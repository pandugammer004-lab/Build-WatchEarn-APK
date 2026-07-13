class AppConfig {
  // Coin System
  static const int coinsPerVideo = 10;
  static const int coinsPerAd = 15;
  static const int coinsPerReferral = 500;
  static const int coinsPerReferralWatch = 200;
  static const int coinsPerRateApp = 300;
  static const int coinsPerShare = 50;
  static const double coinsPerDollar = 10000.0;

  // Streak Rewards (7 days)
  static const List<int> streakRewards = [25, 35, 50, 65, 80, 100, 200];

  // Daily Goals
  static const List<int> videoGoals = [1, 3, 5, 10, 20, 30];
  static const int adsGoal = 5;
  static const int shareGoal = 1;
  static const int categoriesGoal = 3;

  // Ads
  static const int adsAfterVideos = 4; // free users
  static const int vipAdsAfterVideos = 8; // VIP users

  // Daily Limits
  static const int maxDailySpinsFree = 1;
  static const int maxDailyScratchFree = 3;
  static const int maxDailyMysteryFree = 1;

  // Withdrawal
  static const double minWithdrawal = 5.0;
  static const double vipMinWithdrawal = 2.0;

  // Referral
  static const double referralCommission = 0.10; // 10%
  static const List<int> milestones = [5, 10, 25, 50, 100];
  static const List<int> milestoneRewards = [5000, 15000, 50000, 150000, 500000];

  // VIP
  static const Map<String, int> vipMultipliers = {
    'silver': 3,
    'gold': 5,
    'platinum': 7,
    'diamond': 10,
    'lifetime': 15,
  };

  static const Map<String, double> vipPrices = {
    'silver': 9.99,
    'gold': 19.99,
    'platinum': 34.99,
    'diamond': 49.99,
    'lifetime': 99.99,
  };

  // Spin Wheel
  static const List<int> spinPrizes = [5, 10, 25, 50, 100, 200, 500, 1000];
  static const List<double> spinProbabilities = [0.25, 0.20, 0.18, 0.15, 0.10, 0.07, 0.04, 0.01];
}
