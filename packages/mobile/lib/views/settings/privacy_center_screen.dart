import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Center & Compliance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('YOUR DATA RIGHTS (GDPR / CCPA)'),
          _buildActionTile(
            icon: Icons.download_outlined,
            title: 'Export My Data',
            subtitle: 'Download a JSON archive of your projects, scripts, and transactions',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preparing data export archive...')),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildActionTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete My Account',
            subtitle: 'Permanently erase your account, media, and coin ledger',
            isDestructive: true,
            onTap: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('AI SAFETY & THIRD-PARTY DISCLOSURES'),
          _buildInfoTile(
            title: 'Pre-Transfer AI Consent',
            status: 'Active (v2026.1)',
            desc: 'Prompts dispatched to OpenAI, Google Veo, and BytePlus without user account IDs.',
          ),
          const SizedBox(height: 10),
          _buildInfoTile(
            title: '30-Day Retention Cleaner',
            status: 'Enforced',
            desc: 'Uploaded reference face photos and working drafts are automatically swept after 30 days.',
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('LEGAL & TERMS'),
          _buildActionTile(
            icon: Icons.description_outlined,
            title: 'Terms of Use',
            subtitle: 'Fair use, coin economy rules, and prohibited content policies',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our zero-training commitment and compliance guidelines',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white60),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDestructive ? Colors.rose.shade900 : AppTheme.surfaceBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? AppTheme.accentRose : AppTheme.primaryPurple),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDestructive ? AppTheme.accentRose : Colors.white, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String status,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.successGreen, width: 0.5),
                ),
                child: Text(status, style: const TextStyle(fontSize: 10, color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.4)),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Delete Account Permanently?', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'This action is irreversible. All generated short-dramas, photo animations, and unconsumed coins will be permanently erased.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion request submitted.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRose),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}
