import { Injectable, Logger } from '@nestjs/common';
import { EffectType } from 'dramaforge-shared';
import {
  CharacterDefinition,
  FinalCutResult,
  IAIProvider,
  KeyframeResult,
  StoryboardShotPlan,
  StoryScriptResult,
  SubtitleEntry,
  VideoClipResult,
} from '../interfaces/ai-provider.interface';

@Injectable()
export class MockAIAdapter implements IAIProvider {
  private readonly logger = new Logger(MockAIAdapter.name);

  getProviderName(): string {
    return 'MOCK';
  }

  async generateStoryScript(
    prompt: string,
    genre: string,
    durationSeconds: number,
  ): Promise<StoryScriptResult> {
    this.logger.log(`[MockAI] Generating story script for prompt: "${prompt}", genre: ${genre}`);

    const characters: CharacterDefinition[] = [
      {
        name: 'Elena Vance',
        appearance: 'Confident investigative journalist in a tailored trench coat, dark brown hair.',
        voiceStyle: 'Determined, sharp, articulate',
      },
      {
        name: 'Marcus Sterling',
        appearance: 'Enigmatic billionaire tech titan in an open-collar navy suit, piercing silver eyes.',
        voiceStyle: 'Low, composed, authoritative',
      },
    ];

    const synopsis = `When investigative reporter Elena Vance uncovers a covert takeover orchestrated by CEO Marcus Sterling, a tense confrontation in a rainy penthouse penthouse leads to a shocking alliance neither anticipated.`;

    const scriptText = `ACT I: THE INFILTRATION
Scene 1: Marcus's high-rise penthouse office overlooking neon city rain.
ELENA: "You thought you buried the prototype data, Marcus. But paper trails don't vanish into thin air."
MARCUS: (Smiles without turning) "You walked through five security checkpoints, Elena. What makes you think you're holding leverage?"

ACT II: THE REVELATION
Scene 2: Thunder rumbles outside floor-to-ceiling glass. Elena slides the encrypted drive across the glass table.
ELENA: "This wasn't an accident. Your board betrayed you first."
MARCUS: (Turns slowly, eyes hardening) "Then it seems we share an enemy."

ACT III: THE ALLIANCE
Scene 3: Sirens echo far below. They exchange a decisive glance as security footfalls approach.
ELENA: "So do we run, or do we expose them together?"
MARCUS: "We take the entire empire back."`;

    const estimatedShots = Math.max(3, Math.min(8, Math.round(durationSeconds / 5)));

    return {
      synopsis,
      characters,
      scriptText,
      estimatedShots,
    };
  }

  async generateStoryboard(
    synopsis: string,
    scriptText: string,
    characters: CharacterDefinition[],
  ): Promise<StoryboardShotPlan[]> {
    this.logger.log(`[MockAI] Decomposing script into storyboard shots`);

    return [
      {
        sequenceIndex: 1,
        sceneDescription: 'High-rise glass office at night. Rain streams down windows with city neon reflections.',
        cameraDirection: 'Wide establishing tracking shot, moving forward toward Marcus silhouetted by the glass.',
        dialogue: 'Elena: You thought you buried the prototype data, Marcus.',
        durationSeconds: 5,
        keyframePrompt: 'Cinematic wide shot of luxury modern office at night, neon rain outside, man standing at floor to ceiling window, 8k vertical 9:16',
      },
      {
        sequenceIndex: 2,
        sceneDescription: 'Elena steps into the dim ambient lighting, holding a glowing encrypted USB drive.',
        cameraDirection: 'Medium low-angle shot on Elena Vance, determined expression, sharp lighting.',
        dialogue: 'Elena: Paper trails don\'t vanish into thin air.',
        durationSeconds: 5,
        keyframePrompt: 'Medium shot of female investigative journalist holding glowing device in dark modern room, dramatic lighting, 9:16',
      },
      {
        sequenceIndex: 3,
        sceneDescription: 'Marcus turns around slowly, his silver eyes catching the amber table lamp light.',
        cameraDirection: 'Tight over-the-shoulder close-up shifting focus to Marcus\'s reaction.',
        dialogue: 'Marcus: What makes you think you\'re holding leverage?',
        durationSeconds: 5,
        keyframePrompt: 'Intense cinematic close-up of handsome billionaire in navy suit, subtle smirk, dramatic shadow, 9:16',
      },
      {
        sequenceIndex: 4,
        sceneDescription: 'Flash of lightning illuminates the room as Elena slides the drive onto the table.',
        cameraDirection: 'Dynamic dutch-angle push in on the drive sliding across polished dark marble.',
        dialogue: 'Elena: Your board betrayed you first.',
        durationSeconds: 5,
        keyframePrompt: 'Extreme close-up of encrypted metallic drive sliding across reflective black marble table with blue LED glow, 9:16',
      },
      {
        sequenceIndex: 5,
        sceneDescription: 'Elena and Marcus stand side-by-side as elevator doors ding in the distance.',
        cameraDirection: 'Two-shot profile panning into a confident freeze frame as sirens wail.',
        dialogue: 'Marcus: We take the entire empire back.',
        durationSeconds: 5,
        keyframePrompt: 'Two characters standing back-to-back in futuristic boardroom, cinematic backlight, dramatic short drama climax, 9:16',
      },
    ];
  }

