import 'package:flutter/material.dart';
import '../../core/services/ad_service.dart';
import '../../core/constants/app_config.dart';

// AdProvider stub - returns empty widgets when ads are disabled
class AdProvider extends ChangeNotifier {
  final AdService _adService = AdService();

  bool get isBannerLoaded => false;
  bool get isInterstitialLoaded => false;
  bool get isRewardedLoaded => false;
  int _videoCountForAd = 0;
  int get videoCountForAd => _videoCountForAd;

  AdProvider() {
    _adService.initialize();
  }

  Future<void> loadBannerAd() async {}
  Future<void> loadInterstitialAd() async {}
  Future<void> loadRewardedAd() async {}
  Future<void> showInterstitialAd() async {}
  Future<int> showRewardedAd() async => 0;
  void disposeBannerAd() {}

  void incrementVideoCount() {
    _videoCountForAd++;
    notifyListeners();
  }

  bool shouldShowInterstitial(bool isVip) {
    final limit = isVip ? AppConfig.vipAdsAfterVideos : AppConfig.adsAfterVideos;
    if (_videoCountForAd >= limit) {
      _videoCountForAd = 0;
      return true;
    }
    return false;
  }

  Widget buildBannerAdWidget() => const SizedBox.shrink();
}
