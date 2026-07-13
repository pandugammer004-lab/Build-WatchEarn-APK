import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/daily_goal_model.dart';
import '../constants/app_colors.dart';
import 'animations/coin_flight_animation.dart';

class DailyGoalCard extends StatefulWidget {
  final DailyGoalModel goal;
  final int currentProgress;
  final bool isClaimed;
  final VoidCallback onClaim;

  const DailyGoalCard({
    Key? key,
    required this.goal,
    required this.currentProgress,
    required this.isClaimed,
    required this.onClaim,
  }) : super(key: key);

  @override
  State<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends State<DailyGoalCard> {
  bool _isClaiming = false;

  void _handleClaim(BuildContext context) {
    if (_isClaiming) return;
    setState(() => _isClaiming = true);
    
    CoinFlightAnimation.show(
      context,
      count: 5,
      onComplete: () {
        widget.onClaim();
        if (mounted) {
          setState(() => _isClaiming = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.currentProgress / widget.goal.target).clamp(0.0, 1.0);
    final isComplete = widget.currentProgress >= widget.goal.target;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isComplete ? Colors.green : AppColors.primary,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _getIconForType(widget.goal.type),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.goal.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isComplete ? Colors.green : AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.currentProgress}/${widget.goal.target}',
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '+${widget.goal.reward} 🪙',
                    style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.isClaimed)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24)
                else if (isComplete)
                  SizedBox(
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () => _handleClaim(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: _isClaiming
                          ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('Claim', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  const SizedBox(height: 24), // Placeholder to keep height consistent
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getIconForType(String type) {
    switch (type) {
      case 'video': return '▶️';
      case 'ad': return '📺';
      case 'share': return '🦋';
      case 'category': return '🗺️';
      default: return '🎯';
    }
  }
}
