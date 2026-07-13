import 'package:flutter/material.dart';

class AppColors {
  // Single Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color accent = Color(0xFF00D9FF);
  static const Color gold = Color(0xFFFFD700);
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252542);
  static const Color cardColor = Color(0xFF1E1E32);
  static const Color cardBorder = Color(0xFF2A2A4A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D0);
  static const Color textTertiary = Color(0xFF7A7A9A);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D9FF), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient silverGradient = LinearGradient(
    colors: [Color(0xFFC0C0C0), Color(0xFF808080)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient platinumGradient = LinearGradient(
    colors: [Color(0xFFE5E4E2), Color(0xFFBDBDBD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient diamondGradient = LinearGradient(
    colors: [Color(0xFFB9F2FF), Color(0xFF81D4FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // VIP Colors
  static const Color vipSilver = Color(0xFFC0C0C0);
  static const Color vipGold = Color(0xFFFFD700);
  static const Color vipPlatinum = Color(0xFFE5E4E2);
  static const Color vipDiamond = Color(0xFFB9F2FF);

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primary.withOpacity(0.3),
          blurRadius: 15,
          spreadRadius: 2,
        )
      ];
}
