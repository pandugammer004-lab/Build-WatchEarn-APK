import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/coin_earned_animation.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/earn_provider.dart';
import '../../data/providers/ad_provider.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({Key? key}) : super(key: key);

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  StreamController<int> selected = StreamController<int>();
  bool _isSpinning = false;
  
  final List<int> _prizes = [5, 10, 25, 50, 100, 200, 500, 1000];
  final List<Color> _colors = [
    Colors.grey.shade700,
    Colors.blue.shade600,
    Colors.cyan.shade600,
    Colors.green.shade600,
    Colors.purple.shade600,
    Colors.pink.shade600,
    Colors.orange.shade600,
    Colors.red.shade600,
  ];

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  void _spin(BuildContext context) async {
    if (_isSpinning) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final earnProvider = Provider.of<EarnProvider>(context, listen: false);
    
    // Check spins remaining logic here
    // For demo, assuming they have spins
    
    setState(() {
      _isSpinning = true;
    });

    final prize = earnProvider.getSpinWheelPrize();
    final index = earnProvider.getSpinIndexForPrize(prize);
    
    selected.add(index);
    
    // Wait for spin to finish (usually 5 seconds in flutter_fortune_wheel)
    await Future.delayed(const Duration(seconds: 5));
    
    if (!mounted) return;
    
    setState(() {
      _isSpinning = false;
    });

    // Award Prize
    await earnProvider.logSpin(userProvider.user!, prize);
    await userProvider.updateCoins(prize, 'Lucky Spin');
    
    CoinEarnedAnimation.show(context, coins: prize, source: 'Lucky Spin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '🎰 Lucky Spin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Win up to 1,000 coins!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '1 Free Spin Available',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Neon glow effect behind wheel
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FortuneWheel(
                    selected: selected.stream,
                    animateFirst: false,
                    physics: CircularPanPhysics(
                      duration: const Duration(seconds: 1),
                      curve: Curves.decelerate,
                    ),
                    items: [
                      for (int i = 0; i < _prizes.length; i++)
                        FortuneItem(
                          child: Text(
                            '${_prizes[i]} 🪙',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          style: FortuneItemStyle(
                            color: _colors[i],
                            borderColor: Colors.amber,
                            borderWidth: 2,
                          ),
                        ),
                    ],
                  ),
                ),
                // Center Hub
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 4),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_circle_fill, color: Colors.amber, size: 30),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ElevatedButton(
              onPressed: _isSpinning ? null : () => _spin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: Colors.amber.withOpacity(0.5),
              ),
              child: Text(
                _isSpinning ? 'SPINNING...' : 'SPIN NOW',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Show Ad for extra spin
            },
            child: const Text(
              'Watch Ad to Spin Extra',
              style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
