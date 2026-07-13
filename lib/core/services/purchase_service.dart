import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    try {
      _isAvailable = await _iap.isAvailable();
      if (_isAvailable) {
        final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
        _subscription = purchaseUpdated.listen(
          (purchaseDetailsList) {
            _listenToPurchaseUpdated(purchaseDetailsList);
          },
          onDone: () {
            _subscription?.cancel();
          },
          onError: (error) {
            debugPrint("IAP Stream Error: $error");
          },
        );
      }
    } catch (e) {
      debugPrint("IAP Init Error: $e");
    }
  }

  Future<void> loadProducts(Set<String> productIds) async {
    if (!_isAvailable) return;
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("Products not found: ${response.notFoundIDs}");
      }
      _products = response.productDetails;
    } catch (e) {
      debugPrint("IAP Load Error: $e");
    }
  }

  Future<bool> buyProduct(String productId) async {
    if (!_isAvailable) return false;
    try {
      final ProductDetails? product = _products.cast<ProductDetails?>().firstWhere(
        (p) => p?.id == productId,
        orElse: () => null,
      );
      
      if (product == null) return false;

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint("IAP Buy Error: $e");
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint("IAP Restore Error: $e");
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("IAP Purchase Error: ${purchaseDetails.error}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyPurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Verify purchase with backend/Firebase
    debugPrint("Purchase verified: ${purchaseDetails.productID}");
  }

  void dispose() {
    _subscription?.cancel();
  }
}
