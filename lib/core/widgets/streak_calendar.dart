import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'animations/glow_pulse_widget.dart';
import 'animations/scale_in_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakCalendar extends StatelessWidget {
  final int currentStreak;
  final bool claimedToday;
  
  const StreakCalendar({
    Key? key,
    required this.currentStreak,
    required this.claimedToday,
  }) : super(key: key);

  final List<int> _rewards = const [25, 35, 50, 65, 80, 100, 200];
  final List<String> _days = const ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5', 'Day 6', 'Day 7'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final dayNum = index + 1;
          final isCompleted = claimedToday ? dayNum <= currentStreak : dayNum < currentStreak;
          final isToday = claimedToday ? dayNum == currentStreak : dayNum == currentStreak;
          final isFuture = dayNum > currentStreak;

          return ScaleInWidget(
            delay: Duration(milliseconds: index * 100),
            child: Column(
              children: [
                Text(
                  '+${_rewards[index]}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isCompleted ? Colors.amber : Colors.white38,
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                _buildDayCircle(isCompleted, isToday, isFuture),
                const SizedBox(height: 4),
                Text(
                  _days[index],
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isToday ? AppColors.primary : Colors.white54,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayCircle(bool isCompleted, bool isToday, bool isFuture) {
    Widget circle = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isCompleted ? AppColors.primaryGradient : null,
        color: isFuture ? Colors.white10 : (isToday ? AppColors.cardColor : null),
        border: isToday && !isCompleted ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : (isToday && !claimedToday
                ? const Icon(Icons.star, color: AppColors.primary, size: 16)
                : const Text('🪙', style: TextStyle(fontSize: 12))),
      ),
    );

    if (isToday && !claimedToday) {
      return GlowPulseWidget(
        glowColor: AppColors.primary,
        maxBlurRadius: 15,
        child: circle,
      );
    }

    return circle;
  }
}
