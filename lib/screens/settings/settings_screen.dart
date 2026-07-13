import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Preferences
  bool _pushNotifications = true;
  bool _autoplayVideos = true;
  String _videoQuality = 'Auto';
  bool _soundEffects = true;

  // Notification Controls
  bool _dailyBonusNotif = true;
  bool _streakWarningNotif = true;
  bool _newVideosNotif = true;
  bool _vipOffersNotif = true;
  bool _referralNotif = true;
  bool _leaderboardNotif = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('⚙️ Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('APP PREFERENCES'),
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('ACCOUNT SETTINGS'),
            _buildAccountSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('NOTIFICATIONS'),
            _buildNotificationsSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('PAYMENT SETTINGS'),
            _buildPaymentSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('SUPPORT'),
            _buildSupportSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('ABOUT'),
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('DANGER ZONE', isDanger: true),
            _buildDangerSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: isDanger ? Colors.redAccent : AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildPreferencesSection() {
    return _buildCardContainer([
      _buildSwitchTile('Push Notifications', 'Daily reminders & rewards', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
      const Divider(color: Colors.white12, height: 1),
      _buildSwitchTile('Autoplay Videos', 'Auto-play next video', _autoplayVideos, (v) => setState(() => _autoplayVideos = v)),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        title: const Text('Video Quality', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('Current: Auto', style: TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          // Show bottom sheet to select quality
        },
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        title: const Text('Dark Mode', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('Dark theme (default)', style: TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: Switch(value: true, onChanged: null, activeColor: AppColors.primary),
      ),
      const Divider(color: Colors.white12, height: 1),
      _buildSwitchTile('Sound Effects', 'Coin earn & spin sounds', _soundEffects, (v) => setState(() => _soundEffects = v)),
    ]);
  }

  Widget _buildAccountSection() {
    return _buildCardContainer([
      ListTile(
        leading: const Icon(Icons.lock, color: Colors.white),
        title: const Text('Change Password', style: TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () => _showChangePasswordSheet(),
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.email, color: Colors.white),
        title: const Text('Email Address', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('user@example.com (Not changeable)', style: TextStyle(color: Colors.white54, fontSize: 12)),
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.link, color: Colors.white),
        title: const Text('Connected Accounts', style: TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {},
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.devices, color: Colors.white),
        title: const Text('Device Sessions', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('Manage active sessions', style: TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {},
      ),
    ]);
  }

  Widget _buildNotificationsSection() {
    return _buildCardContainer([
      _buildSwitchTile('Daily Bonus Reminder', '', _dailyBonusNotif, (v) => setState(() => _dailyBonusNotif = v)),
      const Divider(color: Colors.white12, height: 1),
      _buildSwitchTile('Streak Warning', '', _streakWarningNotif, (v) => setState(() => _streakWarningNotif = v)),
      const Divider(color: Colors.white12, height: 1),
      _buildSwitchTile('New Videos', '', _newVideosNotif, (v) => setState(() => _newVideosNotif = v)),
      const Divider(color: Colors.white12, height: 1),
      _buildSwitchTile('VIP Offers', '', _vipOffersNotif, (v) => setState(() => _vipOffersNotif = v)),
      const Divider(color: Colors.white12, height: 1),
      _buildSwitchTile('Referral Updates', '', _referralNotif, (v) => setState(() => _referralNotif = v)),
      const Divider(color: Colors.white12, height: 1),
      _buildSwitchTile('Leaderboard Updates', '', _leaderboardNotif, (v) => setState(() => _leaderboardNotif = v)),
      const Divider(color: Colors.white12, height: 1),
      SwitchListTile(
        title: const Text('Withdrawal Updates', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('Always on for security', style: TextStyle(color: Colors.white54, fontSize: 12)),
        value: true,
        onChanged: null,
      ),
    ]);
  }

  Widget _buildPaymentSection() {
    return _buildCardContainer([
      ListTile(
        leading: const Icon(Icons.payment, color: Colors.white),
        title: const Text('Default Payment Method', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('PayPal', style: TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {},
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.pin, color: Colors.white),
        title: const Text('Transaction PIN', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('Not configured', style: TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {},
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return _buildCardContainer([
      ListTile(
        leading: const Icon(Icons.mail_outline, color: Colors.white),
        title: const Text('Contact Support', style: TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () {},
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        title: const Text('Live Chat', style: TextStyle(color: Colors.white, fontSize: 14)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          child: const Text('COMING SOON', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
        ),
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.help_outline, color: Colors.white),
        title: const Text('FAQ', style: TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () => Navigator.pushNamed(context, '/help'),
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.bug_report_outlined, color: Colors.white),
        title: const Text('Report Bug', style: TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () {},
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.lightbulb_outline, color: Colors.white),
        title: const Text('Suggest Feature', style: TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () {},
      ),
    ]);
  }

  Widget _buildAboutSection() {
    return _buildCardContainer([
      const ListTile(
        title: Text('App Version', style: TextStyle(color: Colors.white, fontSize: 14)),
        trailing: Text('1.0.0 (Build 1)', style: TextStyle(color: Colors.white54)),
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        title: const Text('Terms of Service', style: TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () => Navigator.pushNamed(context, '/legal'),
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () => Navigator.pushNamed(context, '/legal'),
      ),
      const Divider(color: Colors.white12, height: 1),
      const ListTile(
        title: Text('Open Source Licenses', style: TextStyle(color: Colors.white, fontSize: 14)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      ),
    ]);
  }

  Widget _buildDangerSection() {
    return _buildCardContainer([
      ListTile(
        leading: const Icon(Icons.delete_outline, color: Colors.white),
        title: const Text('Clear Cache', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('42 MB', style: TextStyle(color: Colors.white54, fontSize: 12)),
        onTap: () {},
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.white),
        title: const Text('Log Out', style: TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () {},
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
        title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
        onTap: () {},
      ),
    ]);
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Change Password', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const CustomTextField(hintText: 'Current Password', prefixIcon: Icons.lock_outline, isPassword: true),
                const SizedBox(height: 16),
                const CustomTextField(hintText: 'New Password', prefixIcon: Icons.lock, isPassword: true),
                const SizedBox(height: 16),
                const CustomTextField(hintText: 'Confirm New Password', prefixIcon: Icons.lock, isPassword: true),
                const SizedBox(height: 24),
                CustomButton(text: 'Save Password', onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        );
      },
    );
  }
}
