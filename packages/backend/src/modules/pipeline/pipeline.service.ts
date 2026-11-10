import { BadRequestException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import {
  COIN_PRICING,
  GenerationStatus,
  GenerationType,
  LedgerReason,
  ProjectStatus,
  ShotStatus,
} from 'dramaforge-shared';
import { PrismaService } from '../../prisma.service';
import { AIProviderService } from '../ai-provider/ai-provider.service';
import { CharacterDefinition, SubtitleEntry } from '../ai-provider/interfaces/ai-provider.interface';
import { ComplianceService } from '../compliance/compliance.service';
import { ModerationService } from '../moderation/moderation.service';
import { WalletService } from '../wallet/wallet.service';

export interface GenerateStoryDto {
  projectId: string;
  prompt: string;
  genre?: string;
  durationSeconds?: number;
}

export interface QuickGenerateDto {
  title: string;
  prompt: string;
  genre?: string;
  aspectRatio?: any;
  targetDurationSeconds?: number;
  removeWatermark?: boolean;
}

@Injectable()
export class PipelineService {
  private readonly logger = new Logger(PipelineService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly aiProvider: AIProviderService,
    private readonly walletService: WalletService,
    private readonly complianceService: ComplianceService,
    private readonly moderationService: ModerationService,
  ) {}

  /**
   * STAGE 1: STORY OUTLINE & SCRIPT EXPANSION
   * Cost: 0 Coins (Free exploration)
   */
  async generateStory(userId: string, dto: GenerateStoryDto) {
    // 1. Compliance: Check pre-transfer third-party AI consent
    const hasConsent = await this.complianceService.hasConsent(userId);
    if (!hasConsent) {
      throw new BadRequestException('Pre-transfer AI disclosure consent must be accepted prior to generation.');
    }

    // 2. Moderation: Assert user allowed and prompt safe
    await this.moderationService.assertFeatureAllowed(userId);
    const modResult = await this.moderationService.evaluateText(userId, dto.prompt);
    if (!modResult.allowed) {
      throw new BadRequestException(modResult.reason);
    }

    const project = await this.prisma.project.findUnique({ where: { id: dto.projectId } });
    if (!project || project.userId !== userId) {
      throw new NotFoundException('Project not found');
    }

    const duration = dto.durationSeconds ?? project.targetDurationSeconds;
    const genre = dto.genre ?? 'drama';

    // 3. Call AI Provider for script expansion
    const storyPlan = await this.aiProvider.generateStoryScript(dto.prompt, genre, duration);

    // 4. Save Story
    const story = await this.prisma.story.create({
      data: {
        projectId: project.id,
        synopsis: storyPlan.synopsis,
        genre,
        characters: storyPlan.characters as any,
        scriptText: storyPlan.scriptText,
      },
    });

    this.logger.log(`Story script generated for project ${project.id}, story ${story.id}`);
    return story;
  }

  /**
   * STAGE 2: STORYBOARD & KEYFRAME GENERATION
   * Cost: 2 coins per shot
   */
  async generateStoryboard(userId: string, storyId: string) {
    const hasConsent = await this.complianceService.hasConsent(userId);
    if (!hasConsent) throw new BadRequestException('Consent required.');
    await this.moderationService.assertFeatureAllowed(userId);

    const story = await this.prisma.story.findUnique({
      where: { id: storyId },
      include: { project: true, shots: true },
    });

    if (!story || story.project.userId !== userId) {
      throw new NotFoundException('Story not found');
    }

    // 1. Decompose into shots plan
    const shotPlans = await this.aiProvider.generateStoryboard(
      story.synopsis,
      story.scriptText,
      story.characters as unknown as CharacterDefinition[],
    );

    const shotCount = shotPlans.length;
    const totalCost = shotCount * COIN_PRICING.KEYFRAME_PER_SHOT;

    // 2. Pre-deduct coins strictly before generation
    const deduction = await this.walletService.deductCoins(
      userId,
      totalCost,
      LedgerReason.USAGE,
      `storyboard_${storyId}`,
    );

    const generation = await this.prisma.generation.create({
      data: {
        userId,
        jobId: `gen_storyboard_${Date.now()}_${Math.random().toString(36).substring(7)}`,
        type: GenerationType.KEYFRAME_IMAGE,
        provider: this.aiProvider.getProviderName(),
        coinCost: totalCost,
        status: GenerationStatus.PROCESSING,
      },
    });

    try {
      // Clean previous shots if re-running
      await this.prisma.shot.deleteMany({ where: { storyId } });

      const createdShots = [];
      for (const plan of shotPlans) {
        // Generate keyframe image via AI Provider
        const keyframe = await this.aiProvider.generateKeyframe(
          plan.keyframePrompt,
          [],
          story.project.aspectRatio,
        );

        const shot = await this.prisma.shot.create({
          data: {
            storyId,
            sequenceIndex: plan.sequenceIndex,
            sceneDescription: plan.sceneDescription,
            cameraDirection: plan.cameraDirection,
            dialogue: plan.dialogue,
            durationSeconds: plan.durationSeconds,
            keyframePrompt: plan.keyframePrompt,
            keyframeImageUrl: keyframe.imageUrl,
            status: ShotStatus.IMAGE_DONE,
          },
        });
        createdShots.push(shot);
      }

      await this.prisma.generation.update({
        where: { id: generation.id },
        data: { status: GenerationStatus.COMPLETED },
      });

      return createdShots;
    } catch (err: any) {
      this.logger.error(`Failed to generate storyboard keyframes: ${err.message}`);
      await this.prisma.generation.update({
        where: { id: generation.id },
        data: { status: GenerationStatus.FAILED, errorMessage: err.message },
      });

      // AUTO-REFUND compensating ledger entry
      await this.walletService.autoRefund(userId, generation.id, totalCost, {
        subscription: deduction.deductedFromSubscription,
        purchased: deduction.deductedFromPurchased,
      });

      throw new BadRequestException(`Storyboard keyframe generation failed. ${totalCost} coins have been refunded.`);
    }
  }

  /**
   * STAGE 3: SHOT VIDEO GENERATION (Image-to-Video for all shots)
   * Cost: 8 coins per shot
   */
  async generateShotVideos(userId: string, storyId: string) {
    const hasConsent = await this.complianceService.hasConsent(userId);
    if (!hasConsent) throw new BadRequestException('Consent required.');
    await this.moderationService.assertFeatureAllowed(userId);

    const story = await this.prisma.story.findUnique({
      where: { id: storyId },
      include: {
        project: true,
        shots: { orderBy: { sequenceIndex: 'asc' } },
      },
    });

    if (!story || story.project.userId !== userId) {
      throw new NotFoundException('Story not found');
    }

    const pendingShots = story.shots.filter(
      (s) => s.status === ShotStatus.IMAGE_DONE || s.status === ShotStatus.PENDING,
    );

    if (pendingShots.length === 0) {
      return story.shots;
    }

    const totalCost = pendingShots.length * COIN_PRICING.VIDEO_PER_SHOT;

    // 1. Pre-deduct coins strictly before queueing
    const deduction = await this.walletService.deductCoins(
      userId,
      totalCost,
      LedgerReason.USAGE,
      `shots_${storyId}`,
    );

    const generation = await this.prisma.generation.create({
      data: {
        userId,
        jobId: `gen_shots_${Date.now()}_${Math.random().toString(36).substring(7)}`,
        type: GenerationType.SHOT_VIDEO,
        provider: this.aiProvider.getProviderName(),
        coinCost: totalCost,
        status: GenerationStatus.PROCESSING,
      },
    });

    const completedShots = [];
    try {
      for (const shot of pendingShots) {
        await this.prisma.shot.update({
          where: { id: shot.id },
          data: { status: ShotStatus.VIDEO_GENERATING },
        });

        const videoClip = await this.aiProvider.generateShotVideo(
          shot.keyframeImageUrl || '',
          shot.sceneDescription,
          shot.durationSeconds,
          story.project.aspectRatio,
        );

        const updatedShot = await this.prisma.shot.update({
          where: { id: shot.id },
          data: {
            videoClipUrl: videoClip.videoUrl,
            status: ShotStatus.VIDEO_DONE,
          },
        });
        completedShots.push(updatedShot);
      }

      await this.prisma.generation.update({
        where: { id: generation.id },
        data: { status: GenerationStatus.COMPLETED },
      });

      return completedShots;
    } catch (err: any) {
      this.logger.error(`Shot video rendering failed: ${err.message}`);
      await this.prisma.generation.update({
        where: { id: generation.id },
        data: { status: GenerationStatus.FAILED, errorMessage: err.message },
      });

      // AUTO-REFUND
      await this.walletService.autoRefund(userId, generation.id, totalCost, {
        subscription: deduction.deductedFromSubscription,
        purchased: deduction.deductedFromPurchased,
      });

      throw new BadRequestException(`Video generation failed. ${totalCost} coins have been refunded.`);
    }
  }

  /**
   * INDIVIDUAL SHOT REGENERATION
   * Cost: 8 coins
   */
  async regenerateSingleShot(userId: string, shotId: string) {
    const hasConsent = await this.complianceService.hasConsent(userId);
    if (!hasConsent) throw new BadRequestException('Consent required.');
    await this.moderationService.assertFeatureAllowed(userId);

    const shot = await this.prisma.shot.findUnique({
      where: { id: shotId },
      include: { story: { include: { project: true } } },
    });

    if (!shot || shot.story.project.userId !== userId) {
      throw new NotFoundException('Shot not found');
    }

    const cost = COIN_PRICING.VIDEO_PER_SHOT;
    const deduction = await this.walletService.deductCoins(
      userId,
      cost,
      LedgerReason.USAGE,
      `shot_regen_${shotId}`,
    );

    const generation = await this.prisma.generation.create({
      data: {
        userId,
        jobId: `gen_shot_single_${Date.now()}_${shotId.substring(0, 5)}`,
        type: GenerationType.SHOT_VIDEO,
        provider: this.aiProvider.getProviderName(),
        coinCost: cost,
        status: GenerationStatus.PROCESSING,
      },
    });

    try {
      const videoClip = await this.aiProvider.generateShotVideo(
        shot.keyframeImageUrl || '',
        shot.sceneDescription,
        shot.durationSeconds,
        shot.story.project.aspectRatio,
      );

      const updated = await this.prisma.shot.update({
        where: { id: shotId },
        data: {
          videoClipUrl: videoClip.videoUrl,
          status: ShotStatus.VIDEO_DONE,
        },
      });

      await this.prisma.generation.update({
        where: { id: generation.id },
        data: { status: GenerationStatus.COMPLETED },
      });

      return updated;
    } catch (err: any) {
      await this.prisma.generation.update({
        where: { id: generation.id },
        data: { status: GenerationStatus.FAILED, errorMessage: err.message },
      });

      await this.walletService.autoRefund(userId, generation.id, cost, {
        subscription: deduction.deductedFromSubscription,
        purchased: deduction.deductedFromPurchased,
      });

      throw new BadRequestException(`Shot regeneration failed. ${cost} coins refunded.`);
    }
  }

  /**
   * STAGE 4: FINAL CUT ASSEMBLY & SUBTITLES
   * Cost: 15 coins for 1080p unwatermarked export, or 0 if user has active subscription
   */
  async assembleFinalCut(userId: string, projectId: string, removeWatermark = false) {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
      include: {
        stories: {
          include: {
            shots: { orderBy: { sequenceIndex: 'asc' } },
          },
        },
      },
    });

    if (!project || project.userId !== userId) {
      throw new NotFoundException('Project not found');
    }

    const story = project.stories[0];
    if (!story || !story.shots || story.shots.length === 0) {
      throw new BadRequestException('Project has no shots to assemble.');
    }

    // Check user active subscription
    const activeSub = await this.prisma.subscription.findFirst({
      where: { userId, status: 'ACTIVE' },
    });

    let cost = 0;
    let shouldWatermark = true;

    if (activeSub) {
      shouldWatermark = false; // Subscribers always receive unwatermarked 1080p
    } else if (removeWatermark) {
      cost = COIN_PRICING.FINAL_RENDER_1080P;
      shouldWatermark = false;
    }

    let deduction;
    if (cost > 0) {
      deduction = await this.walletService.deductCoins(
        userId,
        cost,
        LedgerReason.USAGE,
        `final_cut_${projectId}`,
      );
    }

    const videoClips = story.shots
      .map((s) => s.videoClipUrl)
      .filter((url): url is string => Boolean(url));

    let elapsed = 0;
    const subtitles: SubtitleEntry[] = story.shots.map((s) => {
      const entry: SubtitleEntry = {
        sequenceIndex: s.sequenceIndex,
        startTimeSeconds: elapsed,
        endTimeSeconds: elapsed + s.durationSeconds,
        speaker: 'Voice',
        text: s.dialogue || s.sceneDescription,
      };
      elapsed += s.durationSeconds;
      return entry;
    });

    const finalCut = await this.aiProvider.assembleFinalCut(
      videoClips,
      subtitles,
      shouldWatermark,
    );

    const updatedProject = await this.prisma.project.update({
      where: { id: projectId },
      data: {
        finalVideoUrl: finalCut.finalVideoUrl,
        status: ProjectStatus.COMPLETED,
      },
    });

    return updatedProject;
  }

  /**
   * FLOW A: QUICK GENERATION (ONE TAP)
   * Orchestrates Stage 1 -> Stage 2 -> Stage 3 -> Stage 4 end-to-end
   */
  async runQuickGeneration(userId: string, dto: QuickGenerateDto) {
    // 1. Create project
    const project = await this.prisma.project.create({
      data: {
        userId,
        title: dto.title || 'Quick AI Drama',
        mode: 'QUICK' as any,
        aspectRatio: dto.aspectRatio ?? 'PORTRAIT_9_16',
        targetDurationSeconds: dto.targetDurationSeconds ?? 25,
        status: ProjectStatus.PROCESSING,
      },
    });

    try {
      // Stage 1: Story
      const story = await this.generateStory(userId, {
        projectId: project.id,
        prompt: dto.prompt,
        genre: dto.genre,
        durationSeconds: dto.targetDurationSeconds,
      });

      // Stage 2: Storyboard keyframes
      await this.generateStoryboard(userId, story.id);

      // Stage 3: Shot videos
      await this.generateShotVideos(userId, story.id);

      // Stage 4: Final Cut
      const finalProject = await this.assembleFinalCut(
        userId,
        project.id,
        dto.removeWatermark ?? false,
      );

      return finalProject;
    } catch (err: any) {
      await this.prisma.project.update({
        where: { id: project.id },
        data: { status: ProjectStatus.FAILED },
      });
      throw err;
    }
  }
}
