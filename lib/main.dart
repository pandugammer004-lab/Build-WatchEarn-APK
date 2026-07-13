import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/user_provider.dart';
import 'data/providers/video_provider.dart';
import 'data/providers/coin_provider.dart';
import 'data/providers/referral_provider.dart';
import 'data/providers/vip_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/home/main_navigation.dart';
import 'screens/player/video_player_screen.dart';
import 'screens/explore/category_videos_screen.dart';
import 'screens/earn/earn_screen.dart';
import 'screens/earn/spin_wheel_screen.dart';
import 'screens/earn/scratch_card_screen.dart';
import 'screens/earn/mystery_box_screen.dart';
import 'screens/earn/daily_goals_screen.dart';
import 'screens/referral/referral_screen.dart';
import 'screens/vip/vip_plans_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/wallet/withdraw_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/help/help_screen.dart';
import 'screens/legal/legal_screen.dart';
import 'data/providers/earn_provider.dart';
import 'data/providers/ad_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Assuming options will be added later)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Mobile Ads SDK
  await MobileAds.instance.initialize();

  // Set portrait orientation only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D1A), // Match AppColors.background
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => CoinProvider()),
        ChangeNotifierProvider(create: (_) => ReferralProvider()),
        ChangeNotifierProvider(create: (_) => VipProvider()),
        ChangeNotifierProvider(create: (_) => EarnProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
      ],
      child: const SatisfyMeApp(),
    ),
  );
}
