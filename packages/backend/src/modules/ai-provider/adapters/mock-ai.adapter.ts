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
    this.logger.log(`[MockAI] Generating dynamic story script for prompt: "${prompt}", genre: ${genre}`);

    const lowerPrompt = (prompt || '').toLowerCase();
    const effectiveGenre = genre || 'Revenge Drama';

    // Dynamic character extraction / synthesis based on prompt & genre
    const characters = this.synthesizeCharacters(lowerPrompt, effectiveGenre);

    // Formulate 3-Act Script based on user prompt
    const leadName = characters[0]?.name || 'Protagonist';
    const counterName = characters[1]?.name || 'Antagonist';

    const cleanPrompt = prompt?.trim() || 'A high-stakes confrontation unfolding in an unexpected setting';

    const synopsis = `Driven by sudden revelation, ${leadName} confronts ${counterName} regarding: "${cleanPrompt}". What begins as an intense standoff escalates into a twist that upends everything they fought for.`;

    const scriptText = `ACT I: THE HOOK
Scene 1: Atmospheric opening. The world is charged with tension.
${leadName.toUpperCase()}: "You thought nobody would ever trace this back to you, ${counterName}. But every secret leaves a scar."
${counterName.toUpperCase()}: (Smiles faintly, unfazed) "You took a dangerous risk coming here alone. What makes you think you're walking out?"

ACT II: THE CONFRONTATION & TWIST
Scene 2: Thunderous intensity. Evidence is revealed, shattering their assumptions.
${leadName.toUpperCase()}: "Look at the records. You weren't the puppet master — you were the target all along."
${counterName.toUpperCase()}: (Eyes narrowing as realization hits) "Then the board betrayed both of us."

ACT III: THE CLIMAX & ALLIANCE
Scene 3: Sirens and shadows close in. A pact forged in fire.
${leadName.toUpperCase()}: "So do we go down fighting each other, or do we turn the tables on them?"
${counterName.toUpperCase()}: "We take the entire empire back."`;

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
    this.logger.log(`[MockAI] Decomposing story into dynamic storyboard shots`);

    const lead = characters[0]?.name || 'Lead';
    const counter = characters[1]?.name || 'Counterpart';

    const shotTemplates: StoryboardShotPlan[] = [
      {
        sequenceIndex: 1,
        sceneDescription: `Atmospheric wide establishing shot. Rain streaks across glass and neon ambient reflections illuminate ${counter}'s silhouette.`,
        cameraDirection: 'Wide establishing tracking shot, moving forward with dramatic low angle.',
        dialogue: `${lead}: "You thought nobody would ever trace this back to you, ${counter}."`,
        durationSeconds: 5,
        keyframePrompt: `Cinematic wide shot of moody architectural interior, volumetric neon rain rim lighting, silhouette at panoramic window, 8k vertical 9:16, masterpiece cinematography`,
      },
      {
        sequenceIndex: 2,
        sceneDescription: `${lead} steps out of the deep shadows into sharp key light, holding decisive proof.`,
        cameraDirection: `Medium low-angle push-in on ${lead}, intense determined expression, high contrast chiaroscuro lighting.`,
        dialogue: `${lead}: "Every secret leaves a scar."`,
        durationSeconds: 5,
        keyframePrompt: `Medium portrait of determined protagonist holding glowing evidence device, moody dramatic rim lighting, cinematic depth of field, 9:16`,
      },
      {
        sequenceIndex: 3,
        sceneDescription: `${counter} turns slowly, intense gaze meeting the challenge across the polished marble.`,
        cameraDirection: `Tight over-the-shoulder close-up shifting focus dynamically to ${counter}'s reaction.`,
        dialogue: `${counter}: "What makes you think you're walking out of here alive?"`,
        durationSeconds: 5,
        keyframePrompt: `Tight dramatic close-up portrait of powerful antagonist, intense eyes, cinematic backlight, shallow depth of field, 9:16`,
      },
      {
        sequenceIndex: 4,
        sceneDescription: 'Sudden flash of illumination. The classified data drive slides across the dark reflective table.',
        cameraDirection: 'Dynamic Dutch-angle push-in on the evidence sliding across reflective surface with blue LED glow.',
        dialogue: `${lead}: "Look at the records. You were the target all along."`,
        durationSeconds: 5,
        keyframePrompt: `Extreme macro close-up of futuristic encrypted drive sliding across black obsidian table, lightning flash, reflections, 9:16`,
      },
      {
        sequenceIndex: 5,
        sceneDescription: `${lead} and ${counter} stand back-to-back as shadows approach in the corridor, forging an unprecedented alliance.`,
        cameraDirection: 'Two-shot profile panning into a confident freeze-frame as sirens echo in the distance.',
        dialogue: `${counter}: "We take the entire empire back."`,
        durationSeconds: 5,
        keyframePrompt: `Two cinematic characters standing back-to-back in luxury high-rise lobby, dramatic backlight, dust motes, cinematic climax frame, 9:16`,
      },
    ];

    return shotTemplates;
  }

  async generateKeyframe(
    prompt: string,
    characterRefs: string[],
    aspectRatio: string,
  ): Promise<KeyframeResult> {
    this.logger.log(`[MockAI] Generating keyframe image: "${prompt.slice(0, 50)}..."`);

    // Generate high-fidelity SVG with rich cinematic gradients, lighting particles, and scene framing
    const svgContent = `<svg xmlns="http://www.w3.org/2000/svg" width="720" height="1280" viewBox="0 0 720 1280">
      <defs>
        <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#090d16"/>
          <stop offset="35%" stop-color="#1e1b4b"/>
          <stop offset="70%" stop-color="#311042"/>
          <stop offset="100%" stop-color="#0f172a"/>
        </linearGradient>
        <linearGradient id="neonGlow" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stop-color="#8b5cf6" stop-opacity="0.8"/>
          <stop offset="100%" stop-color="#ec4899" stop-opacity="0.8"/>
        </linearGradient>
        <radialGradient id="spotlight" cx="50%" cy="40%" r="60%">
          <stop offset="0%" stop-color="#6366f1" stop-opacity="0.35"/>
          <stop offset="100%" stop-color="#000000" stop-opacity="0"/>
        </radialGradient>
      </defs>
      <rect width="100%" height="100%" fill="url(#bgGrad)"/>
      <circle cx="360" cy="480" r="320" fill="url(#spotlight)"/>
      
      <!-- Cinematic Letterbox Lines -->
      <line x1="40" y1="60" x2="680" y2="60" stroke="#8b5cf6" stroke-opacity="0.3" stroke-width="1"/>
      <line x1="40" y1="1220" x2="680" y2="1220" stroke="#8b5cf6" stroke-opacity="0.3" stroke-width="1"/>

      <!-- Viewfinder Reticles -->
      <path d="M 60 100 L 60 80 L 80 80" stroke="#8b5cf6" stroke-width="2" fill="none"/>
      <path d="M 660 100 L 660 80 L 640 80" stroke="#8b5cf6" stroke-width="2" fill="none"/>
      <path d="M 60 1180 L 60 1200 L 80 1200" stroke="#8b5cf6" stroke-width="2" fill="none"/>
      <path d="M 660 1180 L 660 1200 L 640 1200" stroke="#8b5cf6" stroke-width="2" fill="none"/>

      <!-- Cinematic Badge -->
      <rect x="230" y="90" width="260" height="36" rx="18" fill="#131a29" stroke="#8b5cf6" stroke-width="1"/>
      <text x="360" y="113" font-family="sans-serif" font-size="13" fill="#a78bfa" text-anchor="middle" font-weight="bold">DRAMAFORGE CINEMATIC</text>

      <!-- Center Silhouette Art / Composition -->
      <ellipse cx="360" cy="560" rx="90" ry="180" fill="#030712" opacity="0.85"/>
      <circle cx="360" cy="400" r="60" fill="#030712" opacity="0.85"/>
      <circle cx="360" cy="480" r="140" stroke="url(#neonGlow)" stroke-width="2" fill="none" opacity="0.6"/>

      <!-- Title & Details -->
      <text x="360" y="800" font-family="sans-serif" font-size="28" fill="#ffffff" text-anchor="middle" font-weight="900" letter-spacing="1">KEYFRAME SCENE</text>
      <text x="360" y="840" font-family="sans-serif" font-size="16" fill="#f59e0b" text-anchor="middle" font-weight="bold">${aspectRatio} • 8K ULTRA-HD</text>
      <text x="360" y="920" font-family="sans-serif" font-size="14" fill="#cbd5e1" text-anchor="middle" width="560">${prompt.replace(/"/g, "'").slice(0, 55)}...</text>
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
    
    // Sample cinematic video clips
    const sampleClips = [
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
    ];
    const randomIndex = Math.floor(Math.random() * sampleClips.length);

    return {
      videoUrl: `${sampleClips[randomIndex]}#t=0,${durationSeconds}`,
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

  private synthesizeCharacters(lowerPrompt: string, genre: string): CharacterDefinition[] {
    if (lowerPrompt.includes('cyber') || lowerPrompt.includes('android') || lowerPrompt.includes('robot') || lowerPrompt.includes('hack')) {
      return [
        {
          name: 'Kai Chen',
          appearance: 'Cybernetically augmented investigator in a high-collar matte carbon coat with luminous amber neural optic.',
          voiceStyle: 'Calm, gritty, analytical with a slight electronic resonance',
        },
        {
          name: 'Vespera',
          appearance: 'Rogue corporate AI architect dressed in iridescent synth-silk, sharp holographic silver hair.',
          voiceStyle: 'Whispering, mocking, calculating and seductive',
        },
      ];
    }

    if (lowerPrompt.includes('billionaire') || lowerPrompt.includes('ceo') || lowerPrompt.includes('heir') || lowerPrompt.includes('gala')) {
      return [
        {
          name: 'Elena Vance',
          appearance: 'Disguised investigative reporter in an emerald evening gown, poised and piercing dark eyes.',
          voiceStyle: 'Sharp, composed, resolute',
        },
        {
          name: 'Marcus Sterling',
          appearance: 'Enigmatic billionaire tech titan in an open-collar tailored navy tuxedo, piercing silver eyes.',
          voiceStyle: 'Low, velvety, authoritative and commanding',
        },
      ];
    }

    if (lowerPrompt.includes('samurai') || lowerPrompt.includes('blade') || lowerPrompt.includes('warrior') || lowerPrompt.includes('clan')) {
      return [
        {
          name: 'Jin Sakai',
          appearance: 'Lone wandering swordsman with a tattered dark indigo haori, weathered hands clutching a wrapped hilt.',
          voiceStyle: 'Gravelly, disciplined, quiet intensity',
        },
        {
          name: 'Lord Kuroda',
          appearance: 'Corrupt warlord clad in gilded black o-yoroi armor with a crimson sash.',
          voiceStyle: 'Booming, ruthless, arrogant and sneering',
        },
      ];
    }

    if (lowerPrompt.includes('alien') || lowerPrompt.includes('space') || lowerPrompt.includes('star') || lowerPrompt.includes('ship')) {
      return [
        {
          name: 'Commander Sarah Ryder',
          appearance: 'Deep-space salvage captain in weathered pressure suit with glowing visor.',
          voiceStyle: 'Pragmatic, urgent, commanding',
        },
        {
          name: 'The Entity',
          appearance: 'Shifting humanoid silhouette woven from golden plasma and star dust.',
          voiceStyle: 'Echoing, harmonic, timeless',
        },
      ];
    }

    // Default dynamic dramatic pairing
    return [
      {
        name: 'Elena Vance',
        appearance: 'Confident investigative protagonist in a tailored trench coat with observant, resolute eyes.',
        voiceStyle: 'Determined, sharp, articulate',
      },
      {
        name: 'Marcus Sterling',
        appearance: 'Charismatic rival titan in a sharp dark suit with an enigmatic, intense presence.',
        voiceStyle: 'Low, composed, authoritative',
      },
    ];
  }
}
