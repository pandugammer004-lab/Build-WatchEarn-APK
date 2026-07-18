import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/coin_earned_animation.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/earn_provider.dart';

class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({Key? key}) : super(key: key);

  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen> {
  bool _isScratched = false;
  int _prize = 0;
  String _cardType = 'bronze';
  Timer? _countdownTimer;
  String _timeRemaining = '';
  
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final scratchKey = GlobalKey<ScratcherState>();

  @override
  void initState() {
    super.initState();
    _initCard();
    _startTimer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }
  
  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _confettiController.dispose();
    _audioPlayer.dispose();
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

  void _playSound(String type) async {
    try {
      if (type == 'scratch') {
        await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/foley/paper_rustle.ogg'));
      } else if (type == 'win') {
        await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/cartoon/clown_horn.ogg'));
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _handleScratchComplete() async {
    if (_isScratched) return;
    
    setState(() {
      _isScratched = true;
    });

    _playSound('win');
    HapticFeedback.heavyImpact();
    _confettiController.play();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.user != null) {
      try {
        await userProvider.claimScratchCardReward(_prize);
        if (mounted) {
          CoinEarnedAnimation.show(context, coins: _prize, source: 'Scratch Card');
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to claim prize', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
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
                        
                        if (hasFreeScratch)
                          Scratcher(
                            key: scratchKey,
                            brushSize: 40,
                            threshold: 70,
                            color: _getCardColor(),
                            onThreshold: () => scratchKey.currentState?.reveal(duration: const Duration(milliseconds: 500)),
                            onScratchStart: () {
                              HapticFeedback.lightImpact();
                              _playSound('scratch');
                            },
                            onScratchEnd: () {
                              _audioPlayer.stop();
                            },
                            onChange: (value) {
                              if (value >= 70 && !_isScratched) {
                                _handleScratchComplete();
                              }
                            },
                            child: Container(
                              width: 300,
                              height: 200,
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Column(
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
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 300,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey, width: 2),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock, color: Colors.white54, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Locked',
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
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ],
      ),
    );
  }
}
