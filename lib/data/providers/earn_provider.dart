import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/user_model.dart';
import '../models/daily_goal_model.dart';
import '../../core/services/firestore_service.dart';

class EarnProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final math.Random _random = math.Random();

  List<DailyGoalModel> _dailyGoals = [
    DailyGoalModel(id: 'g1', title: 'First Video', description: 'Watch 1 video', icon: '🎬', reward: 20, target: 1, current: 0, isClaimed: false, type: 'video'),
    DailyGoalModel(id: 'g2', title: 'Morning Viewer', description: 'Watch 3 videos', icon: '🌅', reward: 40, target: 3, current: 0, isClaimed: false, type: 'video'),
    DailyGoalModel(id: 'g3', title: 'Half Way', description: 'Watch 5 videos', icon: '📈', reward: 60, target: 5, current: 0, isClaimed: false, type: 'video'),
    DailyGoalModel(id: 'g4', title: 'Dedicated', description: 'Watch 10 videos', icon: '👀', reward: 120, target: 10, current: 0, isClaimed: false, type: 'video'),
    DailyGoalModel(id: 'g5', title: 'Ad Supporter', description: 'Watch 5 ads', icon: '📺', reward: 100, target: 5, current: 0, isClaimed: false, type: 'ad'),
  ];
  List<DailyGoalModel> get dailyGoals => _dailyGoals;

  int getSpinWheelPrize(bool isPremium) {
    final double r = _random.nextDouble();
    
    if (isPremium) {
      // Much better chances for Premium Spins
      if (r < 0.10) return 25;
      if (r < 0.30) return 50;
      if (r < 0.60) return 100;
      if (r < 0.80) return 200;
      if (r < 0.95) return 500;
      return 1000;
    }
    
    // Standard Spin chances
    if (r < 0.25) return 5;
    if (r < 0.45) return 10;
    if (r < 0.63) return 25;
    if (r < 0.78) return 50;
    if (r < 0.88) return 100;
    if (r < 0.95) return 200;
    if (r < 0.99) return 500;
    return 1000;
  }

  int getSpinIndexForPrize(int prize) {
    switch (prize) {
      case 5: return 0;
      case 10: return 1;
      case 25: return 2;
      case 50: return 3;
      case 100: return 4;
      case 200: return 5;
      case 500: return 6;
      case 1000: return 7;
      default: return 0;
    }
  }

  int getScratchCardPrize(String cardType) {
    switch (cardType) {
      case 'bronze': return _random.nextInt(21) + 5; // 5-25
      case 'silver': return _random.nextInt(76) + 25; // 25-100
      case 'gold': return _random.nextInt(401) + 100; // 100-500
      case 'diamond': return _random.nextInt(1501) + 500; // 500-2000
      default: return 10;
    }
  }

  String getRandomScratchCardType() {
    final double r = _random.nextDouble();
    if (r < 0.60) return 'bronze';
    if (r < 0.85) return 'silver';
    if (r < 0.97) return 'gold';
    return 'diamond';
  }

  int getMysteryBoxPrize(String boxType) {
    switch (boxType) {
      case 'common': return _random.nextInt(41) + 10; // 10-50
      case 'rare': return _random.nextInt(151) + 50; // 50-200
      case 'epic': return _random.nextInt(801) + 200; // 200-1000
      case 'legendary': return _random.nextInt(4001) + 1000; // 1000-5000
      default: return 25;
    }
  }

  String getMysteryBoxType(UserModel user) {
    if (user.vipPlan == 'free') return 'common';
    if (user.vipPlan == 'silver') return 'rare';
    if (user.vipPlan == 'gold') return 'epic';
    if (user.vipPlan == 'platinum' || user.vipPlan == 'diamond') return 'epic'; // Or legendary with small chance
    if (user.vipPlan == 'lifetime') return 'legendary';
    return 'common';
  }

  Future<void> logSpin(UserModel user, int prize) async {
    // Implement Firestore logging
  }

  Future<void> logScratch(UserModel user, int prize, String type) async {
    // Implement Firestore logging
  }

  Future<void> logMysteryBox(UserModel user, int prize, String type) async {
    // Implement Firestore logging
  }
}
