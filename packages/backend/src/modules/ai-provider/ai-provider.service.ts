import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EffectType } from 'dramaforge-shared';
import { MockAIAdapter } from './adapters/mock-ai.adapter';
import {
  CharacterDefinition,
  FinalCutResult,
  IAIProvider,
  KeyframeResult,
  StoryboardShotPlan,
  StoryScriptResult,
  SubtitleEntry,
  VideoClipResult,
} from './interfaces/ai-provider.interface';

@Injectable()
export class AIProviderService implements IAIProvider {
  private readonly logger = new Logger(AIProviderService.name);
  private activeProvider: IAIProvider;

  constructor(
    private readonly configService: ConfigService,
    private readonly mockAdapter: MockAIAdapter,
  ) {
    const mode = this.configService.get<string>('AI_PROVIDER_MODE', 'mock').toLowerCase();
    this.logger.log(`AIProviderService initialized in [${mode.toUpperCase()}] mode`);
    // Default to Mock adapter for safe offline development and automated testing
    this.activeProvider = this.mockAdapter;
  }

  getProviderName(): string {
    return this.activeProvider.getProviderName();
  }

  async generateStoryScript(
    prompt: string,
    genre: string,
    durationSeconds: number,
  ): Promise<StoryScriptResult> {
    return this.activeProvider.generateStoryScript(prompt, genre, durationSeconds);
  }

  async generateStoryboard(
    synopsis: string,
    scriptText: string,
    characters: CharacterDefinition[],
  ): Promise<StoryboardShotPlan[]> {
    return this.activeProvider.generateStoryboard(synopsis, scriptText, characters);
  }

  async generateKeyframe(
    prompt: string,
    characterRefs: string[],
    aspectRatio: string,
  ): Promise<KeyframeResult> {
    return this.activeProvider.generateKeyframe(prompt, characterRefs, aspectRatio);
  }

  async generateShotVideo(
    keyframeUrl: string,
    motionPrompt: string,
    durationSeconds: number,
    aspectRatio: string,
  ): Promise<VideoClipResult> {
    return this.activeProvider.generateShotVideo(keyframeUrl, motionPrompt, durationSeconds, aspectRatio);
  }

  async generatePhotoEffect(
    effectType: EffectType,
    sourceImageUrl: string,
    secondaryImageUrl?: string,
  ): Promise<VideoClipResult> {
    return this.activeProvider.generatePhotoEffect(effectType, sourceImageUrl, secondaryImageUrl);
  }

  async assembleFinalCut(
    videoClips: string[],
    subtitles: SubtitleEntry[],
    watermark: boolean,
  ): Promise<FinalCutResult> {
    return this.activeProvider.assembleFinalCut(videoClips, subtitles, watermark);
  }
}
