import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'views/home/home_screen.dart';
import 'views/onboarding/age_gate_screen.dart';
import 'views/onboarding/consent_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DramaForgeApp());
}

class DramaForgeApp extends StatefulWidget {
  const DramaForgeApp({Key? key}) : super(key: key);

  @override
  State<DramaForgeApp> createState() => _DramaForgeAppState();
}

class _DramaForgeAppState extends State<DramaForgeApp> {
  bool _isAgeVerified = false;
  bool _hasConsented = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DramaForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _buildHomeWorkflow(),
    );
  }

  Widget _buildHomeWorkflow() {
    // 1. Mandatory 13+ Age Gate check
    if (!_isAgeVerified) {
      return AgeGateScreen(
        onVerified: () => setState(() => _isAgeVerified = true),
      );
    }

    // 2. Mandatory Pre-Transfer AI Disclosure Consent
    if (!_hasConsented) {
      return PreTransferConsentScreen(
        onConsentAccepted: () => setState(() => _hasConsented = true),
      );
    }

    // 3. Main Studio Experience
    return const HomeScreen();
  }
}

