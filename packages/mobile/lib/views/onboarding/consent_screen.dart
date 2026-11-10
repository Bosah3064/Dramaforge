import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';

class PreTransferConsentScreen extends StatefulWidget {
  final VoidCallback onConsentAccepted;

  const PreTransferConsentScreen({Key? key, required this.onConsentAccepted}) : super(key: key);

  @override
  State<PreTransferConsentScreen> createState() => _PreTransferConsentScreenState();
}

class _PreTransferConsentScreenState extends State<PreTransferConsentScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Privacy & Data Disclosure'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: AppTheme.primaryPurple, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Your creative media and prompts are processed with privacy-first standards.',
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'How Generative AI Works in DramaForge',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'To transform your ideas into short dramas, keyframe artwork, and video animation, DramaForge connects securely to leading AI providers:',
                style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Providers List
              ...AppConstants.disclosedAiProviders.map(
                (provider) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider,
                          style: const TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Divider(color: AppTheme.surfaceBorder),
              const SizedBox(height: 12),

              // Privacy commitments
              const Text(
                'Privacy Commitments:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                '• User account IDs are never transmitted to third-party AI models.\n'
                '• Temporary reference photos are automatically deleted after 30 days.\n'
                '• No user content is utilized to train public foundation models.',
                style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
              ),

              const Spacer(),

              // Agreement Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreed,
                    activeColor: AppTheme.primaryPurple,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'I acknowledge and consent to third-party AI processing for generation features.',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _agreed ? widget.onConsentAccepted : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _agreed ? AppTheme.primaryPurple : Colors.grey.shade800,
                ),
                child: const Text('Agree & Enable Studio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

