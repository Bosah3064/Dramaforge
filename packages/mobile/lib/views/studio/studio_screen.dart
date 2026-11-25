import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/cinematic_image.dart';
import '../../core/generation_service.dart';
import '../../core/theme.dart';
import '../../models/project_model.dart';
import 'character_manager_modal.dart';
import 'keyframe_viewer_modal.dart';
import 'shot_player_modal.dart';

class StudioScreen extends StatefulWidget {
  final ProjectModel? initialProject;
  final Function(ProjectModel project)? onProjectUpdated;

  const StudioScreen({
    Key? key,
    this.initialProject,
    this.onProjectUpdated,
  }) : super(key: key);

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  int _currentStage = 1; // 1: Story & Voice, 2: Storyboard & LUTs, 3: Shots & SFX, 4: Master Final Cut
  late ProjectModel _project;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isMuted = false;
  bool _isVerticalFrame = true;
  String _selectedSubtitleStyle = '🟡 Karaoke Gold';
  String _selectedBgm = '🎻 Epic Orchestral';
  String _selectedLut = '🎬 Hollywood 70mm';

  final List<String> _subtitleStyles = [
    '🟡 Karaoke Gold',
    '⚪ Clean White',
    '🟢 Neon Cyber',
  ];

  final List<String> _bgmTracks = [
    '🎻 Epic Orchestral',
    '⚡ Cyber Synthwave',
    '🎹 Emotional Piano',
    '🥁 Suspense Thriller',
  ];

  final List<String> _lutFilters = [
    '🎬 Hollywood 70mm',
    '🌆 Cyber Neon',
    '🖤 Noir B&W',
    '🌿 Emerald Gold',
    '⚡ Bleach Bypass',
  ];

  @override
  void initState() {
    super.initState();
    _project = widget.initialProject ?? _createDefaultProject();
    _initFinalCutVideo();
  }

