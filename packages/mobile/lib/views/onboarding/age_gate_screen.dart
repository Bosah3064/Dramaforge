import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AgeGateScreen extends StatefulWidget {
  final VoidCallback onVerified;

  const AgeGateScreen({Key? key, required this.onVerified}) : super(key: key);

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  bool _isConfirmed = false;
  DateTime? _selectedBirthDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryPurple, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: AppTheme.primaryPurple,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to DramaForge',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Before creating short-dramas and animating media, please verify your age. In accordance with digital safety policies, you must be 13 years or older.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Confirmation Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isConfirmed,
                      activeColor: AppTheme.primaryPurple,
                      onChanged: (val) {
                        setState(() {
                          _isConfirmed = val ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I certify that I am at least 13 years old and agree to the Terms of Service.',
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: _isConfirmed ? widget.onVerified : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConfirmed ? AppTheme.primaryPurple : Colors.grey.shade800,
                ),
                child: const Text('Continue to Studio'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

