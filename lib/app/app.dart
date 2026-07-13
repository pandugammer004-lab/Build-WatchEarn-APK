import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import '../core/constants/app_strings.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/main_navigation.dart';
import '../screens/earn/earn_screen.dart';
import '../screens/earn/spin_wheel_screen.dart';
import '../screens/earn/scratch_card_screen.dart';
import '../screens/earn/mystery_box_screen.dart';
import '../screens/earn/daily_goals_screen.dart';
import '../screens/referral/referral_screen.dart';
import '../screens/vip/vip_plans_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/wallet/withdraw_screen.dart';
import '../screens/leaderboard/leaderboard_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/legal/legal_screen.dart';

class SatisfyMeApp extends StatelessWidget {
  const SatisfyMeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const MainNavigation(),
        '/earn': (context) => const EarnScreen(),
        '/spin': (context) => const SpinWheelScreen(),
        '/scratch': (context) => const ScratchCardScreen(),
        '/mystery': (context) => const MysteryBoxScreen(),
        '/daily-goals': (context) => const DailyGoalsScreen(),
        '/referral': (context) => const ReferralScreen(),
        '/vip': (context) => const VipPlansScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/withdraw': (context) => const WithdrawScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/help': (context) => const HelpScreen(),
        '/legal': (context) => const LegalScreen(title: 'Terms of Service', url: 'https://watchearn.app/terms'),
      },
    );
  }
}