  @override
  void didUpdateWidget(covariant StudioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialProject != null && widget.initialProject!.id != _project.id) {
      setState(() {
        _project = widget.initialProject!;
        _currentStage = 2; // Jump to Storyboard so user sees generated images immediately
      });
      _initFinalCutVideo();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initFinalCutVideo() async {
    final url = _project.finalVideoUrl ?? (_currentStory.shots.isNotEmpty ? _currentStory.shots[0].videoClipUrl : null);
    if (url != null && url.startsWith('http')) {
      try {
        _videoController?.dispose();
        final cleanUrl = url.split('#').first;
        _videoController = VideoPlayerController.networkUrl(Uri.parse(cleanUrl));
        await _videoController!.initialize();
        _videoController!.setLooping(true);
        _videoController!.addListener(() {
          if (mounted) setState(() {});
        });
        if (mounted) setState(() => _isVideoInitialized = true);
      } catch (e) {
        if (mounted) setState(() => _isVideoInitialized = false);
      }
    }
  }

  ProjectModel _createDefaultProject() {
    final characters = GenerationService().analyzeCharactersFromPrompt(
      'A rival CEO uncovers an encrypted flash drive during a high-stakes penthouse confrontation in neon rain',
      'Revenge Drama',
    );

    final shots = [
      ShotModel(
        id: 'shot_1',
        sequenceIndex: 1,
        sceneDescription: 'Atmospheric wide establishing shot. Rain streaks across panoramic glass with neon reflections silhouetting Marcus.',
        cameraDirection: 'Wide establishing tracking shot forward',
        cameraMotion: 'Dynamic Push-in',
        lightingStyle: 'Volumetric Neon Cyberpunk',
        sfxCue: 'Rain on glass & distant thunder',
        dialogue: 'Elena: "You thought nobody would ever trace this back to you, Marcus."',
        durationSeconds: 5,
        keyframePrompt: 'Cinematic wide establishing shot of luxury dark penthouse interior, neon rain reflections, volumetric lighting, 9:16',
        keyframeImageUrl: 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?auto=format&fit=crop&w=900&q=80',
        videoClipUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        audioVoiceoverUrl: 'https://actions.google.com/sounds/v1/ambiences/rain_heavy.ogg',
        status: 'VIDEO_DONE',
      ),
      ShotModel(
        id: 'shot_2',
        sequenceIndex: 2,
        sceneDescription: 'Elena steps out of deep ambient shadows into sharp rim light, holding glowing proof.',
        cameraDirection: 'Medium low-angle push-in on Elena, high contrast lighting',
        cameraMotion: 'Low-angle Tracking',
        lightingStyle: 'Moody Rainy Film Noir',
        sfxCue: 'Muffled footsteps on marble',
        dialogue: 'Elena: "Every secret leaves a scar, no matter how deep you bury it."',
        durationSeconds: 5,
        keyframePrompt: 'Medium portrait of determined character holding glowing device in dark modern room, dramatic rim lighting, 9:16',
        keyframeImageUrl: 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=900&q=80',
        videoClipUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        audioVoiceoverUrl: 'https://actions.google.com/sounds/v1/ambiences/rain_heavy.ogg',
        status: 'VIDEO_DONE',
      ),
      ShotModel(
        id: 'shot_3',
        sequenceIndex: 3,
        sceneDescription: 'Marcus turns slowly, intense gaze locking across the dark polished table.',
        cameraDirection: 'Tight over-the-shoulder close-up shifting focus to Marcus',
        cameraMotion: 'Sweeping 360 Orbit',
        lightingStyle: 'High-Key Luxury Glamour',
        sfxCue: 'Ice clinking in tumbler',
        dialogue: 'Marcus: "What makes you think you\'re walking out of here alive?"',
        durationSeconds: 5,
        keyframePrompt: 'Tight intense cinematic close-up portrait of powerful rival, piercing eyes, cinematic backlight, 9:16',
        keyframeImageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=900&q=80',
        videoClipUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        audioVoiceoverUrl: 'https://actions.google.com/sounds/v1/ambiences/rain_heavy.ogg',
        status: 'VIDEO_DONE',
      ),
      ShotModel(
        id: 'shot_4',
        sequenceIndex: 4,
        sceneDescription: 'Flash of lightning illumination. The encrypted drive slides across black obsidian table.',
        cameraDirection: 'Dynamic Dutch-angle macro push on sliding drive with blue LED glow',
        cameraMotion: 'Dutch Angle Snap Zoom',
        lightingStyle: 'Volumetric Neon Cyberpunk',
        sfxCue: 'Metallic drive slide & electric hum',
        dialogue: 'Elena: "Look at the records. Your board marked you first."',
        durationSeconds: 5,
        keyframePrompt: 'Extreme macro close-up of encrypted metallic drive sliding across black reflective table, electric sparks, 9:16',
        keyframeImageUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=900&q=80',
        videoClipUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
        audioVoiceoverUrl: 'https://actions.google.com/sounds/v1/ambiences/rain_heavy.ogg',
        status: 'VIDEO_DONE',
      ),
      ShotModel(
        id: 'shot_5',
        sequenceIndex: 5,
        sceneDescription: 'Elena and Marcus stand back-to-back as shadows approach in the corridor, sealing their alliance.',
        cameraDirection: 'Two-shot profile freeze-frame with sirens wailing in ambient rain',
        cameraMotion: 'Aerial Crane Pullback',
        lightingStyle: 'Golden Hour Anamorphic Flare',
        sfxCue: 'Elevator chime & tactical footsteps',
        dialogue: 'Marcus: "We take the entire empire back."',
        durationSeconds: 5,
        keyframePrompt: 'Two cinematic characters standing back-to-back in modern skyscraper lobby, dramatic backlight, volumetric dust, 9:16',
        keyframeImageUrl: 'https://images.unsplash.com/photo-1515260268569-9271009adfdb?auto=format&fit=crop&w=900&q=80',
        videoClipUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        audioVoiceoverUrl: 'https://actions.google.com/sounds/v1/ambiences/rain_heavy.ogg',
        status: 'VIDEO_DONE',
      ),
    ];

    final story = StoryModel(
      id: 'story_default',
      synopsis: 'When investigative reporter Elena Vance uncovers a covert takeover orchestrated by CEO Marcus Sterling, a tense confrontation in a rainy penthouse leads to an alliance neither anticipated.',
      genre: 'Revenge Drama',
      scriptText: '''ACT I: THE INFILTRATION
Scene 1: Marcus's high-rise penthouse office overlooking neon city rain.
ELENA: "You thought you buried the prototype data, Marcus. But paper trails don't vanish into thin air."
MARCUS: (Smiles without turning) "You walked through five security checkpoints, Elena. What makes you think you're holding leverage?"

ACT II: THE REVELATION
Scene 2: Thunder rumbles outside floor-to-ceiling glass.
ELENA: "This wasn't an accident. Your board betrayed you first."
MARCUS: (Turns slowly, eyes hardening) "Then it seems we share an enemy."

ACT III: THE ALLIANCE
Scene 3: Sirens echo far below.
ELENA: "So do we run, or do we expose them together?"
MARCUS: "We take the entire empire back."''',
      characters: characters,
      shots: shots,
    );

    return ProjectModel(
      id: 'proj_default',
      title: 'Revenge Drama: Secrets in Rain',
      mode: 'STUDIO',
      aspectRatio: 'PORTRAIT_9_16',
      status: 'COMPLETED',
      finalVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      stories: [story],
    );
  }

  StoryModel get _currentStory => _project.stories.isNotEmpty ? _project.stories[0] : StoryModel(id: '', synopsis: '', scriptText: '', shots: []);

  void _openCharacterManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CharacterManagerModal(
        initialCharacters: _currentStory.characters,
        onSave: (updated) {
          final updatedStory = _currentStory.copyWith(characters: updated);
          final updatedProject = _project.copyWith(stories: [updatedStory]);
          setState(() => _project = updatedProject);
          widget.onProjectUpdated?.call(updatedProject);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Character faces applied across all scenes!'), backgroundColor: AppTheme.primaryPurple),
          );
        },
      ),
    );
  }

  void _openVoiceSelector(CharacterModel character, int charIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Assign Voice Actor: ${character.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white60), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Select an AI Voice Persona for dialogue dubbing and speech synthesis.', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 16),
              ...GenerationService.voicePersonas.map((vp) {
                final isSelected = (character.voicePersona ?? '').contains(vp.name);
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: isSelected ? AppTheme.primaryPurple.withOpacity(0.2) : AppTheme.surfaceCard,
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppTheme.primaryPurple : AppTheme.surfaceBorder,
                    child: const Icon(Icons.mic, size: 18, color: Colors.white),
                  ),
                  title: Text(vp.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  subtitle: Text(vp.title, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.goldCoin, size: 20) : null,
                  onTap: () {
                    final updatedChar = character.copyWith(
                      voicePersona: '${vp.name} (${vp.title})',
                      voiceId: vp.id,
                    );
                    final updatedChars = List<CharacterModel>.from(_currentStory.characters);
                    updatedChars[charIndex] = updatedChar;
                    final updatedStory = _currentStory.copyWith(characters: updatedChars);
                    final updatedProject = _project.copyWith(stories: [updatedStory]);

                    setState(() => _project = updatedProject);
                    widget.onProjectUpdated?.call(updatedProject);
                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Voice Persona "${vp.name}" assigned to ${character.name}!'), backgroundColor: AppTheme.primaryPurple),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showNewPromptModal() {
    final promptCtrl = TextEditingController();
    String genre = 'Revenge Drama';
    String visualMedium = _project.visualMedium ?? 'REAL_HUMAN';
    int duration = 30;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('New Video Prompt in Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white60), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: promptCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Enter your short drama idea or premise...'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Animation & Visual Style', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: GenerationService.visualMediums.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final vm = GenerationService.visualMediums[i];
                        final isSelected = visualMedium == vm.id;
                        return ChoiceChip(
                          label: Text('${vm.icon} ${vm.shortName}'),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryPurple,
                          backgroundColor: AppTheme.surfaceCard,
                          labelStyle: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.white70),
                          onSelected: (val) {
                            if (val) setModalState(() => visualMedium = vm.id);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Forging new scenes, keyframe images and video...'), backgroundColor: AppTheme.primaryPurple),
                      );

                      final newProject = await GenerationService().generateProject(
                        prompt: promptCtrl.text,
                        genre: genre,
                        aspectRatio: '9:16 (Vertical)',
                        durationSeconds: duration,
                        visualMedium: visualMedium,
                      );

                      setState(() {
                        _project = newProject;
                        _currentStage = 2; // jump to storyboard
                      });
                      widget.onProjectUpdated?.call(newProject);
                      _initFinalCutVideo();
                    },
                    child: const Text('Generate New Project'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _rerollShotImage(ShotModel shot) {
    final updatedShot = GenerationService().rerollShotImage(
      shot,
      _currentStory.genre,
      visualMedium: _project.visualMedium ?? 'REAL_HUMAN',
    );
    final updatedShots = _currentStory.shots.map((s) => s.id == shot.id ? updatedShot : s).toList();
    final updatedStory = _currentStory.copyWith(shots: updatedShots);
    final updatedProject = _project.copyWith(stories: [updatedStory]);

    setState(() => _project = updatedProject);
    widget.onProjectUpdated?.call(updatedProject);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shot ${shot.sequenceIndex} keyframe image regenerated (2 coins).'), backgroundColor: AppTheme.primaryPurple),
    );
  }

  void _rerollShotVideo(ShotModel shot) {
    final updatedShot = GenerationService().rerollShotVideo(shot);
    final updatedShots = _currentStory.shots.map((s) => s.id == shot.id ? updatedShot : s).toList();
    final updatedStory = _currentStory.copyWith(shots: updatedShots);
    final updatedProject = _project.copyWith(stories: [updatedStory]);

    setState(() => _project = updatedProject);
    widget.onProjectUpdated?.call(updatedProject);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shot ${shot.sequenceIndex} video re-synthesized (8 coins).'), backgroundColor: AppTheme.primaryPurple),
    );
  }

  Widget _buildLutOverlay() {
    switch (_selectedLut) {
      case '🎬 Hollywood 70mm':
        return Container(color: const Color(0xFFD97706).withOpacity(0.08));
      case '🌆 Cyber Neon':
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.withOpacity(0.12), Colors.cyan.withOpacity(0.12)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      case '🖤 Noir B&W':
        return Container(color: Colors.black.withOpacity(0.20));
      case '🌿 Emerald Gold':
        return Container(color: const Color(0xFF059669).withOpacity(0.08));
      case '⚡ Bleach Bypass':
        return Container(color: const Color(0xFF3B82F6).withOpacity(0.08));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('DramaForge Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(_project.title, style: const TextStyle(fontSize: 11, color: Colors.white60), maxLines: 1),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryPurple),
            tooltip: 'New Prompt',
            onPressed: _showNewPromptModal,
          ),
          IconButton(
            icon: const Icon(Icons.face_retouching_natural, color: AppTheme.goldCoin),
            tooltip: 'Character Faces',
            onPressed: _openCharacterManager,
          ),
        ],
      ),
      body: Column(
        children: [
          // 4-Stage Stepper Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceCard,
              border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStagePill(1, 'Story & Voices'),
                _buildStageDivider(),
                _buildStagePill(2, 'Images & LUTs'),
                _buildStageDivider(),
                _buildStagePill(3, 'Videos & SFX'),
                _buildStageDivider(),
                _buildStagePill(4, 'Master Cut'),
              ],
            ),
          ),

          // Stage Content View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCurrentStageView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStagePill(int stage, String label) {
    final isActive = _currentStage == stage;
    final isDone = _currentStage > stage;

    return GestureDetector(
      onTap: () {
        setState(() => _currentStage = stage);
        if (stage == 4) _initFinalCutVideo();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isDone
                ? AppTheme.successGreen
                : isActive
                    ? AppTheme.primaryPurple
                    : AppTheme.surfaceCard,
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text('$stage', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.white : Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageDivider() {
    return Container(width: 16, height: 1, color: AppTheme.surfaceBorder);
  }

  Widget _buildCurrentStageView() {
    switch (_currentStage) {
      case 1:
        return _buildStoryStage();
      case 2:
        return _buildStoryboardStage();
      case 3:
        return _buildShotsStage();
      case 4:
        return _buildFinalCutStage();
      default:
        return Container();
    }
  }

  Widget _buildStoryStage() {
    final story = _currentStory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Character Faces & Voice Personas
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Character Visuals & Voice Dubbing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  GestureDetector(
                    onTap: _openCharacterManager,
                    child: const Text('Edit Cast +', style: TextStyle(fontSize: 12, color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: story.characters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final char = story.characters[i];
                    return GestureDetector(
                      onTap: () => _openVoiceSelector(char, i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.darkBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            CinematicImage(
                              imageUrl: char.referenceImageUrl,
                              width: 44,
                              height: 44,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(char.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.mic, size: 10, color: AppTheme.goldCoin),
                                    const SizedBox(width: 2),
                                    Text(
                                      char.voicePersona ?? 'Adam (Deep Titan)',
                                      style: const TextStyle(fontSize: 10, color: Colors.purpleAccent, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Text('3-Act Screenplay & Dialogue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Logline: ${story.synopsis}',
                      style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    story.scriptText,
                    style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        ElevatedButton(
          onPressed: () => setState(() => _currentStage = 2),
          child: Text('Proceed to Keyframe Images (${story.shots.length} shots)'),
        ),
      ],
    );
  }

  Widget _buildStoryboardStage() {
    final story = _currentStory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LUT Filter Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Color Grading & Visual LUT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
            Text('${story.shots.length} Scenes', style: const TextStyle(fontSize: 11, color: AppTheme.goldCoin, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _lutFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final lut = _lutFilters[i];
              final isSelected = _selectedLut == lut;
              return ChoiceChip(
                label: Text(lut),
                selected: isSelected,
                selectedColor: AppTheme.primaryPurple,
                backgroundColor: AppTheme.surfaceCard,
                labelStyle: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedLut = lut);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Grid of Keyframe Images ("nice images")
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: story.shots.length,
            itemBuilder: (context, i) {
              final shot = story.shots[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KeyframeViewerModal(
                        shot: shot,
                        onRerollImage: () => _rerollShotImage(shot),
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Keyframe Image with Badges & LUT Overlay
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: 'keyframe_${shot.id}',
                              child: CinematicImage(
                                imageUrl: shot.keyframeImageUrl,
                                fit: BoxFit.cover,
                                placeholderText: 'Shot ${shot.sequenceIndex}',
                              ),
                            ),
                            // Live LUT Overlay
                            _buildLutOverlay(),
                            // Gradient Vignette
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.8)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Shot Sequence Badge
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text('Scene ${shot.sequenceIndex}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                            // Re-roll button
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _rerollShotImage(shot),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.refresh, size: 14, color: AppTheme.goldCoin),
                                ),
                              ),
                            ),
                            // Camera Motion Tag
                            Positioned(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPurple.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  shot.cameraMotion ?? shot.cameraDirection,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          shot.dialogue ?? shot.sceneDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        ElevatedButton(
          onPressed: () => setState(() => _currentStage = 3),
          child: const Text('Proceed to Scene Videos & SFX'),
        ),
      ],
    );
  }

  Widget _buildShotsStage() {
    final story = _currentStory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Scene Videos & Foley SFX ("videos")', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${story.shots.length} Clips Ready', style: const TextStyle(fontSize: 12, color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),

        // List of video clips
        Expanded(
          child: ListView.separated(
            itemCount: story.shots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final shot = story.shots[i];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    // Video Thumbnail with Play Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShotPlayerModal(
                              shot: shot,
                              onRerollVideo: () => _rerollShotVideo(shot),
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CinematicImage(
                            imageUrl: shot.keyframeImageUrl,
                            width: 68,
                            height: 68,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(Icons.play_arrow, size: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Scene ${shot.sequenceIndex}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('${shot.durationSeconds}s', style: const TextStyle(fontSize: 10, color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(shot.dialogue ?? shot.sceneDescription, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.graphic_eq, size: 12, color: AppTheme.goldCoin),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  shot.sfxCue ?? 'Atmospheric tension',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, color: Colors.amberAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _rerollShotVideo(shot),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryPurple),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: const Text('Re-roll', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        ElevatedButton(
          onPressed: () {
            setState(() => _currentStage = 4);
            _initFinalCutVideo();
          },
          child: const Text('Assemble Master Final Cut'),
        ),
      ],
    );
  }

  Widget _buildFinalCutStage() {
    final story = _currentStory;
    final totalDuration = story.shots.fold<int>(0, (acc, s) => acc + s.durationSeconds);

    final position = _videoController?.value.position ?? Duration.zero;
    final totalDurationTime = _videoController?.value.duration ?? Duration(seconds: totalDuration > 0 ? totalDuration : 25);
    final isPlaying = _videoController?.value.isPlaying ?? false;

    final currentSec = position.inSeconds;
    final totalSec = totalDurationTime.inSeconds > 0 ? totalDurationTime.inSeconds : (totalDuration > 0 ? totalDuration : 25);

    // Current subtitle determined by real video position
    final currentShotIndex = ((currentSec / (totalSec > 0 ? totalSec : 25)) * story.shots.length).clamp(0, story.shots.length - 1).toInt();
    final currentDialogue = story.shots.isNotEmpty ? (story.shots[currentShotIndex].dialogue ?? story.shots[currentShotIndex].sceneDescription) : '';
    final currentSfx = story.shots.isNotEmpty ? (story.shots[currentShotIndex].sfxCue ?? 'Atmospheric ambience') : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Master Drama Video Player', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            Row(
              children: [
                IconButton(
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, size: 20, color: Colors.white70),
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                      _videoController?.setVolume(_isMuted ? 0.0 : 1.0);
                    });
                  },
                ),
                GestureDetector(
                  onTap: () => setState(() => _isVerticalFrame = !_isVerticalFrame),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Text(
                      _isVerticalFrame ? '9:16 Vertical' : '16:9 Widescreen',
                      style: const TextStyle(fontSize: 11, color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Real Interactive Video Player Box
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _isVerticalFrame ? 9 / 16 : 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.6)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Video Stream or Fallback
                    if (_isVideoInitialized && _videoController != null)
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      )
                    else
                      CinematicImage(
                        imageUrl: story.shots.isNotEmpty ? story.shots[currentShotIndex].keyframeImageUrl : null,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),

                    // Color Grading LUT Filter Overlay
                    _buildLutOverlay(),

                    // Play/Pause Overlay Tap
                    GestureDetector(
                      onTap: () {
                        if (_videoController != null && _isVideoInitialized) {
                          setState(() {
                            isPlaying ? _videoController!.pause() : _videoController!.play();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black45,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 54,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Live Soundscape / SFX Cue Badge
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.graphic_eq, size: 12, color: AppTheme.goldCoin),
                            const SizedBox(width: 6),
                            Text('SFX: $currentSfx', style: const TextStyle(fontSize: 10, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                    // Live Synchronized Subtitles
                    if (currentDialogue.isNotEmpty)
                      Positioned(
                        bottom: 40,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedSubtitleStyle.contains('Neon')
                                  ? const Color(0xFF10B981)
                                  : Colors.white24,
                            ),
                          ),
                          child: Text(
                            currentDialogue,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _selectedSubtitleStyle.contains('White')
                                  ? Colors.white
                                  : _selectedSubtitleStyle.contains('Neon')
                                      ? const Color(0xFF10B981)
                                      : Colors.yellow,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Video Scrubbing Timeline Bar
                    Positioned(
                      bottom: 8,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Text('00:${currentSec.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: Colors.white)),
                          Expanded(
                            child: Slider(
                              value: currentSec.toDouble().clamp(0.0, totalSec.toDouble()),
                              min: 0.0,
                              max: totalSec > 0 ? totalSec.toDouble() : 25.0,
                              activeColor: AppTheme.primaryPurple,
                              inactiveColor: Colors.white24,
                              onChanged: (v) {
                                if (_videoController != null && _isVideoInitialized) {
                                  _videoController!.seekTo(Duration(seconds: v.toInt()));
                                }
                              },
                            ),
                          ),
                          Text('00:${totalSec.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle Style & BGM Soundtrack Selectors
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Subtitle Style', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _selectedSubtitleStyle,
                    isDense: true,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: _subtitleStyles.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedSubtitleStyle = v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BGM Soundtrack', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _selectedBgm,
                    isDense: true,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: _bgmTracks.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 11)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedBgm = v);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Export Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting 720p HD with DramaForge watermark...'), backgroundColor: AppTheme.primaryPurple),
                  );
                },
                child: const Text('Export 720p (Free)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting 1080p Ultra-HD Clean with Audio Master...'), backgroundColor: AppTheme.successGreen),
                  );
                },
                child: const Text('Export 1080p (Clean)'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
