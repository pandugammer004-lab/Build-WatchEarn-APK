import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Watching', 'Streaks', 'Referrals', 'Special'];

  // Demo badges data
  final List<Map<String, dynamic>> _badges = [
    {
      'id': 'w1', 'category': 'Watching', 'name': 'First View',
      'desc': 'Watch your first video', 'emoji': '👀', 'reward': 500,
      'reqDesc': 'Watch 1 video (1/1)', 'isUnlocked': true, 'unlockDate': 'Mar 15'
    },
    {
      'id': 'w2', 'category': 'Watching', 'name': 'Binge Watcher',
      'desc': 'Watch 50 videos', 'emoji': '🍿', 'reward': 2000,
      'reqDesc': 'Watch 50 videos (23/50)', 'isUnlocked': false,
    },
    {
      'id': 's1', 'category': 'Streaks', 'name': 'Weekend Warrior',
      'desc': 'Login both Saturday and Sunday', 'emoji': '⚔️', 'reward': 1000,
      'reqDesc': 'Login on weekend (2/2)', 'isUnlocked': true, 'unlockDate': 'Mar 17'
    },
    {
      'id': 's2', 'category': 'Streaks', 'name': '7-Day Streak',
      'desc': 'Login for 7 consecutive days', 'emoji': '🔥', 'reward': 5000,
      'reqDesc': 'Login 7 days (4/7)', 'isUnlocked': false,
    },
    {
      'id': 'r1', 'category': 'Referrals', 'name': 'First Invite',
      'desc': 'Successfully refer 1 friend', 'emoji': '🤝', 'reward': 1000,
      'reqDesc': 'Refer 1 friend (0/1)', 'isUnlocked': false,
    },
    {
      'id': 'sp1', 'category': 'Special', 'name': 'VIP Member',
      'desc': 'Become a VIP member', 'emoji': '👑', 'reward': 5000,
      'reqDesc': 'Purchase VIP plan', 'isUnlocked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('🎖️ Achievements', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCategoriesFilter(),
            const SizedBox(height: 24),
            _buildRecentUnlocks(),
            const SizedBox(height: 24),
            Text('Next to Unlock', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAlmostThere(),
            const SizedBox(height: 24),
            Text('All Badges', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildBadgesGrid(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    int unlockedCount = _badges.where((b) => b['isUnlocked']).length;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$unlockedCount/${_badges.length} Unlocked', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('1,500 🪙 from badges', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: unlockedCount / _badges.length,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 8,
                ),
              ),
              Text(
                '${((unlockedCount / _badges.length) * 100).toInt()}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: Colors.white10,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
              showCheckmark: false,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentUnlocks() {
    final recent = _badges.where((b) => b['isUnlocked']).toList();
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recently Unlocked', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final badge = recent[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2A2D3E), AppColors.cardColor]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(badge['emoji'], style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(badge['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('+${badge['reward']} 🪙', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                          Text('Earned ${badge['unlockDate']}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlmostThere() {
    // Demo logic, just show locked badges with progress
    final almost = _badges.where((b) => !b['isUnlocked']).take(2).toList();
    if (almost.isEmpty) return const SizedBox.shrink();

    return Column(
      children: almost.map((badge) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Text(badge['emoji'], style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(badge['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(badge['reqDesc'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(value: 0.46, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(Colors.amber), minHeight: 6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadgesGrid() {
    final filteredBadges = _selectedCategory == 'All' 
        ? _badges 
        : _badges.where((b) => b['category'] == _selectedCategory).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredBadges.length,
      itemBuilder: (context, index) {
        final badge = filteredBadges[index];
        return _buildBadgeCard(badge);
      },
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final bool unlocked = badge['isUnlocked'];

    return GestureDetector(
      onTap: () => _showBadgeDetail(badge),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: unlocked ? Border.all(color: Colors.amber.withOpacity(0.5), width: 2) : Border.all(color: Colors.white12),
          boxShadow: unlocked ? [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 10)] : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: unlocked ? 1.0 : 0.3,
                  child: Text(badge['emoji'], style: const TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    badge['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: unlocked ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (!unlocked)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.lock, color: Colors.white24, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(Map<String, dynamic> badge) {
    final bool unlocked = badge['isUnlocked'];

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
              Opacity(opacity: unlocked ? 1.0 : 0.5, child: Text(badge['emoji'], style: const TextStyle(fontSize: 80))),
              const SizedBox(height: 16),
              Text(badge['name'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(badge['desc'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Text('Reward: +${badge['reward']} 🪙', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(badge['reqDesc'], style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              if (unlocked) ...[
                const SizedBox(height: 16),
                Text('Unlocked on ${badge['unlockDate']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50)),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
