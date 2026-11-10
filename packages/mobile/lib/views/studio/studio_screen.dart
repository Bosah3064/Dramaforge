import 'package:flutter/material.dart';
import '../../core/theme.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({Key? key}) : super(key: key);

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  int _currentStage = 1; // 1: Story, 2: Storyboard, 3: Shots, 4: Final Cut

  // Demo Shots State
  final List<Map<String, dynamic>> _shots = [
    {
      'index': 1,
      'title': 'Shot 1: Rain-slicked Penthouse Window',
      'camera': 'Wide tracking forward',
      'dialogue': 'Elena: You thought you buried the prototype data, Marcus.',
      'status': 'VIDEO_DONE',
    },
    {
      'index': 2,
      'title': 'Shot 2: Elena Steps Forward',
      'camera': 'Medium low-angle push-in',
      'dialogue': 'Elena: Paper trails don\'t vanish into thin air.',
      'status': 'VIDEO_DONE',
    },
    {
      'index': 3,
      'title': 'Shot 3: Marcus Turns Around',
      'camera': 'Tight over-the-shoulder close-up',
      'dialogue': 'Marcus: What makes you think you\'re holding leverage?',
      'status': 'VIDEO_DONE',
    },
    {
      'index': 4,
      'title': 'Shot 4: Encrypted Flash Drive Slide',
      'camera': 'Dynamic dutch-angle close-up',
      'dialogue': 'Elena: Your board betrayed you first.',
      'status': 'IMAGE_DONE',
    },
    {
      'index': 5,
      'title': 'Shot 5: Alliance Sealed',
      'camera': 'Two-shot profile freeze-frame',
      'dialogue': 'Marcus: We take the entire empire back.',
      'status': 'PENDING',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DramaForge Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 4-Stage Progress Stepper Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceCard,
              border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStagePill(1, 'Story'),
                _buildStageDivider(),
                _buildStagePill(2, 'Storyboard'),
                _buildStageDivider(),
                _buildStagePill(3, 'Shots'),
                _buildStageDivider(),
                _buildStagePill(4, 'Final Cut'),
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
      onTap: () => setState(() => _currentStage = stage),
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isDone
                ? AppTheme.successGreen
                : isActive
                    ? AppTheme.primaryPurple
                    : Colors.slate.shade800,
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
    return Container(width: 24, height: 1, color: AppTheme.surfaceBorder);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('3-Act Script & Character Profiles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: const SingleChildScrollView(
              child: Text(
                'ACT I: THE INFILTRATION\n'
                'Scene 1: Marcus\'s high-rise penthouse office overlooking neon city rain.\n'
                'ELENA: "You thought you buried the prototype data, Marcus. But paper trails don\'t vanish into thin air."\n'
                'MARCUS: (Smiles without turning) "You walked through five security checkpoints, Elena. What makes you think you\'re holding leverage?"\n\n'
                'ACT II: THE REVELATION\n'
                'Scene 2: Thunder rumbles outside floor-to-ceiling glass.\n'
                'ELENA: "This wasn\'t an accident. Your board betrayed you first."\n'
                'MARCUS: (Turns slowly, eyes hardening) "Then it seems we share an enemy."\n\n'
                'ACT III: THE ALLIANCE\n'
                'Scene 3: Sirens echo far below.\n'
                'ELENA: "So do we run, or do we expose them together?"\n'
                'MARCUS: "We take the entire empire back."',
                style: TextStyle(fontSize: 13, height: 1.6, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => setState(() => _currentStage = 2),
          child: const Text('Proceed to Storyboard (2 coins/shot)'),
        ),
      ],
    );
  }

  Widget _buildStoryboardStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            const Text('Storyboard Keyframe Grid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${_shots.length} Shots Planned', style: const TextStyle(fontSize: 12, color: Colors.white60)),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: _shots.length,
            itemBuilder: (context, i) {
              final shot = _shots[i];
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.slate.shade900,
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade900, Colors.indigo.shade900],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.movie_outlined, size: 36, color: Colors.white.withOpacity(0.6)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(shot['title'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1),
                    const SizedBox(height: 4),
                    Text(shot['camera'], style: const TextStyle(fontSize: 11, color: Colors.white60), maxLines: 1),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => setState(() => _currentStage = 3),
          child: const Text('Render Shot Videos (8 coins/shot)'),
        ),
      ],
    );
  }

  Widget _buildShotsStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Shot Video Synthesis & Regeneration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _shots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final shot = _shots[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade900,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('${shot['index']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shot['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(shot['dialogue'], style: const TextStyle(fontSize: 11, color: Colors.white70), maxLines: 2),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Granular Re-roll Button
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Regenerating Shot ${shot['index']} (8 coins)...')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryPurple),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      child: const Text('Re-roll', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => setState(() => _currentStage = 4),
          child: const Text('Assemble Final Cut'),
        ),
      ],
    );
  }

  Widget _buildFinalCutStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Final Cut & Subtitle Synchronization', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.play_circle_fill, size: 64, color: AppTheme.primaryPurple),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'MARCUS: "We take the entire empire back."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Export 720p (Free)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Export 1080p (Clean)'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