  async generateKeyframe(
    prompt: string,
    characterRefs: string[],
    aspectRatio: string,
  ): Promise<KeyframeResult> {
    this.logger.log(`[MockAI] Generating keyframe image: "${prompt.slice(0, 50)}..."`);
    // Return SVG data URI placeholder for deterministic offline dev
    const svgContent = `<svg xmlns="http://www.w3.org/2000/svg" width="720" height="1280" viewBox="0 0 720 1280">
      <defs>
        <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#0f172a"/>
          <stop offset="50%" stop-color="#1e1b4b"/>
          <stop offset="100%" stop-color="#311042"/>
        </linearGradient>
      </defs>
      <rect width="100%" height="100%" fill="url(#bg)"/>
      <circle cx="360" cy="450" r="140" fill="#6366f1" opacity="0.4"/>
      <text x="360" y="470" font-family="sans-serif" font-size="28" fill="#ffffff" text-anchor="middle" font-weight="bold">DramaForge Keyframe</text>
      <text x="360" y="520" font-family="sans-serif" font-size="16" fill="#94a3b8" text-anchor="middle">Ratio: ${aspectRatio}</text>
      <text x="360" y="700" font-family="sans-serif" font-size="14" fill="#cbd5e1" text-anchor="middle" width="600">${prompt.slice(0, 60)}...</text>
    </svg>`;

    const base64Svg = Buffer.from(svgContent).toString('base64');
    const imageUrl = `data:image/svg+xml;base64,${base64Svg}`;

    return {
      imageUrl,
      seed: Math.floor(Math.random() * 1000000),
      promptUsed: prompt,
    };
  }

  async generateShotVideo(
    keyframeUrl: string,
    motionPrompt: string,
    durationSeconds: number,
    aspectRatio: string,
  ): Promise<VideoClipResult> {
    this.logger.log(`[MockAI] Generating shot video clip (${durationSeconds}s, ${aspectRatio})`);
    return {
      videoUrl: `https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4#t=0,${durationSeconds}`,
      durationSeconds,
      resolution: aspectRatio === '16:9' ? '1920x1080' : '1080x1920',
    };
  }

  async generatePhotoEffect(
    effectType: EffectType,
    sourceImageUrl: string,
    secondaryImageUrl?: string,
  ): Promise<VideoClipResult> {
    this.logger.log(`[MockAI] Rendering photo effect: ${effectType}`);
    return {
      videoUrl: `https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4#effect=${effectType}`,
      durationSeconds: 6,
      resolution: '1080x1920',
    };
  }

  async assembleFinalCut(
    videoClips: string[],
    subtitles: SubtitleEntry[],
    watermark: boolean,
  ): Promise<FinalCutResult> {
    const totalDuration = subtitles.length > 0 ? subtitles[subtitles.length - 1].endTimeSeconds : videoClips.length * 5;
    this.logger.log(`[MockAI] Assembling final cut: ${videoClips.length} clips, total ${totalDuration}s, watermark: ${watermark}`);

    return {
      finalVideoUrl: `https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4#t=0,${Math.max(15, totalDuration)}`,
      durationSeconds: Math.max(15, totalDuration),
      resolution: '1080x1920',
      isWatermarked: watermark,
    };
  }
}
