import 'package:flutter/material.dart';
import '../../core/theme.dart';

class QuickGenView extends StatefulWidget {
  final Function(String prompt, String genre, String ratio) onGenerate;

  const QuickGenView({Key? key, required this.onGenerate}) : super(key: key);

  @override
  State<QuickGenView> createState() => _QuickGenViewState();
}

class _QuickGenViewState extends State<QuickGenView> {
  final TextEditingController _promptController = TextEditingController(
    text: 'A rival CEO uncovers an encrypted flash drive during a high-stakes penthouse confrontation in neon rain.',
  );

  String _selectedGenre = 'Revenge Drama';
  String _selectedAspectRatio = '9:16 (Vertical)';
  int _selectedDuration = 30;
  bool _isGenerating = false;

  final List<String> _genres = [
    'Revenge Drama',
    'Billionaire Romance',
    'Cyberpunk Thriller',
    'Secret Identity',
    'Noir Mystery',
  ];

  final List<String> _aspectRatios = [
    '9:16 (Vertical)',
    '16:9 (Cinematic)',
    '1:1 (Square)',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  'Idea in → Full Drama out',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'AI writes the 3-act script, generates shot keyframes, synthesizes video clips, and cuts with synchronized subtitles.',
                  style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Story Prompt Input
          const Text(
            'Story Idea or Premise',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _promptController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe your drama premise in one or two sentences...',
            ),
          ),
          const SizedBox(height: 20),

          // Genre selector chips
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

          // Aspect Ratio & Duration Row
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
            onPressed: _isGenerating
                ? null
                : () {
                    setState(() => _isGenerating = true);
                    widget.onGenerate(_promptController.text, _selectedGenre, _selectedAspectRatio);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isGenerating = false);
                    });
                  },
            child: _isGenerating
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      SizedBox(width: 12),
                      Text('Synthesizing Short Drama...'),
                    ],
                  )
                : const Row(
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
    );
  }
}

