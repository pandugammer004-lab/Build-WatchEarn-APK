import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/daily_goal_card.dart';
import '../../data/providers/earn_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/coin_provider.dart';
import '../../core/widgets/coin_earned_animation.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({Key? key}) : super(key: key);

  @override
  State<DailyGoalsScreen> createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> {

  int _getGoalProgress(String goalId, UserProvider userProvider) {
    final user = userProvider.user;
    if (user == null) return 0;

    switch (goalId) {
      case 'g1':
      case 'g2':
      case 'g3':
      case 'g4':
        return user.dailyVideosWatched;
      case 'g5':
        return user.dailyAdsWatched;
      default:
        return 0;
    }
  }

  void _claimGoal(String goalId, int reward) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null || user.claimedGoals.contains(goalId)) return;

    final actualReward = reward * (user.isVip ? 3 : 1); // Multiplier logic
    await userProvider.claimGoal(goalId, actualReward);
    
    // Show animation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Claimed $actualReward coins!'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('🎯 Daily Goals', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Consumer2<EarnProvider, UserProvider>(
        builder: (context, earnProvider, userProvider, _) {
          final goals = earnProvider.dailyGoals;
          int completedCount = 0;
          
          for (var goal in goals) {
            if (_getGoalProgress(goal.id, userProvider) >= goal.target) {
              completedCount++;
            }
          }

          final allComplete = completedCount == goals.length;
          final bonusClaimed = userProvider.user?.claimedGoals.contains('bonus') ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProgressHeader(completedCount, goals.length),
                const SizedBox(height: 24),
                
                ...goals.map((goal) {
                  final progress = _getGoalProgress(goal.id, userProvider);
                  return DailyGoalCard(
                    goal: goal,
                    currentProgress: progress,
                    isClaimed: userProvider.user?.claimedGoals.contains(goal.id) ?? false,
                    onClaim: () => _claimGoal(goal.id, goal.reward),
                  );
                }).toList(),

                const SizedBox(height: 16),
                _buildBonusCard(allComplete, bonusClaimed),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Progress', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
              const Text('Resets in: 14:32:05', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: total > 0 ? completed / total : 0,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 12,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$completed/$total',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Goals', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBonusCard(bool allComplete, bool isClaimed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('🎊 Complete all goals for bonus!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('+300 Bonus Coins', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: allComplete && !isClaimed ? () => _claimGoal('bonus', 300) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              disabledBackgroundColor: Colors.white54,
            ),
            child: Text(isClaimed ? 'CLAIMED' : 'CLAIM BONUS'),
          ),
        ],
      ),
    );
  }
}
