import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/user_provider.dart';
import '../../core/utils/helpers.dart';
import 'withdraw_screen.dart';
import '../vip/vip_plans_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Wallet', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;
          final coins = user?.coins ?? 0;
          final cashValue = (coins / 10000).toStringAsFixed(2); // Assuming 10k coins = $1

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBalanceCard(context, coins, cashValue, user?.isVip ?? false),
                const SizedBox(height: 24),
                _buildQuickStats(),
                const SizedBox(height: 24),
                _buildWithdrawalOptions(context, user?.isVip ?? false),
                const SizedBox(height: 24),
                _buildMinimumWithdrawalInfo(user?.isVip ?? false),
                const SizedBox(height: 24),
                if (user?.isVip != true) _buildVipPromo(context),
                if (user?.isVip != true) const SizedBox(height: 24),
                _buildTransactionHistory(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBalanceCard(BuildContext context, int coins, String cashValue, bool isVip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Text('My Wallet', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪙 ', style: TextStyle(fontSize: 32)),
              Text(
                Helpers.formatCoins(coins),
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('= \$$cashValue USD', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Withdraw Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(coins, isVip),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int coins, bool isVip) {
    final target = isVip ? 20000 : 50000;
    final progress = (coins / target).clamp(0.0, 1.0);
    
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.black26,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text('${Helpers.formatCoins(coins)} / ${Helpers.formatCoins(target)} to next milestone', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatBox('Total Earned', '256,000 🪙'),
        const SizedBox(width: 12),
        _buildStatBox('Total Withdrawn', '\$5.00'),
        const SizedBox(width: 12),
        _buildStatBox('Pending', '\$0.00'),
      ],
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalOptions(BuildContext context, bool isVip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cash Out Methods', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildMethodCard(context, 'PayPal', 'Instant transfer', '💳', true),
        _buildMethodCard(context, 'Amazon Gift Card', 'Email delivery', '🛍️', false),
        _buildMethodCard(context, 'Google Play Credit', 'App credit', '🎮', false),
        _buildMethodCard(context, 'Apple Gift Card', 'iTunes credit', '🍎', false),
        _buildMethodCard(context, 'Visa Prepaid Card', 'Physical card', '💳', false),
      ],
    );
  }

  Widget _buildMethodCard(BuildContext context, String name, String desc, String emoji, bool isPopular) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())),
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
        ),
        title: Row(
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            if (isPopular) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Text(desc, style: const TextStyle(color: Colors.white54)),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Withdraw', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimumWithdrawalInfo(bool isVip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text('Withdrawal Info', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(isVip ? 'Minimum: \$2.00 (20,000 coins)' : 'Minimum: \$5.00 (50,000 coins)', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(isVip ? 'Processing: 1 business day (VIP)' : 'Processing: 3-5 business days', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVipPromo(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VipPlansScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFFFD700)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Withdraw from just \$2 with VIP!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transaction History', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Demo tabs
        Row(
          children: [
            _buildTab('All', true),
            _buildTab('Earnings', false),
            _buildTab('Withdrawals', false),
            _buildTab('VIP', false),
          ],
        ),
        const SizedBox(height: 16),
        _buildTransactionItem('📺', 'Video Watched', '10 mins ago', '+50', true),
        _buildTransactionItem('🎰', 'Lucky Spin', '2 hours ago', '+100', true),
        _buildTransactionItem('💸', 'PayPal Withdrawal', '1 day ago', '-50000', false),
      ],
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildTransactionItem(String emoji, String title, String time, String amount, bool isEarn) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: TextStyle(color: isEarn ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: const Text('Success', style: TextStyle(color: Colors.green, fontSize: 8)),
          ),
        ],
      ),
    );
  }
}
