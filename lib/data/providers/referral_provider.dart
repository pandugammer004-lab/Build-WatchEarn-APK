import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/referral_model.dart';
import '../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> validateReferralCode(String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      final referrer = await _firestore.getUserByReferralCode(code);
      return referrer != null;
    } catch (e) {
      debugPrint("Validation error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyReferral(UserModel newUser, String referralCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      final referrer = await _firestore.getUserByReferralCode(referralCode);
      if (referrer == null) return false;

      // 1. Create referral document
      final refId = 'ref_${DateTime.now().millisecondsSinceEpoch}_${newUser.uid}';
      final referral = ReferralModel(
        id: refId,
        referrerUserId: referrer.uid,
        referredUserId: newUser.uid,
        referredName: newUser.name,
        referredProfilePic: newUser.profilePic,
        referredEmail: newUser.email,
        coinsEarned: 0,
        referredVideosWatched: 0,
        hasPurchasedVip: false,
        status: 'active',
        timestamp: DateTime.now(),
      );
      await _firestore.addReferral(referral);

      // 2. Add 500 coins to new user and set referredBy
      await _firestore.updateUser(newUser.uid, {
        'coins': FieldValue.increment(500),
        'totalEarned': FieldValue.increment(500),
        'referredBy': referrer.uid,
      });

      // 3. Add 1000 coins to referrer and update totalReferrals
      await _firestore.updateUser(referrer.uid, {
        'coins': FieldValue.increment(1000),
        'totalEarned': FieldValue.increment(1000),
        'totalReferrals': FieldValue.increment(1),
        'referralEarnings': FieldValue.increment(1000),
      });

      return true;
    } catch (e) {
      debugPrint("Apply referral error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processCommission(UserModel referredUser, int earnedCoins) async {
    if (referredUser.referredBy.isEmpty) return;

    // 15% commission
    final commission = (earnedCoins * 0.15).floor();
    if (commission <= 0) return;
    
    try {
      await _firestore.updateUser(referredUser.referredBy, {
        'coins': FieldValue.increment(commission),
        'totalEarned': FieldValue.increment(commission),
        'referralEarnings': FieldValue.increment(commission),
      });

      // Update the referral document's coinsEarned
      // This requires querying the referral doc
      final referrals = await _firestore.getReferrals(referredUser.referredBy);
      for (var ref in referrals) {
        if (ref.referredUserId == referredUser.uid) {
          await FirebaseFirestore.instance.collection('referrals').doc(ref.id).update({
            'coinsEarned': FieldValue.increment(commission),
            'lastActivityAt': FieldValue.serverTimestamp(),
          });
          break;
        }
      }
    } catch (e) {
      debugPrint("Process commission error: $e");
    }
  }

  Future<void> checkMilestones(UserModel referrer) async {
    final refs = referrer.totalReferrals;
    int reward = 0;
    if (refs == 5) reward = 5000;
    else if (refs == 10) reward = 12000;
    else if (refs == 25) reward = 35000;
    else if (refs == 50) reward = 80000;
    else if (refs == 100) reward = 200000;

    if (reward > 0) {
      await _firestore.updateUser(referrer.uid, {
        'coins': FieldValue.increment(reward),
        'totalEarned': FieldValue.increment(reward),
        'referralEarnings': FieldValue.increment(reward),
      });
    }
  }
}
