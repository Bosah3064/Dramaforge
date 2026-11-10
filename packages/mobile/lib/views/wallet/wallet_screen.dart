import 'package:flutter/material.dart';
import '../../core/theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Wallet & Plans'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchases restored successfully.')),
              );
            },
            child: const Text('Restore', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dual-Bucket Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade900, Colors.indigo.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.purple.shade900.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  const Text('TOTAL BALANCE', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.monetization_on, color: AppTheme.goldCoin, size: 36),
                      SizedBox(width: 8),
                      Text('450', style: TextStyle(fontSize: 40, fontWeight: FontWeight.black, color: Colors.white)),
                      SizedBox(width: 4),
                      Text('coins', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),

                  // Dual-Bucket Breakdown
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Subscription Coins', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            SizedBox(height: 2),
                            Text('250', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 2),
                            Text('Expires in 18 days', style: TextStyle(fontSize: 10, color: Colors.amberAccent)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Purchased Coins', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            SizedBox(height: 2),
                            Text('200', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                            SizedBox(height: 2),
                            Text('Never expire (Safe)', style: TextStyle(fontSize: 10, color: Colors.white60)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ordering & Refund Invariant Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppTheme.primaryPurple),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Subscription coins are consumed first. All technical errors or model rejections are automatically refunded to your coin ledger.',
                      style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pro Membership Plans
            const Text('Pro Creator Subscriptions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            _buildPlanCard(
              title: 'Pro Monthly (Best Value)',
              price: '\$19.99 / month',
              coins: '700 coins / month',
              features: ['Zero Watermark on all exports', 'Priority rendering queue', 'Full 4-Stage Studio access'],
              isPopular: true,
            ),
            const SizedBox(height: 12),

            _buildPlanCard(
              title: 'Pro Weekly',
              price: '\$6.99 / week',
              coins: '150 coins / week',
              features: ['Unwatermarked exports', '4-Stage Studio access'],
              isPopular: false,
            ),
            const SizedBox(height: 24),

            // Non-Expiring Coin Packs
            const Text('Consumable Coin Packs (Never Expire)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            Row(
              children: [
                _buildPackPill('100 Coins', '\$2.99'),
                const SizedBox(width: 10),
                _buildPackPill('350 Coins', '\$8.99'),
                const SizedBox(width: 10),
                _buildPackPill('1,000 Coins', '\$22.99'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String coins,
    required List<String> features,
    required bool isPopular,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPopular ? AppTheme.primaryPurple.withOpacity(0.12) : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPopular ? AppTheme.primaryPurple : AppTheme.surfaceBorder,
          width: isPopular ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldCoin, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(coins, style: const TextStyle(fontSize: 12, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 14, color: AppTheme.successGreen),
                  const SizedBox(width: 6),
                  Text(f, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            child: const Text('Subscribe Now', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPackPill(String title, String price) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.monetization_on_outlined, color: AppTheme.goldCoin, size: 20),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

