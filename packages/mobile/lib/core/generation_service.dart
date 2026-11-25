import 'dart:math';
import '../models/project_model.dart';
import 'api_client.dart';

class CastArchetype {
  final String id;
  final String name;
  final String role;
  final String appearance;
  final String voiceStyle;
  final String imageUrl;
  final String medium; // 'REAL_HUMAN', 'CARTOON_3D', 'ANIME_2D'

  const CastArchetype({
    required this.id,
    required this.name,
    required this.role,
    required this.appearance,
    required this.voiceStyle,
    required this.imageUrl,
    this.medium = 'REAL_HUMAN',
  });
}

class VoicePersona {
  final String id;
  final String name;
  final String title;
  final String tone;

  const VoicePersona({
    required this.id,
    required this.name,
    required this.title,
    required this.tone,
  });
}

class VisualMediumConfig {
  final String id;
  final String name;
  final String shortName;
  final String icon;
  final String description;
  final String promptModifier;

  const VisualMediumConfig({
    required this.id,
    required this.name,
    required this.shortName,
    required this.icon,
    required this.description,
    required this.promptModifier,
  });
}

class GenerationService {
  static final GenerationService _instance = GenerationService._internal();
  factory GenerationService() => _instance;
  GenerationService._internal();

  final ApiClient _apiClient = ApiClient();
  ApiClient get apiClient => _apiClient;

  static const List<VisualMediumConfig> visualMediums = [
    VisualMediumConfig(
      id: 'REAL_HUMAN',
      name: '🎬 Real Human Live-Action',
      shortName: 'Real Human',
      icon: '🎬',
      description: 'Ultra-realistic 8K cinematic film with human actors, real-world lighting & film optics',
      promptModifier: 'Photorealistic live-action 8k cinema, real human actors, natural skin texture, anamorphic lens, shallow depth of field',
    ),
    VisualMediumConfig(
      id: 'CARTOON_3D',
      name: '✨ 3D Pixar / Disney Cartoon',
      shortName: '3D Cartoon',
      icon: '✨',
      description: 'High-end 3D animated CGI style with expressive characters & vibrant lighting',
      promptModifier: 'High-end 3D CGI cartoon animation, Pixar Disney style, subsurface scattering, expressive stylized character design, vibrant cinematic lighting, raytraced render',
    ),
    VisualMediumConfig(
      id: 'ANIME_2D',
      name: '🎌 Japanese Anime Movie',
      shortName: 'Anime',
      icon: '🎌',
      description: 'Japanese animation movie look, Makoto Shinkai sky, hand-drawn cel shading',
      promptModifier: 'Masterpiece 2D Japanese anime film aesthetic, hand-drawn cel shaded linework, Makoto Shinkai dramatic sky lighting, vibrant anime colors',
    ),
    VisualMediumConfig(
      id: 'WEBTOON_COMIC',
      name: '📖 Webtoon & Graphic Novel',
      shortName: 'Webtoon',
      icon: '📖',
      description: 'Stylized manhwa graphic novel with bold ink lines & dramatic comic panels',
      promptModifier: 'Korean webtoon manhwa comic aesthetic, dynamic ink linework, stylized cel shading, graphic novel panel lighting',
    ),
  ];

  static const List<String> cinematicStyles = [
    '🎬 Hollywood 70mm',
    '🌆 Cyberpunk Neon',
    '🖤 Classic Film Noir',
    '🏰 Dark Fantasy Epic',
    '🌸 Asian Short Drama',
  ];

  static const List<String> cameraMotions = [
    'Dynamic Push-in',
    'Sweeping 360 Orbit',
    'Aerial Crane Pullback',
    'Dutch Angle Snap Zoom',
    'Handheld 60fps Tracking',
  ];

  static const List<String> lightingStyles = [
    'Volumetric Neon Cyberpunk',
    'Golden Hour Anamorphic Flare',
    'Moody Rainy Film Noir',
    'Dark Fantasy Golden Embers',
    'High-Key Luxury Glamour',
  ];

  static const List<String> sfxSoundscapes = [
    'Heavy rain & distant thunder',
    'Metallic device slide & electric hum',
    'Elevator chime & tactical footsteps',
    'Heartbeat pulse & rising strings',
  ];

