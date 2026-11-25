import 'package:flutter/material.dart';
import '../../core/cinematic_image.dart';
import '../../core/generation_service.dart';
import '../../core/theme.dart';
import '../../models/project_model.dart';
import '../studio/character_manager_modal.dart';

class QuickGenView extends StatefulWidget {
  final Function(ProjectModel project) onProjectGenerated;

  const QuickGenView({Key? key, required this.onProjectGenerated}) : super(key: key);

  @override
  State<QuickGenView> createState() => _QuickGenViewState();
}

class _QuickGenViewState extends State<QuickGenView> {
  final TextEditingController _promptController = TextEditingController(
    text: 'A rival CEO uncovers an encrypted flash drive during a high-stakes penthouse confrontation in neon rain.',
  );

  String _selectedGenre = 'Revenge Drama';
  String _selectedVisualMedium = 'REAL_HUMAN';
  String _selectedStyle = GenerationService.cinematicStyles[0];
  String _selectedCameraMotion = GenerationService.cameraMotions[0];
  String _selectedLighting = GenerationService.lightingStyles[0];
  bool _includeAudioDubbing = true;
  String _selectedAspectRatio = '9:16 (Vertical)';
  int _selectedDuration = 30;
  bool _isGenerating = false;
  String _generationStage = '';
  double _generationProgress = 0.0;
  List<CharacterModel>? _customCharacters;

