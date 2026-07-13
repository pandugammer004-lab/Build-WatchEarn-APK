import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'gradient_text.dart';
import 'animations/coin_particle_widget.dart';

class CoinEarnedAnimation extends StatefulWidget {
  final int coins;
  final String source;
  final VoidCallback onComplete;

  const CoinEarnedAnimation({
    Key? key,
    required this.coins,
    required this.source,
    required this.onComplete,
  }) : super(key: key);

  static void show(BuildContext context, {required int coins, required String source}) {
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => CoinEarnedAnimation(
        coins: coins,
        source: source,
        onComplete: () {
          overlayEntry.remove();
        },
      ),
    );
    
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  State<CoinEarnedAnimation> createState() => _CoinEarnedAnimationState();
}

class _CoinEarnedAnimationState extends State<CoinEarnedAnimation> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _confettiController.play();
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: CoinParticleWidget(),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // Straight down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [Colors.amber, Colors.orange, AppColors.primary, Colors.white],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  duration: const Duration(milliseconds: 500),
                  child: Spin(
                    duration: const Duration(milliseconds: 1000),
                    spins: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.monetization_on,
                        size: 80,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: GradientText(
                    '+${widget.coins} Coins!',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    'from ${widget.source}',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
