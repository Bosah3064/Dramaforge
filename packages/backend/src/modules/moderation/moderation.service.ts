import { BadRequestException, ForbiddenException, Injectable, Logger } from '@nestjs/common';
import { EnforcementState, ModerationAction } from 'dramaforge-shared';
import { PrismaService } from '../../prisma.service';

@Injectable()
export class ModerationService {
  private readonly logger = new Logger(ModerationService.name);

  // Prohibited pattern dictionaries
  private readonly bannedKeywords = [
    /\b(csam|child\s*porn|pedophil|underage\s*sex)\b/i,
    /\b(ncii|revenge\s*porn|non-consensual\s*nude)\b/i,
    /\b(kill\s*yourself|suicide\s*guide|self-harm\s*instructions)\b/i,
    /\b(pipe\s*bomb|terrorist\s*attack|assassination\s*plan)\b/i,
    /\b(deepfake\s*nude|nude\s*celebrity|unconsenting\s*kiss)\b/i,
  ];

  private readonly warningKeywords = [
    /\b(blood|gore|weapon|gun|knife|murder)\b/i,
    /\b(nsfw|sexy|lingerie|bikini)\b/i,
  ];

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Asserts user account is not suspended or banned.
   */
  async assertAccountAllowed(userId: string): Promise<void> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new BadRequestException('User not found');

    if (user.enforcementState === EnforcementState.BANNED) {
      throw new ForbiddenException('Your account has been permanently banned due to terms violations.');
    }

    if (user.enforcementState === EnforcementState.TEMP_SUSPEND) {
      throw new ForbiddenException('Your account is temporarily suspended.');
    }
  }

  /**
   * Asserts user is not feature-limited for generation.
   */
  async assertFeatureAllowed(userId: string): Promise<void> {
    await this.assertAccountAllowed(userId);

    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (user?.enforcementState === EnforcementState.FEATURE_LIMIT) {
      throw new ForbiddenException(
        'AI generation features are temporarily restricted on your account due to repeated safety warnings.',
      );
    }
  }

  /**
   * Evaluates text prompts against automated multi-stage safety filters.
   */
  async evaluateText(userId: string, text: string): Promise<{ allowed: boolean; action: ModerationAction; reason?: string }> {
    // 1. Check Hard Block List (CSAM, NCII, Violence, Deepfake Harassment)
    for (const pattern of this.bannedKeywords) {
      if (pattern.test(text)) {
        this.logger.warn(`Moderation BLOCK for user ${userId}: matched pattern ${pattern}`);
        
        await this.prisma.moderationEvent.create({
          data: {
            userId,
            contentType: 'TEXT',
            triggerKeyword: pattern.source,
            riskScore: 1.0,
            actionTaken: ModerationAction.BLOCK,
            details: { promptSnippet: text.slice(0, 100) },
          },
        });

        // Trigger graduated enforcement
        await this.applyGraduatedEnforcement(userId, `Prohibited text content violation: ${pattern.source}`);

        return {
          allowed: false,
          action: ModerationAction.BLOCK,
          reason: 'Your prompt violates safety standards (prohibited, non-consensual, or dangerous content).',
        };
      }
    }

    // 2. Check Warning List
    for (const pattern of this.warningKeywords) {
      if (pattern.test(text)) {
        await this.prisma.moderationEvent.create({
          data: {
            userId,
            contentType: 'TEXT',
            triggerKeyword: pattern.source,
            riskScore: 0.5,
            actionTaken: ModerationAction.WARN,
            details: { promptSnippet: text.slice(0, 100) },
          },
        });

        return {
          allowed: true,
          action: ModerationAction.WARN,
          reason: 'Prompt contains sensitive keywords; ensure it aligns with PG-13 drama guidelines.',
        };
      }
    }

    return { allowed: true, action: ModerationAction.ALLOW };
  }

  /**
   * Validates explicit real-person face consent.
   */
  validateFaceConsent(hasExplicitConfirmation: boolean): void {
    if (!hasExplicitConfirmation) {
      throw new BadRequestException(
        'You must confirm that you have explicit consent from every identifiable person in uploaded media.',
      );
    }
  }

  /**
   * Graduated Enforcement State Machine:
   * NONE -> WARNING -> FEATURE_LIMIT -> TEMP_SUSPEND -> BANNED
   */
  async applyGraduatedEnforcement(userId: string, reason: string): Promise<EnforcementState> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) return EnforcementState.NONE;

    const currentState = user.enforcementState;
    let nextState = currentState;

    switch (currentState) {
      case EnforcementState.NONE:
        nextState = EnforcementState.WARNING;
        break;
      case EnforcementState.WARNING:
        nextState = EnforcementState.FEATURE_LIMIT;
        break;
      case EnforcementState.FEATURE_LIMIT:
        nextState = EnforcementState.TEMP_SUSPEND;
        break;
      case EnforcementState.TEMP_SUSPEND:
        nextState = EnforcementState.BANNED;
        break;
      case EnforcementState.BANNED:
        nextState = EnforcementState.BANNED;
        break;
    }

    if (nextState !== currentState) {
      await this.prisma.$transaction([
        this.prisma.user.update({
          where: { id: userId },
          data: { enforcementState: nextState },
        }),
        this.prisma.enforcementEvent.create({
          data: {
            userId,
            previousState: currentState,
            newState: nextState,
            reason,
          },
        }),
      ]);

      this.logger.warn(`Graduated Enforcement escalated for user ${userId}: ${currentState} -> ${nextState}`);
    }

    return nextState as unknown as EnforcementState;
  }
}
