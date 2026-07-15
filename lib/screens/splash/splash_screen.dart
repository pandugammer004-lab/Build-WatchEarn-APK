import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_text.dart';
import '../../core/widgets/animations/fade_in_widget.dart';
import '../../core/widgets/animations/scale_in_widget.dart';
import '../../core/widgets/animations/slide_in_widget.dart';
import '../../core/widgets/animations/coin_particle_widget.dart';
import '../../data/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      if (!kIsWeb) {
        await Future.delayed(const Duration(seconds: 3));
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final bool isFirstTime = prefs.getBool('is_first_time') ?? true;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (isFirstTime) {
        await prefs.setBool('is_first_time', false);
        if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
      } else if (authProvider.isLoggedIn) {
        if (mounted) Navigator.pushReplacementNamed(context, '/home'); // fixed from /main
      } else {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background particles
          const Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: CoinParticleWidget(),
            ),
          ),
          
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleInWidget(
                  duration: const Duration(milliseconds: 800),
                  child: FadeInWidget(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/logo.jpg',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUpWidget(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 500),
                  child: GradientText(
                    'WatchEarn',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInWidget(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Watch. Earn. Repeat.',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Loading bar at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: SlideInWidget(
              direction: SlideDirection.up,
              delay: const Duration(milliseconds: 800),
              duration: const Duration(milliseconds: 400),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
