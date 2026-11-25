import 'package:flutter/material.dart';
import '../../core/cinematic_image.dart';
import '../../core/theme.dart';
import '../../models/project_model.dart';

class KeyframeViewerModal extends StatelessWidget {
  final ShotModel shot;
  final VoidCallback onRerollImage;

  const KeyframeViewerModal({
    Key? key,
    required this.shot,
    required this.onRerollImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Shot ${shot.sequenceIndex} Keyframe (8K Ultra-HD)', style: const TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.goldCoin),
            tooltip: 'Re-roll Image (2 coins)',
            onPressed: () {
              Navigator.pop(context);
              onRerollImage();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Fullscreen Keyframe with Interactive Zoom
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: Hero(
                    tag: 'keyframe_${shot.id}',
                    child: CinematicImage(
                      imageUrl: shot.keyframeImageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      placeholderText: 'Scene ${shot.sequenceIndex}',
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Scene Details Panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: const Border(top: BorderSide(color: AppTheme.surfaceBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Shot ${shot.sequenceIndex} • ${shot.durationSeconds}s',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceBorder,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            shot.cameraDirection,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Scene Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60)),
                  const SizedBox(height: 4),
                  Text(shot.sceneDescription, style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4)),
                  if (shot.dialogue != null && shot.dialogue!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Text(
                        shot.dialogue!,
                        style: const TextStyle(fontSize: 12, color: Colors.amberAccent, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onRerollImage();
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Re-roll Scene Keyframe (2 coins)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
