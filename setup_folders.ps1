$directories = @(
    "lib/app",
    "lib/core/constants",
    "lib/core/services",
    "lib/core/utils",
    "lib/core/widgets",
    "lib/data/models",
    "lib/data/providers",
    "lib/screens/splash",
    "lib/screens/onboarding",
    "lib/screens/auth",
    "lib/screens/home",
    "lib/screens/player",
    "lib/screens/explore",
    "lib/screens/earn",
    "lib/screens/referral",
    "lib/screens/vip",
    "lib/screens/wallet",
    "lib/screens/leaderboard",
    "lib/screens/achievements",
    "lib/screens/profile",
    "lib/screens/settings",
    "lib/screens/notifications",
    "lib/admin",
    "assets/images",
    "assets/icons",
    "assets/animations"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$files = @(
    "lib/core/services/auth_service.dart",
    "lib/core/services/firestore_service.dart",
    "lib/core/services/ad_service.dart",
    "lib/core/services/notification_service.dart",
    "lib/core/services/purchase_service.dart",
    "lib/core/utils/helpers.dart",
    "lib/core/utils/validators.dart",
    "lib/data/models/user_model.dart",
    "lib/data/models/video_model.dart",
    "lib/data/models/category_model.dart",
    "lib/data/models/transaction_model.dart",
    "lib/data/models/referral_model.dart",
    "lib/data/models/vip_plan_model.dart",
    "lib/data/models/daily_goal_model.dart",
    "lib/data/models/badge_model.dart",
    "lib/data/models/notification_model.dart",
    "lib/data/models/leaderboard_model.dart",
    "lib/data/providers/auth_provider.dart",
    "lib/data/providers/user_provider.dart",
    "lib/data/providers/video_provider.dart",
    "lib/data/providers/coin_provider.dart",
    "lib/data/providers/referral_provider.dart",
    "lib/data/providers/vip_provider.dart",
    "lib/data/providers/earn_provider.dart",
    "lib/data/providers/ad_provider.dart",
    "lib/screens/splash/splash_screen.dart",
    "lib/screens/onboarding/onboarding_screen.dart",
    "lib/screens/auth/login_screen.dart",
    "lib/screens/auth/signup_screen.dart",
    "lib/screens/auth/forgot_password_screen.dart",
    "lib/screens/home/home_screen.dart",
    "lib/screens/home/main_navigation.dart",
    "lib/screens/player/video_player_screen.dart",
    "lib/screens/explore/explore_screen.dart",
    "lib/screens/explore/category_videos_screen.dart",
    "lib/screens/earn/earn_screen.dart",
    "lib/screens/earn/spin_wheel_screen.dart",
    "lib/screens/earn/scratch_card_screen.dart",
    "lib/screens/earn/mystery_box_screen.dart",
    "lib/screens/earn/daily_goals_screen.dart",
    "lib/screens/referral/referral_screen.dart",
    "lib/screens/vip/vip_plans_screen.dart",
    "lib/screens/wallet/wallet_screen.dart",
    "lib/screens/wallet/withdraw_screen.dart",
    "lib/screens/leaderboard/leaderboard_screen.dart",
    "lib/screens/achievements/achievements_screen.dart",
    "lib/screens/profile/profile_screen.dart",
    "lib/screens/profile/edit_profile_screen.dart",
    "lib/screens/settings/settings_screen.dart",
    "lib/screens/notifications/notifications_screen.dart",
    "lib/admin/admin_app.dart",
    "lib/admin/admin_login.dart",
    "lib/admin/admin_dashboard.dart",
    "lib/admin/admin_videos.dart",
    "lib/admin/admin_users.dart",
    "lib/admin/admin_categories.dart",
    "lib/admin/admin_withdrawals.dart",
    "lib/admin/admin_notifications.dart",
    "lib/admin/admin_analytics.dart"
)

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        # Create dummy class based on filename to avoid errors
        $basename = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $className = (Get-Culture).TextInfo.ToTitleCase($basename.Replace("_", " ")).Replace(" ", "")
        
        $content = ""
        if ($file -match "/screens/" -or $file -match "/admin/") {
            $content = "import 'package:flutter/material.dart';`n`nclass $className extends StatelessWidget {`n  const $className({Key? key}) : super(key: key);`n`n  @override`n  Widget build(BuildContext context) {`n    return const Scaffold(body: Center(child: Text('$className')));`n  }`n}"
        } elseif ($file -match "/providers/") {
            $content = "import 'package:flutter/material.dart';`n`nclass $className extends ChangeNotifier {`n}"
        } else {
            $content = "class $className {`n}"
        }
        
        Set-Content -Path $file -Value $content
    }
}
