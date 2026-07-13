import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/vip_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../core/utils/helpers.dart';

class VipPlansScreen extends StatefulWidget {
  const VipPlansScreen({Key? key}) : super(key: key);

  @override
  State<VipPlansScreen> createState() => _VipPlansScreenState();
}

class _VipPlansScreenState extends State<VipPlansScreen> {
  int _selectedPlanIndex = 1; // Default to Gold

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'silver',
      'name': 'Silver VIP',
      'icon': '🥈',
      'price': '\$9.99',
      'duration': '/30 days',
      'multiplier': '3x FASTER',
      'gradient': const LinearGradient(colors: [Color(0xFFC0C0C0), Color(0xFF808080)]),
      'features': [
        '3x Coin Earning Speed',
        'Extra Daily Spin',
        '10 Scratch Cards/day',
        'Fast Withdrawal (24h)',
        'Lower Min Withdrawal (\$2)',
        'Silver VIP Badge',
      ],
    },
    {
      'id': 'gold',
      'name': 'Gold VIP',
      'icon': '🥇',
      'price': '\$19.99',
      'duration': '/30 days',
      'multiplier': '5x FASTER',
      'gradient': const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
      'features': [
        '5x Coin Earning Speed',
        'Unlimited Daily Spins',
        'Unlimited Scratch Cards',
        'Extra Mystery Boxes (5/day)',
        'Priority Withdrawal',
        'Less Ads (every 8th video)',
        'Gold VIP Badge',
      ],
      'popular': true,
    },
    {
      'id': 'platinum',
      'name': 'Platinum VIP',
      'icon': '💠',
      'price': '\$34.99',
      'duration': '/60 days',
      'multiplier': '7x FASTER',
      'gradient': const LinearGradient(colors: [Color(0xFFE5E4E2), Color(0xFFBDBDBD)]),
      'features': [
        'All Gold Features',
        '7x Coin Speed',
        'Exclusive VIP Videos',
        'No Banner Ads',
        'Priority Support',
        'Platinum Badge',
      ],
    },
    {
      'id': 'diamond',
      'name': 'Diamond VIP',
      'icon': '💎',
      'price': '\$49.99',
      'duration': '/90 days',
      'multiplier': '10x FASTER',
      'gradient': const LinearGradient(colors: [Color(0xFFB9F2FF), Color(0xFF81D4FA)]),
      'features': [
        'All Platinum Features',
        '10x Coin Speed',
        'Direct Bank Transfer',
        'Instant Withdrawal',
        'Personal Support Agent',
        'Diamond Badge',
      ],
    },
    {
      'id': 'lifetime',
      'name': 'Lifetime VIP',
      'icon': '👑',
      'price': '\$99.99',
      'duration': ' One-time',
      'multiplier': '15x FASTER',
      'gradient': AppColors.primaryGradient,
      'features': [
        'Everything Included',
        '15x Coin Speed',
        'Never Pay Again',
        'Founding Member Badge',
        'All Future Features Free',
        'Instant Withdrawal Forever',
      ],
      'bestValue': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('💎 ', style: TextStyle(fontSize: 24)),
            Text(
              'VIP Membership',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text('Earn coins up to 15x faster', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 24),
                    _buildEarnComparison(),
                    const SizedBox(height: 24),
                    _buildPlanCards(),
                    const SizedBox(height: 24),
                    _buildFAQ(),
                    const SizedBox(height: 24),
                    _buildReviews(),
                  ],
                ),
              ),
              _buildPurchaseBottomBar(context, userProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEarnComparison() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('In 1 hour of watching:', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildComparisonRow('Free User', '60', 0.2, Colors.grey),
          _buildComparisonRow('Silver VIP', '180', 0.4, const Color(0xFFC0C0C0)),
          _buildComparisonRow('Gold VIP', '300', 0.6, const Color(0xFFFFD700), isHighlighted: true),
          _buildComparisonRow('Diamond VIP', '600', 0.8, const Color(0xFF81D4FA)),
          _buildComparisonRow('Lifetime VIP', '900', 1.0, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String coins, double width, Color color, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: isHighlighted ? Colors.white : Colors.white70, fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(height: 16, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8))),
                FractionallySizedBox(
                  widthFactor: width,
                  child: Container(height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(coins, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCards() {
    return SizedBox(
      height: 480,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          final plan = _plans[index];
          final isSelected = _selectedPlanIndex == index;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedPlanIndex = index),
            child: Container(
              width: 280,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: plan['gradient'],
                borderRadius: BorderRadius.circular(24),
                border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
                boxShadow: isSelected ? [BoxShadow(color: plan['gradient'].colors.first.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)] : [],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${plan['icon']} ${plan['name']}',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, shadows: [const Shadow(blurRadius: 5)]),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(plan['price'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                              child: Text(plan['duration'], style: const TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                          child: Text(plan['multiplier'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (plan['features'] as List).length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(plan['features'][i], style: const TextStyle(color: Colors.white))),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (plan['popular'] == true)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                        child: const Text('MOST POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (plan['bestValue'] == true)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                        child: const Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurchaseBottomBar(BuildContext context, UserProvider userProvider) {
    final plan = _plans[_selectedPlanIndex];
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Consumer<VipProvider>(
            builder: (context, vipProvider, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: vipProvider.isPurchasing ? null : () async {
                      if (userProvider.user == null) return;
                      final success = await vipProvider.purchasePlan(userProvider.user!, plan['id']);
                      if (success && mounted) {
                        Helpers.showSuccessSnackbar(context, 'Welcome to ${plan['name']}!');
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.background,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: vipProvider.isPurchasing
                        ? const CircularProgressIndicator()
                        : Text(
                            'Buy ${plan['name']} for ${plan['price']}',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Subscription auto-renews. Cancel anytime.', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  TextButton(
                    onPressed: () {
                      vipProvider.restorePurchases(userProvider.user!);
                    },
                    child: const Text('Restore Purchases', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFAQ() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frequently Asked Questions', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFAQItem('Can I cancel anytime?', 'Yes, you can easily cancel your subscription anytime directly from your Play Store or App Store account settings.'),
          _buildFAQItem('How does the multiplier work?', 'Every coin you earn is multiplied automatically. For example, if a video gives 10 base coins, Gold VIP (5x) will give you 50 coins instantly!'),
          _buildFAQItem('When does VIP activate?', 'Your VIP status and all benefits are activated immediately after a successful purchase.'),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(q, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        iconColor: AppColors.primary,
        collapsedIconColor: Colors.white54,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(a, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Reviews', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildReviewCard('Michael T.', '🇺🇸', 'Gold VIP is amazing! I earn so much more now. Cashed out \$15 in just 2 weeks!'),
          _buildReviewCard('Sarah K.', '🇬🇧', 'The lifetime plan is the best investment. Already earned my money back in month 1!'),
          _buildReviewCard('David M.', '🇨🇦', 'Best earning app I\'ve used. VIP makes it so much better!'),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, String flag, String review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.white10, child: Text(name[0], style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$name $flag', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      Icon(Icons.star, color: Colors.amber, size: 12),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
