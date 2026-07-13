import 'package:flutter/material.dart';

// AdMob stub - google_mobile_ads removed to prevent startup crash
// Will be re-enabled with proper Android project setup
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  Future<void> initialize() async {
    debugPrint('AdService: disabled (add APPLICATION_ID to manifest first)');
  }
}
