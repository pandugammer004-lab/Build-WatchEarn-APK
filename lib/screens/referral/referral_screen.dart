import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/providers/user_provider.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('👥 Invite & Earn', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;
          final refCode = user?.referralCode ?? 'ERROR';
          final link = 'watchearn.app/invite/$refCode';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user?.totalReferrals ?? 0),
                const SizedBox(height: 24),
                _buildReferralCodeCard(context, refCode, link),
                const SizedBox(height: 24),
                _buildShareButtons(link),
                const SizedBox(height: 24),
                _buildHowItWorks(),
                const SizedBox(height: 24),
                _buildReferralStats(user?.totalReferrals ?? 0),
                const SizedBox(height: 24),
                _buildMilestoneRewards(user?.totalReferrals ?? 0),
                const SizedBox(height: 24),
                _buildMyReferralsList(),
                const SizedBox(height: 24),
                _buildCommissionHistory(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(int totalReferrals) {
    final int earnedCoins = totalReferrals * 500;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Earn lifetime 10% commission!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Total Earned: ${Helpers.formatCoins(earnedCoins)} 🪙', style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(BuildContext context, String code, String link) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text('Your Referral Code', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              code,
              style: GoogleFonts.sourceCodePro(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
          const SizedBox(height: 8),
          Text(link, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionBtn(Icons.copy, 'Copy Code', () {
                Clipboard.setData(ClipboardData(text: code));
                Helpers.showSuccessSnackbar(context, 'Code Copied!');
              }),
              _buildActionBtn(Icons.link, 'Copy Link', () {
                Clipboard.setData(ClipboardData(text: link));
                Helpers.showSuccessSnackbar(context, 'Link Copied!');
              }),
              _buildActionBtn(Icons.qr_code, 'QR Code', () => _showQrCode(context, link, code)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showQrCode(BuildContext context, String link, String code) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Scan to Join WatchEarn', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: QrImageView(
                  data: link,
                  version: QrVersions.auto,
                  size: 200.0,
                  embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
                ),
              ),
              const SizedBox(height: 16),
              Text(code, style: GoogleFonts.sourceCodePro(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareButtons(String link) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Share with Friends', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildShareBtn(Icons.chat, 'WhatsApp', Colors.green, link),
            _buildShareBtn(Icons.camera_alt, 'Instagram', Colors.purple, link),
            _buildShareBtn(Icons.facebook, 'Facebook', Colors.blue, link),
            _buildShareBtn(Icons.alternate_email, 'X (Twitter)', Colors.black87, link),
            _buildShareBtn(Icons.message, 'SMS', Colors.greenAccent.shade700, link),
            _buildShareBtn(Icons.share, 'More...', Colors.grey, link),
          ],
        ),
      ],
    );
  }

  Widget _buildShareBtn(IconData icon, String label, Color color, String link) {
    return GestureDetector(
      onTap: () {
        Share.share('Hey! Join me on WatchEarn and get 500 free coins. Use my link: $link');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How It Works', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildStepCard('1', '📤', 'Share your code', 'Share your unique referral code with friends'),
        _buildStepCard('2', '👤', 'Friend joins', 'Friend downloads app & signs up (+500 coins!)'),
        _buildStepCard('3', '▶️', 'Friend watches', 'Friend watches 10 videos (+200 coins!)'),
        _buildStepCard('4', '♾️', 'Lifetime commission', 'Earn 10% of all coins your friend earns forever!'),
      ],
    );
  }

  Widget _buildStepCard(String step, String emoji, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralStats(int count) {
    final int earnedCoins = count * 500;
    final String cashValue = '\$${(earnedCoins / 10000).toStringAsFixed(2)}'; // Assuming 10k coins = $1
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.0,
      children: [
        _buildStatCard('👥', 'Total Referrals', '$count'),
        _buildStatCard('✅', 'Active Referrals', '$count'),
        _buildStatCard('🪙', 'Coins Earned', Helpers.formatCoins(earnedCoins)),
        _buildStatCard('💰', 'Cash Value', cashValue),
      ],
    );
  }

  Widget _buildStatCard(String icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMilestoneRewards(int count) {
    // Demo milestones
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Milestone Rewards', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildMilestone(context, 5, '5,000 coins', count >= 5, true),
        _buildMilestone(context, 10, '15,000 coins + Bronze', count >= 10, false),
        _buildMilestone(context, 25, '50,000 coins + Silver', count >= 25, false),
        _buildMilestone(context, 50, '150,000 coins + Gold', count >= 50, false),
        _buildMilestone(context, 100, '500,000 coins + VIP', count >= 100, false),
      ],
    );
  }

  Widget _buildMilestone(BuildContext context, int target, String reward, bool reached, bool claimed) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? AppColors.primary : Colors.white10,
                border: Border.all(color: reached ? AppColors.primary : Colors.white38),
              ),
              child: reached ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
            Container(width: 2, height: 30, color: reached ? AppColors.primary : Colors.white10),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$target Referrals', style: TextStyle(color: reached ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                    Text(reward, style: const TextStyle(color: Colors.amber, fontSize: 12)),
                  ],
                ),
                if (reached && !claimed)
                  ElevatedButton(
                    onPressed: () {
                      // Simulated claim
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Claimed $reward! Added to your balance.')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(60, 30)),
                    child: const Text('Claim', style: TextStyle(fontSize: 12)),
                  )
                else if (claimed)
                  const Text('CLAIMED', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyReferralsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Referrals', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Empty state demo
        Center(
          child: Column(
            children: [
              const Icon(Icons.people, color: Colors.white24, size: 64),
              const SizedBox(height: 16),
              const Text('No referrals yet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('Share your code and start earning!', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Commission History', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListTile(
          leading: const Text('🪙', style: TextStyle(fontSize: 24)),
          title: const Text('Alice watched a video', style: TextStyle(color: Colors.white)),
          subtitle: const Text('2 mins ago', style: TextStyle(color: Colors.white54)),
          trailing: const Text('+10', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
