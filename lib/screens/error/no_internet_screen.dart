import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/animations/fade_in_widget.dart';
import '../../core/widgets/animations/scale_in_widget.dart';
import 'dart:async';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isRetrying = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRetry();
  }

  void _startAutoRetry() {
    _retryTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _handleRetry();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    
    // Simulate checking connection
    await Future.delayed(const Duration(seconds: 1));
    
    // Check real connection logic here
    // If connected, navigate back or push replacement
    
    if (mounted) {
      setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleInWidget(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 100,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 40,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FadeInWidget(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'No Internet Connection',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FadeInWidget(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  'Please check your connection and try again',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              FadeInWidget(
                delay: const Duration(milliseconds: 900),
                child: CustomButton(
                  text: 'Retry',
                  isLoading: _isRetrying,
                  onPressed: _handleRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
