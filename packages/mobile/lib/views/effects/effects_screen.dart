import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PhotoEffectsScreen extends StatefulWidget {
  const PhotoEffectsScreen({Key? key}) : super(key: key);

  @override
  State<PhotoEffectsScreen> createState() => _PhotoEffectsScreenState();
}

class _PhotoEffectsScreenState extends State<PhotoEffectsScreen> {
  String _selectedEffect = 'HUG';
  bool _faceConsentChecked = false;
  bool _isRendering = false;

  final List<Map<String, dynamic>> _effects = [
    {'id': 'HUG', 'name': 'AI Hug', 'desc': 'Make 2 photos or people warmly hug', 'icon': Icons.favorite_border},
    {'id': 'KISS', 'name': 'AI Kiss', 'desc': 'Gentle, romantic cinematic embrace', 'icon': Icons.face_retouching_natural},
    {'id': 'DANCE', 'name': 'Party Dance', 'desc': 'Turn still photo into rhythm motion', 'icon': Icons.music_note},
    {'id': 'LOOK_AT_CAMERA', 'name': 'Look & Smile', 'desc': 'Subtle natural eye and head turn', 'icon': Icons.remove_red_eye_outlined},
    {'id': 'AGING', 'name': 'Time Travel (Aging)', 'desc': 'Seamless realistic age progression', 'icon': Icons.hourglass_empty},
    {'id': 'BABY_VERSION', 'name': 'Baby Face', 'desc': 'Adorable infant transformation', 'icon': Icons.child_care},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Photo Animation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Dropzone
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 40, color: AppTheme.primaryPurple),
                  const SizedBox(height: 10),
                  const Text('Upload 1 or 2 Photos to Animate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Portraits with clear faces work best', style: TextStyle(fontSize: 12, color: Colors.white60)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Select Viral Animation Effect', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // Effect Selector Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _effects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final effect = _effects[i];
                final isSelected = _selectedEffect == effect['id'];

                return GestureDetector(
                  onTap: () => setState(() => _selectedEffect = effect['id']),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryPurple.withOpacity(0.15) : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryPurple : AppTheme.surfaceBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(effect['icon'] as IconData, color: isSelected ? AppTheme.primaryPurple : Colors.white70),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(effect['name'], style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.purple.shade200 : Colors.white)),
                              const SizedBox(height: 2),
                              Text(effect['desc'], style: const TextStyle(fontSize: 11, color: Colors.white60)),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryPurple, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // MANDATORY REAL-PERSON CONSENT CHECKBOX
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentRose.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentRose.withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _faceConsentChecked,
                    activeColor: AppTheme.primaryPurple,
                    onChanged: (v) => setState(() => _faceConsentChecked = v ?? false),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'I certify that I have explicit consent from every identifiable person in this media. (Non-consensual deepfakes are strictly prohibited and result in permanent ban).',
                        style: TextStyle(fontSize: 11, color: Colors.white, height: 1.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _faceConsentChecked && !_isRendering
                  ? () {
                      setState(() => _isRendering = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Synthesizing photo animation clip (8 coins)...')),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _isRendering = false);
                      });
                    }
                  : null,
              child: _isRendering
                  ? const Text('Generating Effect Clip...')
                  : const Text('Animate Photo (8 coins)'),
            ),
          ],
        ),
      ),
    );
  }
}

