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
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({Key? key}) : super(key: key);

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  StreamController<int> selected = StreamController<int>();
  bool _isSpinning = false;
  int _currentPrize = 0;
  bool _usedPremiumSpin = false;
  Timer? _countdownTimer;
  String _timeRemaining = '';
  
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMuted = prefs.getBool('spin_muted') ?? false;
    });
  }

  Future<void> _toggleMute() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMuted = !_isMuted;
      prefs.setBool('spin_muted', _isMuted);
    });
  }

  void _playSound(String type) async {
    if (_isMuted) return;
    try {
      if (type == 'spin') {
        // We will just use HapticFeedback for ticks if no mp3, or play a placeholder sound
        await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/foley/spin_wheel_fast.ogg'));
      } else if (type == 'win') {
        await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/cartoon/clown_horn.ogg'));
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }
  
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
    _countdownTimer?.cancel();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _spin(BuildContext context, bool hasFreeSpin, bool hasPremium) {
    if (_isSpinning) return;
    
    if (!hasFreeSpin && !hasPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No spins available! Wait for timer or invite friends.')),
      );
      return;
    }
    
    final earnProvider = Provider.of<EarnProvider>(context, listen: false);
    
    setState(() {
      _isSpinning = true;
      _usedPremiumSpin = hasPremium;
    });

    _playSound('spin');
    HapticFeedback.mediumImpact();

    _currentPrize = earnProvider.getSpinWheelPrize(_usedPremiumSpin);
    final index = earnProvider.getSpinIndexForPrize(_currentPrize);
    
    selected.add(index);
  }

  void _onAnimationEnd() async {
    if (!mounted) return;
    
    setState(() {
      _isSpinning = false;
    });

    _playSound('win');
    HapticFeedback.heavyImpact();
    _confettiController.play();

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Award Prize Securely
    if (userProvider.user != null) {
      try {
        await userProvider.claimSpinReward(_currentPrize, _usedPremiumSpin);
        if (mounted) {
          CoinEarnedAnimation.show(context, coins: _currentPrize, source: _usedPremiumSpin ? 'Premium Spin' : 'Lucky Spin');
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
          '🎰 Lucky Spin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
            onPressed: _toggleMute,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
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
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final user = userProvider.user;
              final lastSpin = user?.lastSpinDate;
              bool hasFreeSpin = false;
              if (lastSpin == null) {
                hasFreeSpin = true;
              } else {
                final diff = DateTime.now().difference(lastSpin);
                if (diff.inHours >= 12) hasFreeSpin = true;
                else {
                  final remaining = const Duration(hours: 12) - diff;
                  final h = remaining.inHours.toString().padLeft(2, '0');
                  final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
                  final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
                  _timeRemaining = '$h:$m:$s';
                }
              }
              final int premiumSpins = user?.premiumSpins ?? 0;
              final bool hasPremium = premiumSpins > 0;
              
              return Column(
                children: [
                  if (hasPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purple)),
                      child: Text('✨ $premiumSpins Premium Spins Available ✨', style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                    )
                  else if (hasFreeSpin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                      child: const Text('1 Daily Free Spin Available', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('Next Free Spin in: $_timeRemaining', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 340,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 50, spreadRadius: 20)],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: FortuneWheel(
                            selected: selected.stream,
                            animateFirst: false,
                            onAnimationEnd: _onAnimationEnd,
                            physics: CircularPanPhysics(duration: const Duration(seconds: 1), curve: Curves.decelerate),
                            items: [
                              for (int i = 0; i < _prizes.length; i++)
                                FortuneItem(
                                  child: Text('${_prizes[i]} 🪙', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  style: FortuneItemStyle(color: _colors[i], borderColor: Colors.amber, borderWidth: 2),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle, border: Border.all(color: Colors.amber, width: 4)),
                          child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.amber, size: 30)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: ElevatedButton(
                      onPressed: _isSpinning ? null : () => _spin(context, hasFreeSpin, hasPremium),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasPremium ? Colors.purpleAccent : (hasFreeSpin ? Colors.amber : Colors.grey),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 10,
                        shadowColor: (hasPremium ? Colors.purple : Colors.amber).withOpacity(0.5),
                      ),
                      child: Text(
                        _isSpinning ? 'SPINNING...' : (hasPremium ? 'SPIN PREMIUM' : (hasFreeSpin ? 'SPIN NOW' : 'WAIT FOR TIMER')),
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!hasFreeSpin && !hasPremium)
                    Consumer<AdProvider>(
                      builder: (context, adProvider, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: ElevatedButton.icon(
                            onPressed: _isSpinning ? null : () async {
                              final reward = await adProvider.showRewardedAd();
                              if (reward > 0) {
                                _spin(context, true, false);
                              }
                            },
                            icon: const Icon(Icons.ondemand_video, color: Colors.white),
                            label: const Text('Watch Ad for Free Spin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                        );
                      }
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Invite Friends for Premium Spins!',
              style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 40),
            ],
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
