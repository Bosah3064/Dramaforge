import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/cinematic_image.dart';
import '../../core/theme.dart';
import '../../models/project_model.dart';

class ShotPlayerModal extends StatefulWidget {
  final ShotModel shot;
  final VoidCallback onRerollVideo;

  const ShotPlayerModal({
    Key? key,
    required this.shot,
    required this.onRerollVideo,
  }) : super(key: key);

  @override
  State<ShotPlayerModal> createState() => _ShotPlayerModalState();
}

class _ShotPlayerModalState extends State<ShotPlayerModal> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() async {
    final url = widget.shot.videoClipUrl;
    if (url != null && url.startsWith('http')) {
      try {
        final cleanUrl = url.split('#').first;
        _controller = VideoPlayerController.networkUrl(Uri.parse(cleanUrl));
        await _controller!.initialize();
        _controller!.setLooping(true);
        _controller!.play();
        if (mounted) setState(() => _isInitialized = true);
      } catch (e) {
        if (mounted) setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shot = widget.shot;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Shot ${shot.sequenceIndex} Video Preview', style: const TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.goldCoin),
            tooltip: 'Re-roll Video (8 coins)',
            onPressed: () {
              Navigator.pop(context);
              widget.onRerollVideo();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video / Animated Keyframe Area
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isInitialized && _controller != null)
                        VideoPlayer(_controller!)
                      else
                        CinematicImage(
                          imageUrl: shot.keyframeImageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),

                      // Play/Pause Overlay Button
                      if (_isInitialized && _controller != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                            });
                          },
                          child: AnimatedOpacity(
                            opacity: _controller!.value.isPlaying ? 0.0 : 0.8,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: Icon(
                                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Dialogue Subtitle Banner
                      if (shot.dialogue != null && shot.dialogue!.isNotEmpty)
                        Positioned(
                          bottom: 24,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              shot.dialogue!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Video Controls & Scene Metadata
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.videocam, size: 18, color: AppTheme.primaryPurple),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: ${shot.durationSeconds}s',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('VIDEO READY', style: TextStyle(color: AppTheme.successGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Camera Move: ${shot.cameraDirection}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onRerollVideo();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Re-roll Scene Video Clip (8 coins)'),
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