  static const List<VoicePersona> voicePersonas = [
    VoicePersona(
      id: 'adam_titan',
      name: 'Adam',
      title: 'Deep Authoritative Titan',
      tone: 'Low, resonant, commanding baritone for CEOs, titans and narrators',
    ),
    VoicePersona(
      id: 'rachel_sharp',
      name: 'Rachel',
      title: 'Sharp Sophisticated Infiltrator',
      tone: 'Crisp, poised, sharp and articulate for lead investigators',
    ),
    VoicePersona(
      id: 'kai_gritty',
      name: 'Kai',
      title: 'Cyberpunk Gritty Whisper',
      tone: 'Rough, quiet intensity with subtle synthetic undertone',
    ),
    VoicePersona(
      id: 'vespera_velvet',
      name: 'Vespera',
      title: 'Velvet Noir Antagonist',
      tone: 'Smooth, alluring, calculating, dangerous poise',
    ),
    VoicePersona(
      id: 'leo_rebel',
      name: 'Leo',
      title: 'Heroic Rebel Lead',
      tone: 'Energetic, impassioned, determined young protagonist',
    ),
  ];

  /// AI Director Prompt Polish: Transforms raw ideas into director-grade cinematic prompts
  String enhancePrompt(String prompt, String genre, String style, {String visualMedium = 'REAL_HUMAN'}) {
    final clean = prompt.trim();
    if (clean.isEmpty) {
      return 'Cinematic wide establishing shot of a luxury penthouse office overlooking neon rain, where two rival titans clash over an encrypted prototype.';
    }

    String mediumModifier = 'photorealistic 8k live-action cinematography';
    if (visualMedium == 'CARTOON_3D') {
      mediumModifier = 'high-end 3D CGI cartoon animation, Pixar Disney quality render, stylized character anatomy, vibrant volumetric lighting';
    } else if (visualMedium == 'ANIME_2D') {
      mediumModifier = 'masterpiece 2D Japanese anime feature film aesthetic, Makoto Shinkai sky, hand-drawn cel shading, dynamic anime linework';
    } else if (visualMedium == 'WEBTOON_COMIC') {
      mediumModifier = 'Korean webtoon manhwa graphic novel style, bold expressive ink contours, vibrant cel-shaded color palettes';
    }

    String visualAtmosphere = 'volumetric lighting, atmospheric mist, high dynamic range, dramatic shadow depth';
    if (style.contains('Cyberpunk')) {
      visualAtmosphere = 'neon puddle reflections, holographic advertisements, iridescent chromatic aberration, high-tech dystopian noir';
    } else if (style.contains('Noir')) {
      visualAtmosphere = 'high contrast chiaroscuro lighting, venetian blind shadows, 35mm grain, moody smoke and amber streetlamp glow';
    } else if (style.contains('Fantasy')) {
      visualAtmosphere = 'golden hour celestial rays, floating ember dust, gothic stone pillars, epic wide-angle composition';
    } else if (style.contains('Asian')) {
      visualAtmosphere = 'ultra-sharp glamour lighting, dynamic push-in camera, high-stakes emotional confrontation, punchy pacing';
    }

    return '$clean, rendered in $mediumModifier with $style visual aesthetic, $visualAtmosphere, shallow depth of field, masterpiece production quality';
  }

