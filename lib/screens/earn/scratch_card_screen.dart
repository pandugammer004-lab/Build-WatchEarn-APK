import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/coin_earned_animation.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/earn_provider.dart';
import '../../data/providers/ad_provider.dart';

class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({Key? key}) : super(key: key);

  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen> {
  // We'll use a placeholder for the actual Scratch widget logic
  // Typically achieved using the scratcher package in production.
  
  bool _isScratched = false;
  int _prize = 0;
  String _cardType = 'bronze';
  int _remainingCards = 3;

  @override
  void initState() {
    super.initState();
    _initCard();
  }

  void _initCard() {
    final earnProvider = Provider.of<EarnProvider>(context, listen: false);
    _cardType = earnProvider.getRandomScratchCardType();
    _prize = earnProvider.getScratchCardPrize(_cardType);
    _isScratched = false;
  }

  Color _getCardColor() {
    switch (_cardType) {
      case 'bronze': return const Color(0xFFCD7F32);
      case 'silver': return const Color(0xFFC0C0C0);
      case 'gold': return const Color(0xFFFFD700);
      case 'diamond': return const Color(0xFF00BFFF);
      default: return Colors.grey;
    }
  }

  void _handleScratchComplete() async {
    if (_isScratched) return;
    
    setState(() {
      _isScratched = true;
      _remainingCards--;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final earnProvider = Provider.of<EarnProvider>(context, listen: false);

    await earnProvider.logScratch(userProvider.user!, _prize, _cardType);
    await userProvider.updateCoins(_prize, 'Scratch Card');

    CoinEarnedAnimation.show(context, coins: _prize, source: 'Scratch Card');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '🎫 Scratch & Win',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scratch to reveal your reward',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '$_remainingCards of 3 cards remaining',
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // Placeholder for Scratch Card Widget
            // Replace with actual Scratcher widget from scratcher package
            GestureDetector(
              onTap: _handleScratchComplete, // Simulating scratch
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: _isScratched ? AppColors.cardColor : _getCardColor(),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getCardColor(), width: 2),
                ),
                child: Center(
                  child: _isScratched
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('YOU WON!', style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(
                              '$_prize 🪙',
                              style: GoogleFonts.poppins(
                                color: Colors.amber,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.touch_app, color: Colors.white54, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to Scratch', // Actually would be scratch in real implementation
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            if (_isScratched && _remainingCards > 0)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initCard();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Next Card →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            if (_remainingCards == 0 && _isScratched)
              const Text('Come back tomorrow for more cards!', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
