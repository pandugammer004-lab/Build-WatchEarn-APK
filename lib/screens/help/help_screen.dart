import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _selectedCategory = 'Earning';
  final List<String> _categories = ['Earning', 'Withdrawal', 'VIP', 'Technical', 'Account'];

  final Map<String, List<Map<String, String>>> _faqs = {
    'Earning': [
      {'q': 'How do I earn coins?', 'a': 'Watch videos to earn 10+ coins each. Complete daily goals, spin the wheel, scratch cards, and open mystery boxes for bonus coins!'},
      {'q': 'How much can I earn per day?', 'a': 'Free users can earn up to 1,000 coins per day from videos. VIP users earn 3x-15x more with no daily limits!'},
      {'q': 'Why didn\'t I get coins for a video?', 'a': 'You need to watch at least 30 seconds. Make sure your internet is connected.'},
    ],
    'Withdrawal': [
      {'q': 'What is the minimum withdrawal?', 'a': '\$5.00 for free users (50,000 coins).\n\$2.00 for VIP users (20,000 coins).'},
      {'q': 'How long does withdrawal take?', 'a': '3-5 business days for free users.\n1-24 hours for VIP users.'},
      {'q': 'Which payment methods are available?', 'a': 'PayPal, Amazon Gift Card, Google Play Credit, Apple Gift Card, Visa Prepaid.'},
    ],
    'VIP': [
      {'q': 'What is VIP membership?', 'a': 'VIP gives you 3x-15x faster earning, more daily spins/scratches, less ads, lower withdrawal minimum, and more!'},
      {'q': 'Can I cancel VIP?', 'a': 'Yes! Cancel anytime from your Play Store or App Store settings.'},
      {'q': 'Is Lifetime VIP really lifetime?', 'a': 'Yes! One payment, benefits forever.'},
    ],
    'Technical': [
      {'q': 'The app is crashing. What do I do?', 'a': 'Clear cache, restart app, or reinstall. Contact support if persists.'},
      {'q': 'Videos won\'t play. Help?', 'a': 'Check internet connection and video quality settings.'},
    ],
    'Account': [
      {'q': 'Can I have multiple accounts?', 'a': 'No, one account per person/device.'},
      {'q': 'How do I delete my account?', 'a': 'Settings → Delete Account. Note: All coins will be lost!'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Help & FAQ', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search FAQ...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = category),
                    backgroundColor: Colors.white10,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _faqs[_selectedCategory]!.length,
              itemBuilder: (context, index) {
                final faq = _faqs[_selectedCategory]![index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(faq['q']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      iconColor: AppColors.primary,
                      collapsedIconColor: Colors.white54,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(faq['a']!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Helpers.launchURL(context, 'mailto:support@watchearn.app?subject=Support%20Request');
              },
              icon: const Icon(Icons.mail),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