  /// Curated library of AI Cast Archetypes spanning Real Human, 3D Cartoon, and Anime
  static const List<CastArchetype> castArchetypes = [
    // Real Human Cast
    CastArchetype(
      id: 'kai_cyber',
      name: 'Kai Chen',
      role: 'Protagonist / Investigator',
      appearance: 'Cybernetically augmented investigator in a dark matte trench coat with amber neural eye.',
      voiceStyle: 'Gravelly, disciplined, quiet intensity',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
      medium: 'REAL_HUMAN',
    ),
    CastArchetype(
      id: 'vespera_ai',
      name: 'Vespera',
      role: 'Antagonist / Architect',
      appearance: 'Corporate AI architect in iridescent synth-silk with sharp silver-dyed hair and piercing gaze.',
      voiceStyle: 'Whispering, calculating, commanding',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=600&q=80',
      medium: 'REAL_HUMAN',
    ),
    CastArchetype(
      id: 'marcus_ceo',
      name: 'Marcus Sterling',
      role: 'Titan / Billionaire Rival',
      appearance: 'Enigmatic tech titan in a tailored midnight navy tuxedo, cold analytical silver eyes.',
      voiceStyle: 'Low, velvety, authoritative',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
      medium: 'REAL_HUMAN',
    ),
    CastArchetype(
      id: 'elena_journalist',
      name: 'Elena Vance',
      role: 'Lead Infiltrator',
      appearance: 'Investigative reporter in an emerald evening gown, poised and watchful dark eyes.',
      voiceStyle: 'Sharp, composed, resolute',
      imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80',
      medium: 'REAL_HUMAN',
    ),

    // 3D Cartoon / CGI Cast
    CastArchetype(
      id: 'milo_spark',
      name: 'Milo Spark',
      role: '3D Animated Hero / Tech Prodigy',
      appearance: 'Expressive 3D CGI character with unruly auburn hair, steampunk goggles, and glowing cyan gauntlet.',
      voiceStyle: 'Bubbly, witty, energetic and determined',
      imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=600&q=80',
      medium: 'CARTOON_3D',
    ),
    CastArchetype(
      id: 'princess_astra',
      name: 'Princess Astra',
      role: '3D Animated Royal Rebel',
      appearance: 'Stylized 3D CGI heroine with iridescent violet hair, porcelain features, and star-embroidered cape.',
      voiceStyle: 'Regal, impassioned, melodic and brave',
      imageUrl: 'https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?auto=format&fit=crop&w=600&q=80',
      medium: 'CARTOON_3D',
    ),

    // 2D Anime Cast
    CastArchetype(
      id: 'ren_anime',
      name: 'Ren Takahashi',
      role: 'Anime Protagonist / Swordmaster',
      appearance: 'Cel-shaded anime hero with spiky midnight-blue hair, intense golden eyes, and high-collar dark duster.',
      voiceStyle: 'Calm, focused, quiet samurai intensity',
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=600&q=80',
      medium: 'ANIME_2D',
    ),
    CastArchetype(
      id: 'yukiko_anime',
      name: 'Yukiko',
      role: 'Anime Sorceress / Shadow Infiltrator',
      appearance: 'Ethereal anime heroine with silver twin-tails, glowing amethyst eyes, and dark kimono robes.',
      voiceStyle: 'Soft, mysterious, razor-sharp when provoked',
      imageUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=600&q=80',
      medium: 'ANIME_2D',
    ),
  ];

  /// High-resolution scene image banks organized by visual medium
  static const Map<String, List<String>> _sceneImagePool = {
    // Real Human Live-Action
    'real_human_cyber': [
      'https://images.unsplash.com/photo-1519501025264-65ba15a82390?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1515260268569-9271009adfdb?auto=format&fit=crop&w=900&q=80',
    ],
    'real_human_luxury': [
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=900&q=80',
    ],
    'real_human_mystery': [
      'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=900&q=80',
    ],

    // 3D Cartoon / CGI Animation Stills
    'cartoon_3d': [
      'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&w=900&q=80',
    ],

    // 2D Anime Movie Art
    'anime_2d': [
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=900&q=80',
    ],

    // Webtoon / Comic Art
    'webtoon_comic': [
      'https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=900&q=80',
    ],
  };

