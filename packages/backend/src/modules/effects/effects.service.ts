import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { COIN_PRICING, EffectType, LedgerReason } from 'dramaforge-shared';
import { PrismaService } from '../../prisma.service';
import { AIProviderService } from '../ai-provider/ai-provider.service';
import { ComplianceService } from '../compliance/compliance.service';
import { ModerationService } from '../moderation/moderation.service';
import { WalletService } from '../wallet/wallet.service';

export interface CreateEffectJobDto {
  effectType: EffectType;
  sourceImageUrl: string;
  secondaryImageUrl?: string;
  hasConsentConfirmation: boolean; // "I have consent from every identifiable person"
}

@Injectable()
export class EffectsService {
  private readonly logger = new Logger(EffectsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly aiProvider: AIProviderService,
    private readonly walletService: WalletService,
    private readonly complianceService: ComplianceService,
    private readonly moderationService: ModerationService,
  ) {}

  async createEffectJob(userId: string, dto: CreateEffectJobDto) {
    // 1. Third-party AI pre-transfer consent
    const hasConsent = await this.complianceService.hasConsent(userId);
    if (!hasConsent) {
      throw new BadRequestException('Pre-transfer AI disclosure consent must be accepted.');
    }

    // 2. Strict Real-Person Consent Checkbox Gate
    this.moderationService.validateFaceConsent(dto.hasConsentConfirmation);

    // 3. User account status
    await this.moderationService.assertFeatureAllowed(userId);

    const cost = COIN_PRICING.PHOTO_EFFECT; // 8 coins

    // 4. Pre-deduct coins strictly before processing
    const deduction = await this.walletService.deductCoins(
      userId,
      cost,
      LedgerReason.USAGE,
      `effect_${dto.effectType}`,
    );

    const effectJob = await this.prisma.effectsJob.create({
      data: {
        userId,
        effectType: dto.effectType,
        sourceImageS3Key: dto.sourceImageUrl,
        secondaryImageS3Key: dto.secondaryImageUrl ?? null,
        hasConsentConfirmation: dto.hasConsentConfirmation,
        status: 'PROCESSING',
      },
    });

    try {
      this.logger.log(`Processing photo effect [${dto.effectType}] for job ${effectJob.id}`);

      const result = await this.aiProvider.generatePhotoEffect(
        dto.effectType,
        dto.sourceImageUrl,
        dto.secondaryImageUrl,
      );

      const updated = await this.prisma.effectsJob.update({
        where: { id: effectJob.id },
        data: {
          status: 'COMPLETED',
          outputVideoS3Key: result.videoUrl,
        },
      });

      return updated;
    } catch (err: any) {
      this.logger.error(`Photo effect rendering failed: ${err.message}`);
      await this.prisma.effectsJob.update({
        where: { id: effectJob.id },
        data: { status: 'FAILED' },
      });

      // Compensating auto-refund
      await this.walletService.autoRefund(userId, effectJob.id, cost, {
        subscription: deduction.deductedFromSubscription,
        purchased: deduction.deductedFromPurchased,
      });

      throw new BadRequestException(`Photo effect failed to render. ${cost} coins have been refunded.`);
    }
  }

  async getEffectJob(userId: string, jobId: string) {
    const job = await this.prisma.effectsJob.findUnique({
      where: { id: jobId },
    });

    if (!job || job.userId !== userId) {
      throw new BadRequestException('Effect job not found');
    }

    return job;
  }
}
