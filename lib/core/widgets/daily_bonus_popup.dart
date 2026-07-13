import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'animations/shake_animation.dart';

class DailyBonusPopup extends StatefulWidget {
  final int day;
  final int coins;
  final VoidCallback onClaim;

  const DailyBonusPopup({Key? key, required this.day, required this.coins, required this.onClaim}) : super(key: key);

  static void show(BuildContext context, {required int day, required int coins, required VoidCallback onClaim}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DailyBonusPopup(day: day, coins: coins, onClaim: onClaim),
    );
  }

  @override
  State<DailyBonusPopup> createState() => _DailyBonusPopupState();
}

class _DailyBonusPopupState extends State<DailyBonusPopup> {
  bool _isOpened = false;

  void _claim() {
    setState(() => _isOpened = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onClaim();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Daily Login Bonus', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Day ${widget.day} Streak!', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            ShakeAnimation(
              animate: !_isOpened,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isOpened
                    ? Column(
                        key: const ValueKey('opened'),
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 80)),
                          const SizedBox(height: 16),
                          Text('+${widget.coins} 🪙', style: GoogleFonts.poppins(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : const Text('🎁', key: ValueKey('closed'), style: TextStyle(fontSize: 100)),
              ),
            ),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isOpened ? null : _claim,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text(_isOpened ? 'Claimed!' : 'Claim Bonus', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
