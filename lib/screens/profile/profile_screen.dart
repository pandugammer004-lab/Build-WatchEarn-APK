import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// Note: In a real app, you would uncomment this
// import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/user_provider.dart';
import '../../core/utils/helpers.dart';
import 'edit_profile_screen.dart';
import '../settings/settings_screen.dart';
import '../notifications/notifications_screen.dart';
import '../help/help_screen.dart';
import '../legal/legal_screen.dart';
import 'package:share_plus/share_plus.dart' as import_share;
import '../../data/providers/auth_provider.dart';
import '../../core/constants/app_config.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, user),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStatsGrid(user),
                      const SizedBox(height: 24),
                      _buildEarningsSummary(userProvider),
                      const SizedBox(height: 24),
                      _buildRecentBadges(context),
                      const SizedBox(height: 24),
                      _buildQuickActions(context, user?.isVip ?? false, user?.coins ?? 0, user?.totalReferrals ?? 0),
                      const SizedBox(height: 24),
                      _buildAccountSection(context, user),
                      const SizedBox(height: 24),
                      _buildDangerZone(),
                      const SizedBox(height: 40),
                      const Text('WatchEarn v1.0.0\nMade with ❤️', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 16),
                      Text('Developed by Azhar Arshad', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('WhatsApp: +923022908393', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: user?.isVip == true ? Colors.amber : Colors.transparent,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white24,
                      backgroundImage: user?.profilePic != null ? NetworkImage(user!.profilePic!) : null,
                      child: user?.profilePic == null
                          ? Text(user?.name[0].toUpperCase() ?? 'U', style: const TextStyle(fontSize: 40, color: Colors.white))
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(user?.name ?? 'User', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user?.email ?? 'user@example.com', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            if (user?.isVip == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Gold VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Code: ${user?.referralCode ?? 'NONE'}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.copy, color: Colors.white70, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(dynamic user) {
    final int watchTimeMin = user?.totalWatchTimeSeconds != null ? user!.totalWatchTimeSeconds ~/ 60 : 0;
    final int h = watchTimeMin ~/ 60;
    final int m = watchTimeMin % 60;
    final String watchTimeStr = h > 0 ? '${h}h ${m}m' : '${m}m';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('🪙', 'Total Coins', Helpers.formatCoins(user?.coins ?? 0), 'Lifetime: ${Helpers.formatCoins(user?.totalEarned ?? 0)}', Colors.amber),
        _buildStatCard('📺', 'Videos', '${user?.videosWatched ?? 0}', 'Today: ${user?.dailyVideosWatched ?? 0}', Colors.purple),
        _buildStatCard('⏱️', 'Watch Time', watchTimeStr, 'Active User', Colors.cyan),
        _buildStatCard('🔥', 'Best Streak', '${user?.streak ?? 0} Days', 'Current Streak', Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEarningsSummary(UserProvider provider) {
    final user = provider.user;
    
    // Calculate last 7 days earnings for chart
    final now = DateTime.now();
    List<FlSpot> spots = [];
    double maxEarning = 0;
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      int dailySum = 0;
      
      for (var tx in provider.transactions) {
        if (tx.isEarning && 
            tx.timestamp.year == date.year && 
            tx.timestamp.month == date.month && 
            tx.timestamp.day == date.day) {
          dailySum += tx.coins;
        }
      }
      
      if (dailySum > maxEarning) maxEarning = dailySum.toDouble();
      spots.add(FlSpot((6 - i).toDouble(), dailySum.toDouble()));
    }
    
    if (maxEarning == 0) maxEarning = 100; // default scale
    maxEarning = maxEarning * 1.2; // 20% padding top

      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: Colors.white12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Earnings Analytics', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Last 7 Days', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final daysAgo = 6 - value.toInt();
                        if (daysAgo == 0) return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Today', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)));
                        if (daysAgo == 3) return const Padding(padding: EdgeInsets.only(top: 8), child: Text('3d ago', style: TextStyle(color: Colors.white54, fontSize: 10)));
                        if (daysAgo == 6) return const Padding(padding: EdgeInsets.only(top: 8), child: Text('7d ago', style: TextStyle(color: Colors.white54, fontSize: 10)));
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxEarning,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: AppColors.cardColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Lifetime Coins', '${Helpers.formatCoins(user?.totalEarned ?? 0)}', Icons.stars, Colors.amber),
              _buildSummaryItem('Cash Value', '\$${((user?.coins ?? 0) / 10000).toStringAsFixed(2)}', Icons.attach_money, Colors.greenAccent),
              _buildSummaryItem('Today\'s Coins', '${spots.last.y.toInt()}', Icons.today, Colors.blueAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentBadges(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Achievements', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/achievements'),
              child: const Text('View All →', style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildBadgeItem('🍿', 'Binge Watcher'),
              _buildBadgeItem('🔥', '7-Day Streak'),
              _buildBadgeItem('🤝', 'First Invite'),
              _buildBadgeItem('👑', 'VIP Member'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(String emoji, String name) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.withOpacity(0.3))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isVip, int coins, int referrals) {
    return Column(
      children: [
        if (!isVip)
          _buildActionItem(context, '💎 Upgrade to VIP', 'Earn faster, withdraw more!', Colors.purpleAccent, () => Navigator.pushNamed(context, '/vip')),
        _buildActionItem(context, '💰 Withdraw Earnings', '${Helpers.formatCoins(coins)} coins available', Colors.green, () => Navigator.pushNamed(context, '/withdraw')),
        _buildActionItem(context, '👥 Referral Program', 'Earn 10% commission ($referrals active)', Colors.blue, () => Navigator.pushNamed(context, '/referral')),
        _buildActionItem(context, '🏆 Leaderboard', 'Check your rank', Colors.amber, () => Navigator.pushNamed(context, '/leaderboard')),
        _buildActionItem(context, '🎖️ Achievements', 'View unlocked badges', Colors.orange, () => Navigator.pushNamed(context, '/achievements')),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, String subtitle, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, dynamic user) {
    final bool isAdmin = user != null && 
        AppConfig.adminEmails.any((email) => email.toLowerCase() == user.email.toString().toLowerCase());
    
    return Container(
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          if (isAdmin) ...[
            _buildAccountListTile(context, Icons.admin_panel_settings, 'Admin Dashboard', Colors.redAccent, () => Navigator.pushNamed(context, '/admin')),
            _buildDivider(),
          ],
          _buildAccountListTile(context, Icons.edit, 'Edit Profile', Colors.white, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
          _buildDivider(),
          _buildAccountListTile(context, Icons.notifications, 'Notifications', Colors.white, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          _buildDivider(),
          _buildAccountListTile(context, Icons.settings, 'Settings', Colors.white, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          _buildDivider(),
          _buildAccountListTile(context, Icons.help_outline, 'Help & FAQ', Colors.white, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()))),
          _buildDivider(),
          _buildAccountListTile(context, Icons.privacy_tip_outlined, 'Privacy Policy', Colors.white, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(title: 'Privacy Policy', url: '')))),
          _buildDivider(),
          _buildAccountListTile(context, Icons.description_outlined, 'Terms of Service', Colors.white, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(title: 'Terms of Service', url: '')))),
          _buildDivider(),
          _buildAccountListTile(context, Icons.star_border, 'Rate Us', Colors.amber, () {
            Helpers.showSuccessSnackbar(context, 'Opening Play Store...');
          }),
          _buildDivider(),
          _buildAccountListTile(context, Icons.share, 'Share App', Colors.blue, () {
            // using exact class path for Share
            import_share.Share.share('Download WatchEarn and get rich! Use my referral code! https://watchearn.app');
          }),
          _buildDivider(),
          _buildAccountListTile(context, Icons.logout, 'Log Out', Colors.redAccent, () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.signOut();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  Widget _buildAccountListTile(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => const Divider(color: Colors.white12, height: 1);

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withOpacity(0.3))),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.redAccent),
        title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        onTap: () {},
      ),
    );
  }
}
