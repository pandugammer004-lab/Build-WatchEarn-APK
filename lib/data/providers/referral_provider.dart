import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/referral_model.dart';
import '../services/firestore_service.dart';

class ReferralProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> validateReferralCode(String code) async {
    _isLoading = true;
    notifyListeners();
    // Simulate validation
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    // Assume all codes are valid for demo except empty
    return code.isNotEmpty;
  }

  Future<bool> applyReferral(UserModel newUser, String referralCode) async {
    // 1. Find referrer by code
    // 2. Create referral document
    // 3. Add 500 coins to new user
    // 4. Add 500 coins to referrer
    // 5. Update referrer totalReferrals
    return true; // Simulate success
  }

  Future<void> processCommission(UserModel referredUser, int earnedCoins) async {
    // 10% commission
    final commission = (earnedCoins * 0.1).floor();
    if (commission <= 0) return;
    
    // 1. Find referrer from referral doc
    // 2. Add commission to referrer coins
    // 3. Add commission transaction
  }

  Future<void> checkMilestones(UserModel referrer) async {
    final refs = referrer.totalReferrals;
    if (refs == 5 || refs == 10 || refs == 25 || refs == 50 || refs == 100) {
      // Award milestone coins and badge
    }
  }
}