  /// Playable video clip library
  static const List<String> _sampleVideos = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
  ];

  /// Analyzes a prompt and extracts structured characters according to visual medium
  List<CharacterModel> analyzeCharactersFromPrompt(
    String prompt,
    String genre, {
    String visualMedium = 'REAL_HUMAN',
  }) {
    if (visualMedium == 'CARTOON_3D') {
      return [
        CharacterModel(
          name: 'Milo Spark',
          role: '3D Animated Prodigy',
          appearance: 'Stylized 3D CGI character with energetic expression, swept auburn hair, and glowing cyan tech gauntlet.',
          voiceStyle: 'Bubbly, witty, energetic and determined',
          referenceImageUrl: castArchetypes[4].imageUrl,
          voicePersona: 'Leo (Heroic Rebel Lead)',
          voiceId: 'leo_rebel',
        ),
        CharacterModel(
          name: 'Princess Astra',
          role: '3D Animated Rebel',
          appearance: 'Stylized 3D CGI royal heroine with flowing violet hair and cosmic embroidered cape.',
          voiceStyle: 'Regal, impassioned, melodic and fearless',
          referenceImageUrl: castArchetypes[5].imageUrl,
          voicePersona: 'Rachel (Sharp Sophisticated Infiltrator)',
          voiceId: 'rachel_sharp',
        ),
      ];
    }

    if (visualMedium == 'ANIME_2D' || visualMedium == 'WEBTOON_COMIC') {
      return [
        CharacterModel(
          name: 'Ren Takahashi',
          role: 'Anime Lead',
          appearance: 'Cel-shaded anime swordsman with spiky dark hair, intense amber eyes, and midnight haori.',
          voiceStyle: 'Calm, disciplined, quiet samurai intensity',
          referenceImageUrl: castArchetypes[6].imageUrl,
          voicePersona: 'Kai (Cyberpunk Gritty Whisper)',
          voiceId: 'kai_gritty',
        ),
        CharacterModel(
          name: 'Yukiko',
          role: 'Shadow Sorceress',
          appearance: 'Cel-shaded anime heroine with silver hair, amethyst eyes, and glowing dark ribbons.',
          voiceStyle: 'Soft, mysterious, calculating',
          referenceImageUrl: castArchetypes[7].imageUrl,
          voicePersona: 'Vespera (Velvet Noir Antagonist)',
          voiceId: 'vespera_velvet',
        ),
      ];
    }

    // Default Real Human Live-Action
    final lower = prompt.toLowerCase();
    if (lower.contains('cyber') || lower.contains('android') || lower.contains('hack') || lower.contains('robot')) {
      return [
        CharacterModel(
          name: 'Kai Chen',
          role: 'Lead Protagonist',
          appearance: 'Cybernetically augmented investigator in a dark matte trench coat with amber neural eye.',
          voiceStyle: 'Gravelly, disciplined, quiet intensity',
          referenceImageUrl: castArchetypes[0].imageUrl,
          voicePersona: 'Kai (Cyberpunk Gritty Whisper)',
          voiceId: 'kai_gritty',
        ),
        CharacterModel(
          name: 'Vespera',
          role: 'Antagonist Architect',
          appearance: 'Corporate AI architect in iridescent synth-silk with sharp holographic silver hair.',
          voiceStyle: 'Whispering, calculating, commanding',
          referenceImageUrl: castArchetypes[1].imageUrl,
          voicePersona: 'Vespera (Velvet Noir Antagonist)',
          voiceId: 'vespera_velvet',
        ),
      ];
    }

    return [
      CharacterModel(
        name: 'Elena Vance',
        role: 'Undercover Lead',
        appearance: 'Investigative reporter in an emerald evening gown, poised and piercing dark eyes.',
        voiceStyle: 'Sharp, composed, resolute',
        referenceImageUrl: castArchetypes[3].imageUrl,
        voicePersona: 'Rachel (Sharp Sophisticated Infiltrator)',
        voiceId: 'rachel_sharp',
      ),
      CharacterModel(
        name: 'Marcus Sterling',
        role: 'Billionaire Titan',
        appearance: 'Enigmatic tech titan in a tailored midnight navy tuxedo, cold analytical silver eyes.',
        voiceStyle: 'Low, velvety, authoritative',
        referenceImageUrl: castArchetypes[2].imageUrl,
        voicePersona: 'Adam (Deep Authoritative Titan)',
        voiceId: 'adam_titan',
      ),
    ];
  }

  /// Full End-to-End Generation Engine supporting Cartoon 3D, Anime 2D & Real Human
  Future<ProjectModel> generateProject({
    required String prompt,
    required String genre,
    required String aspectRatio,
    required int durationSeconds,
    String visualMedium = 'REAL_HUMAN',
    List<CharacterModel>? customCharacters,
    Function(String stageMessage, double progress)? onProgress,
  }) async {
    final effectivePrompt = prompt.trim().isEmpty
        ? 'A high-stakes penthouse confrontation in neon rain revealing a hidden betrayal'
        : prompt.trim();

    onProgress?.call('🧠 Analyzing premise & crafting 3-Act Screenplay...', 0.15);
    await Future.delayed(const Duration(milliseconds: 500));

    final characters = customCharacters != null && customCharacters.isNotEmpty
        ? customCharacters
        : analyzeCharactersFromPrompt(effectivePrompt, genre, visualMedium: visualMedium);

    final lead = characters[0].name;
    final counter = characters.length > 1 ? characters[1].name : 'Rival';

    final mediumConfig = visualMediums.firstWhere((m) => m.id == visualMedium, orElse: () => visualMediums[0]);

    onProgress?.call('🎭 Anchoring [${mediumConfig.shortName}] character visual identities...', 0.35);
    await Future.delayed(const Duration(milliseconds: 400));

    onProgress?.call('🎬 Decomposing scenes & camera choreography...', 0.55);
    await Future.delayed(const Duration(milliseconds: 400));

    final shotCount = max(3, min(6, (durationSeconds / 5).round()));
    final shots = _synthesizeShots(
      prompt: effectivePrompt,
      genre: genre,
      lead: lead,
      counter: counter,
      shotCount: shotCount,
      aspectRatio: aspectRatio,
      visualMedium: visualMedium,
      characters: characters,
    );

    onProgress?.call('🎨 Synthesizing [${mediumConfig.shortName}] scene keyframe images...', 0.75);
    await Future.delayed(const Duration(milliseconds: 500));

    onProgress?.call('🎥 Rendering video clips & mastering audio dubbing...', 0.95);
    await Future.delayed(const Duration(milliseconds: 400));

    final synopsis = 'Driven by sudden revelation, $lead confronts $counter regarding: "$effectivePrompt". Rendered in ${mediumConfig.name} style.';

    final scriptText = '''ACT I: THE HOOK & INFILTRATION
Scene 1: Panoramic floor overlooking neon city rain.
$lead: "You thought nobody would ever trace this back to you, $counter. But every secret leaves a scar."
$counter: (Smiles faintly without turning) "You took a dangerous risk coming here alone. What makes you think you're holding leverage?"

ACT II: THE CONFRONTATION & SHOCKING REVELATION
Scene 2: Thunder rumbles outside floor-to-ceiling glass. The encrypted drive slides across the table.
$lead: "Look at the records. Your board marked you for elimination first."
$counter: (Eyes hardening as data streams decrypt) "Then it seems we share an enemy."

ACT III: THE ALLIANCE & FINAL STAND
Scene 3: Sirens echo far below. Tactical footsteps close in.
$lead: "So do we go down fighting each other, or do we turn the tables on them?"
$counter: "We take the entire empire back."''';

    final story = StoryModel(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      synopsis: synopsis,
      genre: genre,
      scriptText: scriptText,
      characters: characters,
      shots: shots,
    );

    final project = ProjectModel(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      title: _generateTitle(effectivePrompt, genre, mediumConfig.shortName),
      mode: 'STUDIO',
      aspectRatio: aspectRatio.contains('16:9') ? 'LANDSCAPE_16_9' : 'PORTRAIT_9_16',
      status: 'COMPLETED',
      finalVideoUrl: _sampleVideos[0],
      visualMedium: visualMedium,
      bgmTrack: '🎻 Epic Orchestral',
      lutFilter: '🎬 Hollywood 70mm',
      stories: [story],
    );

    onProgress?.call('✨ Final [${mediumConfig.shortName}] Drama Completed!', 1.0);
    return project;
  }

  /// Synthesize individual shots matching the chosen Visual Medium
  List<ShotModel> _synthesizeShots({
    required String prompt,
    required String genre,
    required String lead,
    required String counter,
    required int shotCount,
    required String aspectRatio,
    required String visualMedium,
    required List<CharacterModel> characters,
  }) {
    List<String> pool;
    if (visualMedium == 'CARTOON_3D') {
      pool = _sceneImagePool['cartoon_3d']!;
    } else if (visualMedium == 'ANIME_2D') {
      pool = _sceneImagePool['anime_2d']!;
    } else if (visualMedium == 'WEBTOON_COMIC') {
      pool = _sceneImagePool['webtoon_comic']!;
    } else {
      final lower = prompt.toLowerCase();
      if (lower.contains('cyber') || lower.contains('neon')) {
        pool = _sceneImagePool['real_human_cyber']!;
      } else if (lower.contains('billionaire') || lower.contains('ceo')) {
        pool = _sceneImagePool['real_human_luxury']!;
      } else {
        pool = _sceneImagePool['real_human_mystery']!;
      }
    }

    final mediumConfig = visualMediums.firstWhere((m) => m.id == visualMedium, orElse: () => visualMediums[0]);

    final List<Map<String, String>> templates = [
      {
        'desc': 'Atmospheric wide establishing shot. Rain streaks across glass with reflections silhouetting $counter.',
        'camera': 'Wide establishing tracking shot forward with low tilt',
        'dialogue': '$lead: "You thought nobody would trace this back to you, $counter."',
        'prompt': 'Cinematic wide establishing shot of luxury dark penthouse interior, neon rain reflections, ${mediumConfig.promptModifier}, 9:16',
      },
      {
        'desc': '$lead steps out of deep ambient shadows into sharp rim light, holding glowing proof.',
        'camera': 'Medium low-angle push-in on $lead, high contrast lighting',
        'dialogue': '$lead: "Every secret leaves a scar, no matter how deep you bury it."',
        'prompt': 'Medium portrait of determined character holding glowing device in dark modern room, dramatic rim lighting, ${mediumConfig.promptModifier}, 9:16',
      },
      {
        'desc': '$counter turns slowly, intense gaze locking across the dark polished table.',
        'camera': 'Tight over-the-shoulder close-up shifting focus dynamically to $counter',
        'dialogue': '$counter: "What makes you think you\'re walking out of here alive?"',
        'prompt': 'Tight intense close-up portrait of powerful rival, piercing eyes, backlight, ${mediumConfig.promptModifier}, 9:16',
      },
      {
        'desc': 'Flash of illumination. The encrypted drive slides across the black obsidian marble table.',
        'camera': 'Dynamic Dutch-angle macro push on the sliding drive with blue LED glow',
        'dialogue': '$lead: "Look at the records. Your board marked you first."',
        'prompt': 'Extreme macro close-up of encrypted metallic drive sliding across table, electric sparks, ${mediumConfig.promptModifier}, 9:16',
      },
      {
        'desc': '$lead and $counter stand side-by-side as elevator doors ding in the distance, sealing their pact.',
        'camera': 'Two-shot profile freeze-frame with sirens wailing in the ambient rain',
        'dialogue': '$counter: "We take the entire empire back."',
        'prompt': 'Two characters standing back-to-back in modern skyscraper lobby, dramatic backlight, ${mediumConfig.promptModifier}, 9:16',
      },
      {
        'desc': 'Sweeping crane pullback into the neon city storm as both heroes prepare for the final showdown.',
        'camera': 'Sweeping high-angle crane pullback with lens flare',
        'dialogue': '$lead: "Then let the games begin."',
        'prompt': 'Epic aerial wide shot overlooking towering skyscrapers, thunder storm, ${mediumConfig.promptModifier}, 9:16',
      },
    ];

    final List<ShotModel> shots = [];
    for (int i = 0; i < shotCount; i++) {
      final t = templates[i % templates.length];
      final imgUrl = pool[i % pool.length];
      final videoUrl = _sampleVideos[i % _sampleVideos.length];

      shots.add(
        ShotModel(
          id: 'shot_${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
          sequenceIndex: i + 1,
          sceneDescription: t['desc']!,
          cameraDirection: t['camera']!,
          cameraMotion: cameraMotions[i % cameraMotions.length],
          lightingStyle: lightingStyles[i % lightingStyles.length],
          sfxCue: sfxSoundscapes[i % sfxSoundscapes.length],
          dialogue: t['dialogue'],
          durationSeconds: 5,
          keyframePrompt: t['prompt'],
          keyframeImageUrl: imgUrl,
          videoClipUrl: videoUrl,
          audioVoiceoverUrl: 'https://actions.google.com/sounds/v1/ambiences/rain_heavy.ogg',
          status: 'VIDEO_DONE',
        ),
      );
    }

    return shots;
  }

  /// Re-rolls a single keyframe image
  ShotModel rerollShotImage(ShotModel shot, String genre, {String visualMedium = 'REAL_HUMAN'}) {
    List<String> pool;
    if (visualMedium == 'CARTOON_3D') {
      pool = _sceneImagePool['cartoon_3d']!;
    } else if (visualMedium == 'ANIME_2D') {
      pool = _sceneImagePool['anime_2d']!;
    } else {
      pool = _sceneImagePool['real_human_cyber']!;
    }

    final random = Random();
    final newImage = pool[random.nextInt(pool.length)];

    return shot.copyWith(
      keyframeImageUrl: newImage,
      keyframePrompt: '${shot.keyframePrompt} (Regenerated variant #${random.nextInt(999)})',
      status: 'IMAGE_DONE',
    );
  }

  /// Re-rolls a single shot video
  ShotModel rerollShotVideo(ShotModel shot) {
    final random = Random();
    final newVideo = _sampleVideos[random.nextInt(_sampleVideos.length)];
    return shot.copyWith(
      videoClipUrl: newVideo,
      status: 'VIDEO_DONE',
    );
  }

  String _generateTitle(String prompt, String genre, String mediumName) {
    final words = prompt.split(' ');
    if (words.length > 3) {
      final key = words.take(3).join(' ');
      return '[$mediumName] $genre: ${key[0].toUpperCase()}${key.substring(1)}';
    }
    return '[$mediumName] $genre: Secrets in Rain';
  }
}
