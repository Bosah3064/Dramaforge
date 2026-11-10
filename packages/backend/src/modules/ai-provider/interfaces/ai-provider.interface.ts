import { EffectType } from 'dramaforge-shared';

export interface CharacterDefinition {
  name: string;
  appearance: string;
  voiceStyle?: string;
  referenceImageUrl?: string;
}

export interface StoryScriptResult {
  synopsis: string;
  characters: CharacterDefinition[];
  scriptText: string;
  estimatedShots: number;
}

export interface StoryboardShotPlan {
  sequenceIndex: number;
  sceneDescription: string;
  cameraDirection: string;
  dialogue?: string;
  durationSeconds: number;
  keyframePrompt: string;
}

export interface KeyframeResult {
  imageUrl: string;
  seed: number;
  promptUsed: string;
}

export interface VideoClipResult {
  videoUrl: string;
  durationSeconds: number;
  resolution: string;
}

export interface SubtitleEntry {
  sequenceIndex: number;
  startTimeSeconds: number;
  endTimeSeconds: number;
  speaker: string;
  text: string;
}

export interface FinalCutResult {
  finalVideoUrl: string;
  durationSeconds: number;
  resolution: string;
  isWatermarked: boolean;
}

export interface IAIProvider {
  getProviderName(): string;
  generateStoryScript(
    prompt: string,
    genre: string,
    durationSeconds: number,
  ): Promise<StoryScriptResult>;
  generateStoryboard(
    synopsis: string,
    scriptText: string,
    characters: CharacterDefinition[],
  ): Promise<StoryboardShotPlan[]>;
  generateKeyframe(
    prompt: string,
    characterRefs: string[],
    aspectRatio: string,
  ): Promise<KeyframeResult>;
  generateShotVideo(
    keyframeUrl: string,
    motionPrompt: string,
    durationSeconds: number,
    aspectRatio: string,
  ): Promise<VideoClipResult>;
  generatePhotoEffect(
    effectType: EffectType,
    sourceImageUrl: string,
    secondaryImageUrl?: string,
  ): Promise<VideoClipResult>;
  assembleFinalCut(
    videoClips: string[],
    subtitles: SubtitleEntry[],
    watermark: boolean,
  ): Promise<FinalCutResult>;
}
