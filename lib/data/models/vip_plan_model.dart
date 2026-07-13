import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VipPlanModel {
  final String id;
  final String name;
  final String badge;
  final double price;
  final int durationDays;
  final int multiplier;
  final List<String> features;
  final LinearGradient gradient;
  final Color color;
  final bool isPopular;
  final String productId;

  VipPlanModel({
    required this.id,
    required this.name,
    required this.badge,
    required this.price,
    required this.durationDays,
    required this.multiplier,
    required this.features,
    required this.gradient,
    required this.color,
    required this.isPopular,
    required this.productId,
  });

  String get durationText {
    if (durationDays >= 36500) return 'Lifetime';
    if (durationDays >= 30) return '${durationDays ~/ 30} Months';
    return '$durationDays Days';
  }

  String get priceText => '\$${price.toStringAsFixed(2)}';

  static List<VipPlanModel> getAllPlans() {
    return [
      VipPlanModel(
        id: 'silver',
        name: 'Silver',
        badge: '🥈',
        price: 9.99,
        durationDays: 30,
        multiplier: 3,
        features: ['3x Coins Multiplier', 'Ad-free Experience', 'Priority Support'],
        gradient: AppColors.silverGradient,
        color: AppColors.vipSilver,
        isPopular: false,
        productId: 'com.watchearn.app.vip.silver',
      ),
      VipPlanModel(
        id: 'gold',
        name: 'Gold',
        badge: '🥇',
        price: 19.99,
        durationDays: 30,
        multiplier: 5,
        features: ['5x Coins Multiplier', 'Ad-free Experience', 'Priority Support', 'Exclusive Videos'],
        gradient: AppColors.goldGradient,
        color: AppColors.vipGold,
        isPopular: true,
        productId: 'com.watchearn.app.vip.gold',
      ),
      VipPlanModel(
        id: 'platinum',
        name: 'Platinum',
        badge: '🌟',
        price: 34.99,
        durationDays: 60,
        multiplier: 7,
        features: ['7x Coins Multiplier', 'Ad-free Experience', 'Priority Support', 'Exclusive Videos', 'Early Access'],
        gradient: AppColors.platinumGradient,
        color: AppColors.vipPlatinum,
        isPopular: false,
        productId: 'com.watchearn.app.vip.platinum',
      ),
      VipPlanModel(
        id: 'diamond',
        name: 'Diamond',
        badge: '💎',
        price: 49.99,
        durationDays: 90,
        multiplier: 10,
        features: ['10x Coins Multiplier', 'Ad-free Experience', 'VIP Badge', 'All Features Unlocked'],
        gradient: AppColors.diamondGradient,
        color: AppColors.vipDiamond,
        isPopular: false,
        productId: 'com.watchearn.app.vip.diamond',
      ),
      VipPlanModel(
        id: 'lifetime',
        name: 'Lifetime',
        badge: '👑',
        price: 99.99,
        durationDays: 36500,
        multiplier: 15,
        features: ['15x Coins Multiplier', 'Ad-free Experience', 'Lifetime VIP Badge', 'All Features Unlocked', 'Beta Features'],
        gradient: AppColors.primaryGradient,
        color: AppColors.primary,
        isPopular: false,
        productId: 'com.watchearn.app.vip.lifetime',
      ),
    ];
  }
}
