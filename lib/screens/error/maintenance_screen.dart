import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/animations/fade_in_widget.dart';
import '../../core/widgets/animations/scale_in_widget.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

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
              const ScaleInWidget(
                child: Icon(
                  Icons.build_circle_outlined,
                  size: 120,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              FadeInWidget(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Under Maintenance',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FadeInWidget(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  "We're making WatchEarn better for you. Please check back soon.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              const FadeInWidget(
                delay: Duration(milliseconds: 900),
                child: SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.cardColor,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
              const Spacer(),
              const FadeInWidget(
                delay: Duration(milliseconds: 1200),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