  void _magicEnhancePrompt() {
    final enhanced = GenerationService().enhancePrompt(
      _promptController.text,
      _selectedGenre,
      _selectedStyle,
      visualMedium: _selectedVisualMedium,
    );
    setState(() => _promptController.text = enhanced);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Prompt enhanced with Hollywood camera direction & lighting!'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }

  final List<String> _genres = [
    'Revenge Drama',
    'Billionaire Romance',
    'Cyberpunk Thriller',
    'Secret Identity',
    'Noir Mystery',
    'Fantasy Epic',
  ];

  final List<String> _aspectRatios = [
    '9:16 (Vertical)',
    '16:9 (Cinematic)',
    '1:1 (Square)',
  ];

  final List<Map<String, String>> _starterPrompts = [
    {
      'title': '⚡ Penthouse Heist',
      'genre': 'Revenge Drama',
      'prompt': 'A rival CEO uncovers an encrypted flash drive during a high-stakes penthouse confrontation in neon rain.',
    },
    {
      'title': '👑 Secret Billionaire',
      'genre': 'Billionaire Romance',
      'prompt': 'An undercover billionaire heiress is forced to serve her arrogant rival at a luxury masquerade gala before revealing her true power.',
    },
    {
      'title': '🤖 Cyberpunk Android',
      'genre': 'Cyberpunk Thriller',
      'prompt': 'A cybernetically augmented detective discovers the rogue AI they are tracking is built from their lost sister\'s neural memory.',
    },
    {
      'title': '🗡️ Shadow Ronin',
      'genre': 'Fantasy Epic',
      'prompt': 'An exiled swordmaster returns in stormy twilight to defend the last descendant of his clan against armored assassins.',
    },
    {
      'title': '🕵️ Undercover Double',
      'genre': 'Noir Mystery',
      'prompt': 'A streetwise con artist takes the place of a missing diplomat only to find a sniper waiting in the hotel suite.',
    },
  ];

  void _openCharacterManager() {
    final characters = _customCharacters ??
        GenerationService().analyzeCharactersFromPrompt(
          _promptController.text,
          _selectedGenre,
          visualMedium: _selectedVisualMedium,
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CharacterManagerModal(
        initialCharacters: characters,
        onSave: (updated) {
          setState(() => _customCharacters = updated);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${updated.length} character face references updated for all scenes!'),
              backgroundColor: AppTheme.primaryPurple,
            ),
          );
        },
      ),
    );
  }

  void _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _generationProgress = 0.05;
      _generationStage = 'Initializing drama engine...';
    });

    try {
      final project = await GenerationService().generateProject(
        prompt: _promptController.text,
        genre: _selectedGenre,
        aspectRatio: _selectedAspectRatio,
        durationSeconds: _selectedDuration,
        visualMedium: _selectedVisualMedium,
        customCharacters: _customCharacters,
        onProgress: (stage, progress) {
          if (mounted) {
            setState(() {
              _generationStage = stage;
              _generationProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() => _isGenerating = false);
        widget.onProjectGenerated(project);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation failed: $e'), backgroundColor: AppTheme.accentRose),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChars = _customCharacters ??
        GenerationService().analyzeCharactersFromPrompt(
          _promptController.text,
          _selectedGenre,
          visualMedium: _selectedVisualMedium,
        );

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPurple.withOpacity(0.4), AppTheme.primaryIndigo.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.goldCoin, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Flow A: One-Tap AI Short Drama',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade200,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Prompt in → Scenes, Images & Video out',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Give your video prompt. AI writes the screenplay, synthesizes gorgeous scene keyframes, and cuts synchronized video clips.',
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Visual Medium Selector (Real Human vs 3D Cartoon vs Anime vs Webtoon)
              const Text(
                'Animation & Visual Medium',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: GenerationService.visualMediums.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final vm = GenerationService.visualMediums[i];
                    final isSelected = _selectedVisualMedium == vm.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVisualMedium = vm.id;
                          _customCharacters = null; // Re-align characters to chosen medium
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryPurple.withOpacity(0.2) : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryPurple : AppTheme.surfaceBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(vm.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  vm.shortName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                ),
                                Text(
                                  vm.id == 'REAL_HUMAN' ? 'Live-Action' : 'Animated',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isSelected ? Colors.purpleAccent : Colors.white38,
                                  ),
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
              const SizedBox(height: 20),

              // Curated Prompt Starters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Inspiring Story Prompts',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  Text('Tap to load', style: TextStyle(fontSize: 11, color: Colors.white38)),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _starterPrompts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final item = _starterPrompts[i];
                    return ActionChip(
                      label: Text(item['title']!, style: const TextStyle(fontSize: 12, color: Colors.white)),
                      backgroundColor: AppTheme.surfaceCard,
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      onPressed: () {
                        setState(() {
                          _promptController.text = item['prompt']!;
                          _selectedGenre = item['genre']!;
                          _customCharacters = null; // re-analyze
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Story Prompt Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Video Story Prompt',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _magicEnhancePrompt,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primaryPurple),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 14, color: AppTheme.goldCoin),
                              SizedBox(width: 4),
                              Text('✨ Polish', style: TextStyle(fontSize: 11, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _promptController.clear(),
                        child: const Text('Clear', style: TextStyle(fontSize: 12, color: Colors.white60)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe your drama premise in one or two sentences...',
                ),
              ),
              const SizedBox(height: 16),

              // Cinematic Visual Style Selector
              const Text(
                'Cinematic Visual Style',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: GenerationService.cinematicStyles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final style = GenerationService.cinematicStyles[i];
                    final isSelected = _selectedStyle == style;

                    return ChoiceChip(
                      label: Text(style),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryPurple,
                      backgroundColor: AppTheme.surfaceCard,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedStyle = style);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Analyzed Characters Preview Card (User requested: add/assign image characters once prompt is analysed)
              Container(
                padding: const EdgeInsets.all(14),
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
                        const Row(
                          children: [
                            Icon(Icons.face_retouching_natural, size: 18, color: AppTheme.goldCoin),
                            SizedBox(width: 8),
                            Text(
                              'Character Face References',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _openCharacterManager,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Customize / Add +', style: TextStyle(fontSize: 12, color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: currentChars.map((char) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.darkBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                CinematicImage(
                                  imageUrl: char.referenceImageUrl,
                                  width: 36,
                                  height: 36,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(char.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1),
                                      Text(char.role ?? 'Lead', style: const TextStyle(fontSize: 10, color: Colors.white60), maxLines: 1),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Genre Chips
              const Text(
                'Drama Genre Presets',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _genres.map((genre) {
                  final isSelected = _selectedGenre == genre;
                  return ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryPurple,
                    backgroundColor: AppTheme.surfaceCard,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedGenre = genre);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Cinematography & Audio Director Settings
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.movie_filter_outlined, size: 18, color: AppTheme.primaryPurple),
                        SizedBox(width: 8),
                        Text('Cinematography & Audio Controls', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Camera Motion', style: TextStyle(fontSize: 11, color: Colors.white70)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedCameraMotion,
                                isDense: true,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                items: GenerationService.cameraMotions.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 11)))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedCameraMotion = v);
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
                              const Text('Atmosphere Lighting', style: TextStyle(fontSize: 11, color: Colors.white70)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedLighting,
                                isDense: true,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                items: GenerationService.lightingStyles.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 11)))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedLighting = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Switch(
                          value: _includeAudioDubbing,
                          activeColor: AppTheme.primaryPurple,
                          onChanged: (v) => setState(() => _includeAudioDubbing = v),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Synthesize AI Voice Dubbing & Foley SFX (included)',
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Aspect Ratio & Duration
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Aspect Ratio', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedAspectRatio,
                          items: _aspectRatios
                              .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedAspectRatio = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Duration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _selectedDuration,
                          items: [15, 30, 45, 60]
                              .map((d) => DropdownMenuItem(value: d, child: Text('$d seconds', style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDuration = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Button
              ElevatedButton(
                onPressed: _isGenerating ? null : _startGeneration,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.movie_creation_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Generate Short Drama'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Immersive Production Pipeline Progress Dialog
        if (_isGenerating)
          Container(
            color: Colors.black.withOpacity(0.85),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.6)),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.3), blurRadius: 24),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppTheme.goldCoin, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Forging Your Drama',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _generationStage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    LinearProgressIndicator(
                      value: _generationProgress,
                      backgroundColor: AppTheme.darkBackground,
                      color: AppTheme.primaryPurple,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(_generationProgress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.goldCoin),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
