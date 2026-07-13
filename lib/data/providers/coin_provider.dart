import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/daily_goal_model.dart';
import '../models/badge_model.dart';
import '../../core/constants/app_config.dart';

class CoinProvider extends ChangeNotifier {
  int _videoCount = 0;
  bool _showCoinAnimation = false;
  int _lastEarnedCoins = 0;
  String _lastEarnedSource = '';

  int get videoCount => _videoCount;
  bool get showCoinAnimation => _showCoinAnimation;
  int get lastEarnedCoins => _lastEarnedCoins;
  String get lastEarnedSource => _lastEarnedSource;

  Future<int> earnFromVideo(UserModel user) async {
    // Check limits
    final maxDailyCoins = user.isVip ? double.infinity : 1000;
    if (user.dailyVideosWatched >= 100) return 0;
    // Check if free user exceeded daily coin limit
    // Ignoring full logic here for simplicity, focusing on calculation
    
    int baseCoins = 10;
    int multiplier = _getVipMultiplier(user.vipPlan);
    int earned = baseCoins * multiplier;

    triggerCoinAnimation(earned, 'Video Watched');
    return earned;
  }

  Future<int> earnFromAd(UserModel user) async {
    int earned = 15 * _getVipMultiplier(user.vipPlan);
    triggerCoinAnimation(earned, 'Ad Watched');
    return earned;
  }

  int _getVipMultiplier(String plan) {
    switch (plan) {
      case 'silver': return 3;
      case 'gold': return 5;
      case 'platinum': return 7;
      case 'diamond': return 10;
      case 'lifetime': return 15;
      default: return 1;
    }
  }

  Future<int> claimDailyBonus(UserModel user) async {
    int earned = 50 * user.streak;
    triggerCoinAnimation(earned, 'Daily Bonus');
    return earned;
  }

  Future<int> claimGoalReward(DailyGoalModel goal, UserModel user) async {
    final coins = goal.reward * _getVipMultiplier(user.vipPlan);
    triggerCoinAnimation(coins, 'Goal Completed');
    return coins;
  }

  Future<int> claimBadgeReward(BadgeModel badge, UserModel user) async {
    final coins = badge.reward;
    triggerCoinAnimation(coins, 'Badge Unlocked');
    return coins;
  }

  Future<int> claimMilestoneReward(int milestone, UserModel user) async {
    return 1000;
  }

  Future<bool> processWithdrawal(UserModel user, double amount, String method, String email) async {
    return true;
  }

  void incrementVideoCount() {
    _videoCount++;
    notifyListeners();
  }

  bool shouldShowAd(UserModel user) {
    final limit = user.isVip ? 8 : 4;
    if (_videoCount >= limit) {
      _videoCount = 0;
      return true;
    }
    return false;
  }

  void triggerCoinAnimation(int coins, String source) {
    _lastEarnedCoins = coins;
    _lastEarnedSource = source;
    _showCoinAnimation = true;
    notifyListeners();
    
    Future.delayed(const Duration(seconds: 2), () {
      clearAnimation();
    });
  }

  void clearAnimation() {
    _showCoinAnimation = false;
    notifyListeners();
  }
}
