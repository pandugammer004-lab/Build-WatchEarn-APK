import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/gradient_text.dart';
import '../../core/widgets/animations/fade_in_widget.dart';
import '../../core/widgets/animations/scale_in_widget.dart';
import '../../core/widgets/animations/slide_in_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Watch Amazing Videos',
      description: 'Discover thousands of satisfying and relaxing videos updated daily for your enjoyment.',
      icon: Icons.play_circle_fill_rounded,
      accentColor: const Color(0xFF00D9FF),
    ),
    OnboardingSlide(
      title: 'Earn Real Rewards',
      description: 'Every video you watch earns you coins. Complete daily goals and challenges for bonus rewards.',
      icon: Icons.monetization_on_rounded,
      accentColor: const Color(0xFFFFD700),
    ),
    OnboardingSlide(
      title: 'Cash Out Anytime',
      description: 'Convert your coins to real cash via PayPal, Amazon Gift Cards, and more payment methods.',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: const Color(0xFF00E676),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: FadeInWidget(
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleInWidget(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: slide.accentColor.withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: slide.accentColor.withOpacity(0.2),
                              blurRadius: 50,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: Icon(
                          slide.icon,
                          size: 120,
                          color: slide.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    SlideInWidget(
                      direction: SlideDirection.up,
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SlideInWidget(
                      direction: SlideDirection.up,
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: SlideInWidget(
              direction: SlideDirection.up,
              delay: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _slides[_currentPage].accentColor,
                      dotColor: Colors.white24,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (isLastPage) ...[
                    CustomButton(
                      text: 'Start Earning Now →',
                      onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const GradientText(
                        'Already have an account? Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    CustomButton(
                      text: 'Next',
                      onPressed: _nextPage,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
