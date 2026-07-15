import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/services/firestore_service.dart';

class VipProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  bool _isPurchasing = false;

  bool get isPurchasing => _isPurchasing;

  Future<bool> purchasePlan(UserModel user, String planId, String trxId, String paymentMethod) async {
    _isPurchasing = true;
    notifyListeners();

    try {
      await _firestore.firestore.collection('vip_requests').add({
        'userId': user.uid,
        'userEmail': user.email,
        'planId': planId,
        'trxId': trxId,
        'paymentMethod': paymentMethod,
        'status': 'pending', // pending, approved, rejected
        'createdAt': FieldValue.serverTimestamp(),
      });
      _isPurchasing = false;
      notifyListeners();
      return true; 
    } catch (e) {
      debugPrint("Error submitting VIP request: $e");
      _isPurchasing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restorePurchases(UserModel user) async {
    _isPurchasing = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 2));
    
    _isPurchasing = false;
    notifyListeners();
    return true;
  }

  Future<void> checkVipExpiry(UserModel user) async {
    if (!user.isVip) return;
    
    if (user.vipExpiry != null && user.vipExpiry!.isBefore(DateTime.now())) {
      // Revert to free
      // Send notification
    }
  }
}
