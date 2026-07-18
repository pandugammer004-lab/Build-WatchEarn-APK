import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/streak_calendar.dart';
import '../../core/widgets/banner_ad_widget.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/ad_provider.dart';
import '../../data/providers/coin_provider.dart';
import '../../core/widgets/coin_earned_animation.dart';

import 'package:share_plus/share_plus.dart' as share_pkg;
import 'spin_wheel_screen.dart';
import 'scratch_card_screen.dart';
import 'mystery_box_screen.dart';
import 'daily_goals_screen.dart';

class EarnScreen extends StatelessWidget {
  const EarnScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text('💰 ', style: TextStyle(fontSize: 24)),
            Text(
              'Earn Center',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSubtitle(),
            const SizedBox(height: 24),
            
            _buildDailyBonus(context),
            const SizedBox(height: 24),
            
            _buildStreakCalendar(),
            const SizedBox(height: 24),
            
            Text('Mini Games', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildEarnCardsGrid(context),
            const SizedBox(height: 24),
            
            Text('Quick Earn', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildQuickEarnOptions(),
            const SizedBox(height: 24),
            
            _buildVipPromo(context),
            const SizedBox(height: 24),
            
            const BannerAdWidget(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final earnedToday = userProvider.user?.dailyEarned ?? 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Multiple ways to earn coins', style: TextStyle(color: Colors.white70)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Today: +$earnedToday 🪙', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDailyBonus(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    bool hasClaimed = false;
    if (user != null && user.lastDailyBonusClaim != null) {
      final last = user.lastDailyBonusClaim!;
      final now = DateTime.now();
      if (last.year == now.year && last.month == now.month && last.day == now.day) {
        hasClaimed = true;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_giftcard, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Login Bonus', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('🔥 Day ${user?.streak ?? 1} Streak!', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                if (hasClaimed) ...[
                  const SizedBox(height: 4),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      final now = DateTime.now();
                      final tomorrow = DateTime(now.year, now.month, now.day + 1);
                      final diff = tomorrow.difference(now);
                      final h = diff.inHours.toString().padLeft(2, '0');
                      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
                      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
                      return Text('Next in: $h:$m:$s', style: const TextStyle(color: Colors.white70, fontSize: 11));
                    },
                  ),
                ]
              ],
            ),
          ),
          ElevatedButton(
            onPressed: hasClaimed ? null : () async {
              try {
                int amount = await userProvider.claimDailyBonus();
                if (context.mounted && amount > 0) {
                  CoinEarnedAnimation.show(context, coins: amount, source: 'Daily Login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Daily Bonus Claimed! +$amount Coins', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to claim: ${e.toString().replaceAll('Exception: ', '')}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.white54,
              disabledForegroundColor: Colors.black54,
            ),
            child: Text(hasClaimed ? 'Claimed' : 'Claim'),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const StreakCalendar(
        currentStreak: 1,
        claimedToday: false,
      ),
    );
  }

  Widget _buildEarnCardsGrid(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    
    // Spin logic
    bool hasSpin = true;
    if (user != null && user.lastSpinDate != null) {
      if (DateTime.now().difference(user.lastSpinDate!).inHours < 12) {
        hasSpin = false;
      }
    }
    String spinBadge = user?.premiumSpins != null && user!.premiumSpins > 0 ? '${user.premiumSpins} Premium' : (hasSpin ? '1 Free Spin' : '0 Spins Left');
    
    // Scratch logic
    bool hasScratch = true;
    if (user != null && user.lastScratchDate != null) {
      if (DateTime.now().difference(user.lastScratchDate!).inHours < 12) {
        hasScratch = false;
      }
    }
    String scratchBadge = hasScratch ? '1 Card Left' : '0 Cards Left';
    
    // Mystery Box logic
    bool hasBox = true;
    if (user != null && user.lastMysteryBoxDate != null) {
      if (DateTime.now().difference(user.lastMysteryBoxDate!).inHours < 12) {
        hasBox = false;
      }
    }
    String boxBadge = hasBox ? '1 Box Left' : '0 Boxes Left';

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: [
        _buildGameCard(
          context: context,
          title: 'Lucky Spin',
          subtitle: 'Win up to 1000 coins!',
          badgeText: spinBadge,
          icon: Icons.casino,
          colors: [Colors.purple, Colors.blue],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpinWheelScreen())),
        ),
        _buildGameCard(
          context: context,
          title: 'Scratch & Win',
          subtitle: 'Reveal hidden rewards!',
          badgeText: scratchBadge,
          icon: Icons.style,
          colors: [Colors.pink, Colors.orange],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScratchCardScreen())),
        ),
        _buildGameCard(
          context: context,
          title: 'Mystery Box',
          subtitle: 'Surprise rewards inside!',
          badgeText: boxBadge,
          icon: Icons.inventory_2,
          colors: [Colors.teal, Colors.green],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MysteryBoxScreen())),
        ),
        _buildGameCard(
          context: context,
          title: 'Daily Goals',
          subtitle: 'Complete goals for coins',
          badgeText: 'Earn up to 1170🪙',
          icon: Icons.track_changes,
          colors: [Colors.amber, Colors.orange],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyGoalsScreen())),
        ),
      ],
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const Spacer(),
            Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
              child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEarnOptions() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Consumer2<AdProvider, UserProvider>(
            builder: (context, adProvider, userProvider, _) {
              return _buildListTile(Icons.ondemand_video, 'Watch Rewarded Ad', '+50 Coins per ad', adProvider.isRewardedLoaded ? 'Watch' : 'Loading...', Colors.blue, () async {
                if (!adProvider.isRewardedLoaded) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad is not ready yet, please wait.')));
                  adProvider.loadRewardedAd(); // Retry loading
                  return;
                }
                final reward = await adProvider.showRewardedAd();
                if (reward > 0 && context.mounted && userProvider.user != null) {
                  try {
                    await userProvider.claimAdReward(reward);
                    if (context.mounted) {
                      CoinEarnedAnimation.show(context, coins: reward, source: 'Ad Watched');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Awesome! +$reward Coins Claimed', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to verify reward. Try again.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                    }
                  }
                }
              });
            },
          ),
          const Divider(color: Colors.white10, height: 1),
          _buildListTile(Icons.share, 'Share App', '+50 Coins (3x daily)', '1/3', Colors.green, () {
            share_pkg.Share.share('💰 I am earning money by watching videos on WatchEarn! Download it now: https://watchearn.app');
          }),
          const Divider(color: Colors.white10, height: 1),
          _buildListTile(Icons.star, 'Rate App', '+300 Coins', 'Rate', Colors.amber, () {
            // Opens app store in production - for now show snackbar
          }),
          const Divider(color: Colors.white10, height: 1),
          _buildListTile(Icons.person_add, 'Invite Friend', '+500 Coins per friend', 'Invite', Colors.purple, () {
            share_pkg.Share.share('🎁 Join WatchEarn and earn real money watching videos! Sign up with my referral link: https://watchearn.app/invite');
          }),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, String action, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white10,
          foregroundColor: Colors.white,
          minimumSize: const Size(60, 30),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(action, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildVipPromo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFFFD700)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💎 Earn 5x-15x Faster!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Upgrade from \$9.99', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/vip');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Text('Upgrade', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
