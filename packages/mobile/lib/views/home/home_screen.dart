import 'package:flutter/material.dart';
import '../../core/generation_service.dart';
import '../../core/theme.dart';
import '../../models/project_model.dart';
import '../effects/effects_screen.dart';
import '../settings/privacy_center_screen.dart';
import '../showcase/showcase_view.dart';
import '../studio/studio_screen.dart';
import '../wallet/wallet_screen.dart';
import 'quick_gen_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Default to Quick Gen (Create)
  ProjectModel? _activeProject;
  int _userCoins = 450;

  void _remixDrama(String prompt, String genre) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Remixing "$genre" drama into Studio...'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );

    final project = await GenerationService().generateProject(
      prompt: prompt,
      genre: genre,
      aspectRatio: '9:16 (Vertical)',
      durationSeconds: 30,
    );

    setState(() {
      _activeProject = project;
      _currentIndex = 2; // Jump to Studio
      _userCoins = (_userCoins - 20).clamp(0, 9999);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      ShowcaseView(onRemixPrompt: _remixDrama),
      QuickGenView(
        onProjectGenerated: (project) {
          setState(() {
            _activeProject = project;
            _currentIndex = 2; // Transition to Studio tab
            _userCoins = (_userCoins - 20).clamp(0, 9999);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ "${project.title}" generated! Inspecting in Studio.'),
              backgroundColor: AppTheme.primaryPurple,
            ),
          );
        },
      ),
      StudioScreen(
        initialProject: _activeProject,
        onProjectUpdated: (project) {
          setState(() => _activeProject = project);
        },
      ),
      const PhotoEffectsScreen(),
      const WalletScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryPurple, AppTheme.primaryIndigo]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('DF', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            const Text('DramaForge'),
          ],
        ),
        actions: [
          // Live Coin Counter
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 4),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: AppTheme.goldCoin, size: 16),
                  const SizedBox(width: 6),
                  Text('$_userCoins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ],
              ),
            ),
          ),

          // Privacy & Compliance Center Action
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: Colors.white70, size: 20),
            tooltip: 'Privacy Center & Consent',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyCenterScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceCard,
          border: Border(top: BorderSide(color: AppTheme.surfaceBorder, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primaryPurple,
          unselectedItemColor: Colors.white38,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_outlined),
              activeIcon: Icon(Icons.flash_on),
              label: 'Quick Gen',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_outlined),
              activeIcon: Icon(Icons.video_library),
              label: 'Studio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Effects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
          ],
        ),
      ),
    );
  }
}
