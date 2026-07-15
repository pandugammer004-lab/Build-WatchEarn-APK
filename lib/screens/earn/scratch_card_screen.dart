import 'dart:async';
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
  Timer? _countdownTimer;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    _initCard();
    _startTimer();
  }
  
  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
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
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lastScratch = userProvider.user?.lastScratchDate;
    
    if (lastScratch != null && DateTime.now().difference(lastScratch).inHours < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wait for the timer to expire!')),
      );
      return;
    }
    
    setState(() {
      _isScratched = true;
    });

    final earnProvider = Provider.of<EarnProvider>(context, listen: false);

    await earnProvider.logScratch(userProvider.user!, _prize, _cardType);
    await userProvider.updateCoins(_prize, 'Scratch Card');
    await userProvider.updateScratchState();

    if (mounted) {
      CoinEarnedAnimation.show(context, coins: _prize, source: 'Scratch Card');
    }
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
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final user = userProvider.user;
                final lastScratch = user?.lastScratchDate;
                bool hasFreeScratch = false;
                
                if (lastScratch == null) {
                  hasFreeScratch = true;
                } else {
                  final diff = DateTime.now().difference(lastScratch);
                  if (diff.inHours >= 12) hasFreeScratch = true;
                  else {
                    final remaining = const Duration(hours: 12) - diff;
                    final h = remaining.inHours.toString().padLeft(2, '0');
                    final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
                    final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
                    _timeRemaining = '$h:$m:$s';
                  }
                }
                
                return Column(
                  children: [
                    if (hasFreeScratch)
                      const Text(
                        '1 Card Available Today',
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text('Next Card in: $_timeRemaining', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    
                    const SizedBox(height: 40),
                    
                    GestureDetector(
                      onTap: hasFreeScratch ? _handleScratchComplete : () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please wait for the timer!')));
                      },
                      child: Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          color: _isScratched ? AppColors.cardColor : (hasFreeScratch ? _getCardColor() : Colors.grey),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: hasFreeScratch ? _getCardColor() : Colors.grey, width: 2),
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
                                    Icon(hasFreeScratch ? Icons.touch_app : Icons.lock, color: Colors.white54, size: 48),
                                    const SizedBox(height: 8),
                                    Text(
                                      hasFreeScratch ? 'Tap to Scratch' : 'Locked',
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
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
