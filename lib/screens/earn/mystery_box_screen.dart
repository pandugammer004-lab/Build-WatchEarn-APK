import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/animations/shake_animation.dart';
import '../../core/widgets/coin_earned_animation.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/earn_provider.dart';
import '../../data/providers/ad_provider.dart';

class MysteryBoxScreen extends StatefulWidget {
  const MysteryBoxScreen({Key? key}) : super(key: key);

  @override
  State<MysteryBoxScreen> createState() => _MysteryBoxScreenState();
}

class _MysteryBoxScreenState extends State<MysteryBoxScreen> {
  bool _isOpen = false;
  bool _isShaking = false;
  String _boxType = 'common';
  int _prize = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final earnProvider = Provider.of<EarnProvider>(context, listen: false);
    
    _boxType = earnProvider.getMysteryBoxType(userProvider.user!);
    _prize = earnProvider.getMysteryBoxPrize(_boxType);
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

  void _openBox() async {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final earnProvider = Provider.of<EarnProvider>(context, listen: false);

    final lastBox = userProvider.user?.lastMysteryBoxDate;
    if (lastBox != null && DateTime.now().difference(lastBox).inHours < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wait for the timer to expire!')),
      );
      return;
    }

    // Play Rewarded Ad before opening
    if (adProvider.isRewardedLoaded) {
      await adProvider.showRewardedAd();
    } else {
      // If no ad loaded, try loading one and proceed or just proceed
      adProvider.loadRewardedAd();
    }

    setState(() {
      _isShaking = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isShaking = false;
      _isOpen = true;
    });

    await earnProvider.logMysteryBox(userProvider.user!, _prize, _boxType);
    await userProvider.updateCoins(_prize, 'Mystery Box');
    await userProvider.updateMysteryBoxState();

    if (mounted) {
      CoinEarnedAnimation.show(context, coins: _prize, source: 'Mystery Box');
    }
  }

  Color _getBoxColor() {
    switch (_boxType) {
      case 'common': return Colors.brown;
      case 'rare': return Colors.blue;
      case 'epic': return Colors.purple;
      case 'legendary': return Colors.amber;
      default: return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Space theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('📦 Mystery Box', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "What's inside? Only one way to find out!",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getBoxColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getBoxColor()),
              ),
              child: Text(
                'Today\'s Box: ${_boxType.toUpperCase()}',
                style: TextStyle(color: _getBoxColor(), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 60),
            
            ShakeAnimation(
              animate: _isShaking,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _isOpen ? Colors.transparent : _getBoxColor().withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isOpen ? [] : [
                    BoxShadow(
                      color: _getBoxColor().withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: Center(
                  child: _isOpen
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎉', style: TextStyle(fontSize: 60)),
                            const SizedBox(height: 16),
                            Text(
                              '+$_prize 🪙',
                              style: GoogleFonts.poppins(
                                color: Colors.amber,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Icon(Icons.help_outline, color: Colors.white, size: 80),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final user = userProvider.user;
                final lastBox = user?.lastMysteryBoxDate;
                bool hasFreeBox = false;
                String timeRemaining = '';
                
                if (lastBox == null) {
                  hasFreeBox = true;
                } else {
                  final diff = DateTime.now().difference(lastBox);
                  if (diff.inHours >= 12) {
                    hasFreeBox = true;
                  } else {
                    final remaining = const Duration(hours: 12) - diff;
                    final h = remaining.inHours.toString().padLeft(2, '0');
                    final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
                    final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
                    timeRemaining = '$h:$m:$s';
                  }
                }
                
                return Column(
                  children: [
                    if (!_isOpen) ...[
                      if (hasFreeBox)
                        ElevatedButton(
                          onPressed: _isShaking ? null : _openBox,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            minimumSize: const Size(250, 60),
                          ),
                          child: Text(
                            _isShaking ? 'OPENING...' : 'OPEN BOX',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: Text(
                            'Next Box in: $timeRemaining',
                            style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Text('Watch Ad to Open', style: TextStyle(color: Colors.white54)),
                    ],
                  ],
                );
              },
            ),
            if (_isOpen)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Great!', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}
