import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/custom_button.dart';

class AdminSettings extends StatelessWidget {
  const AdminSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('⚙️ App Settings', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              CustomButton(text: 'Save All Settings', onPressed: () {}, width: 200),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildSettingsGroup('Coin System Settings', [
                          _buildNumberSetting('Coins per video', '10'),
                          _buildNumberSetting('Coins per ad', '15'),
                          _buildNumberSetting('Coins per referral', '500'),
                          _buildNumberSetting('Coins to Dollar ratio', '10000'),
                        ]),
                        const SizedBox(height: 24),
                        _buildSettingsGroup('Daily Limits (Free)', [
                          _buildNumberSetting('Max videos per day', '100'),
                          _buildNumberSetting('Max spins per day', '1'),
                          _buildNumberSetting('Max scratch cards', '3'),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildSettingsGroup('Withdrawal Settings', [
                          _buildNumberSetting('Min withdrawal (Free) \$', '5.00'),
                          _buildNumberSetting('Min withdrawal (VIP) \$', '2.00'),
                          _buildToggleSetting('Enable withdrawals', true),
                          _buildToggleSetting('Auto-approve under \$5', false),
                        ]),
                        const SizedBox(height: 24),
                        _buildSettingsGroup('Ad Settings', [
                          _buildToggleSetting('Banner Ads', true),
                          _buildToggleSetting('Interstitial Ads', true),
                          _buildToggleSetting('Rewarded Ads', true),
                          _buildNumberSetting('Ads after videos (Free)', '4'),
                          _buildNumberSetting('Ads after videos (VIP)', '8'),
                        ]),
                        const SizedBox(height: 24),
                        _buildSettingsGroup('App Config', [
                          _buildToggleSetting('Maintenance Mode', false),
                          _buildToggleSetting('Force Update', false),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNumberSetting(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          SizedBox(
            width: 100,
            height: 40,
            child: TextField(
              controller: TextEditingController(text: value),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Switch(value: value, onChanged: (_) {}, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}
