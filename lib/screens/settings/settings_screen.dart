import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/services/notification_service.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/auth_provider.dart';

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
      _buildSwitchTile('Push Notifications', 'Daily reminders & rewards', _pushNotifications, (v) {
        setState(() => _pushNotifications = v);
        if (!v) {
          NotificationService().cancelAllNotifications();
        } else {
          // Re-schedule based on current state (e.g., daily login)
          NotificationService().scheduleDailyLoginReminder();
        }
      }),
      const Divider(color: Colors.white12, height: 1),
      _buildSwitchTile('Autoplay Videos', 'Auto-play next video', _autoplayVideos, (v) => setState(() => _autoplayVideos = v)),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        title: const Text('Video Quality', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text('Current: $_videoQuality', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.cardColor,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Video Quality', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...['Auto', '1080p', '720p', '480p'].map((q) => ListTile(
                    title: Text(q, style: const TextStyle(color: Colors.white)),
                    trailing: _videoQuality == q ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () {
                      setState(() => _videoQuality = q);
                      Navigator.pop(context);
                    },
                  )).toList(),
                  const SizedBox(height: 16),
                ],
              );
            }
          );
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
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardColor,
              title: const Text('Connected Accounts', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.g_mobiledata, color: Colors.white, size: 32),
                    title: const Text('Google', style: TextStyle(color: Colors.white)),
                    trailing: const Text('Connected', style: TextStyle(color: Colors.green)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.facebook, color: Colors.white, size: 32),
                    title: const Text('Facebook', style: TextStyle(color: Colors.white)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting to Facebook...')));
                      }, 
                      child: const Text('Connect')
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Colors.white54))),
              ],
            )
          );
        },
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.devices, color: Colors.white),
        title: const Text('Device Sessions', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('Manage active sessions', style: TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardColor,
              title: const Text('Device Sessions', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: Colors.white),
                    title: const Text('Current Device', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Active now - Android 13', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Colors.white54))),
              ],
            )
          );
        },
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
        subtitle: const Text('Crypto (TRC20)', style: TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardColor,
              title: const Text('Payment Method', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    value: 'Crypto (TRC20)',
                    groupValue: 'Crypto (TRC20)',
                    onChanged: (val) => Navigator.pop(context),
                    title: const Text('Crypto (TRC20)', style: TextStyle(color: Colors.white)),
                    activeColor: AppColors.primary,
                  ),
                  RadioListTile(
                    value: 'PayPal',
                    groupValue: 'Crypto (TRC20)',
                    onChanged: (val) => Navigator.pop(context),
                    title: const Text('PayPal', style: TextStyle(color: Colors.white)),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            )
          );
        },
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.pin, color: Colors.white),
        title: const Text('Transaction PIN', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('Not configured', style: TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN setup will be available soon!')));
        },
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return _buildCardContainer([
      ListTile(
        leading: const Icon(Icons.mail_outline, color: Colors.white),
        title: const Text('Contact Support', style: TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening email client to support@watchearn.com...')));
        },
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
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live Chat is currently offline.')));
        },
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
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bug report form will open here.')));
        },
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.lightbulb_outline, color: Colors.white),
        title: const Text('Suggest Feature', style: TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature suggestion form will open here.')));
        },
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
      ListTile(
        title: const Text('Open Source Licenses', style: TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          showLicensePage(context: context);
        },
      ),
    ]);
  }

  Widget _buildDangerSection() {
    return _buildCardContainer([
      ListTile(
        leading: const Icon(Icons.delete_outline, color: Colors.white),
        title: const Text('Clear Cache', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('42 MB', style: TextStyle(color: Colors.white54, fontSize: 12)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache cleared successfully! 0 MB used.')));
        },
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.white),
        title: const Text('Log Out', style: TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () async {
          try {
            await Provider.of<AuthProvider>(context, listen: false).signOut();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out successfully.')));
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            }
          }
        },
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
        title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardColor,
              title: const Text('Delete Account?', style: TextStyle(color: Colors.white)),
              content: const Text('Are you sure you want to delete your account? This action cannot be undone.', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted successfully.')));
                    try {
                      await Provider.of<AuthProvider>(context, listen: false).signOut();
                    } catch (e) {}
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: const Text('Delete'),
                ),
              ],
            )
          );
        },
      ),
    ]);
  }

  void _showChangePasswordSheet() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

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
                CustomTextField(controller: currentPasswordController, hintText: 'Current Password', prefixIcon: Icons.lock_outline, isPassword: true),
                const SizedBox(height: 16),
                CustomTextField(controller: newPasswordController, hintText: 'New Password', prefixIcon: Icons.lock, isPassword: true),
                const SizedBox(height: 16),
                CustomTextField(controller: confirmPasswordController, hintText: 'Confirm New Password', prefixIcon: Icons.lock, isPassword: true),
                const SizedBox(height: 24),
                CustomButton(text: 'Save Password', onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
