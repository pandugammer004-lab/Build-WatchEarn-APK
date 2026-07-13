import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/ad_service.dart';
import '../../core/constants/app_config.dart';

class AdProvider extends ChangeNotifier {
  final AdService _adService = AdService();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;
  int _videoCountForAd = 0;

  BannerAd? get bannerAd => _bannerAd;
  InterstitialAd? get interstitialAd => _interstitialAd;
  RewardedAd? get rewardedAd => _rewardedAd;
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;
  int get videoCountForAd => _videoCountForAd;

  AdProvider() {
    _adService.initialize();
  }

  Future<void> loadBannerAd() async {
    _bannerAd = _adService.getBannerAd(
      onLoaded: () {
        _isBannerLoaded = true;
        notifyListeners();
      },
      onFailed: () {
        _isBannerLoaded = false;
        notifyListeners();
      },
    );
    await _bannerAd?.load();
  }

  Future<void> loadInterstitialAd() async {
    await _adService.loadInterstitialAd(
      onLoaded: (ad) {
        _interstitialAd = ad;
        _isInterstitialLoaded = true;
        notifyListeners();
      },
      onFailed: () {
        _isInterstitialLoaded = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadRewardedAd() async {
    await _adService.loadRewardedAd(
      onLoaded: (ad) {
        _rewardedAd = ad;
        _isRewardedLoaded = true;
        notifyListeners();
      },
      onFailed: () {
        _isRewardedLoaded = false;
        notifyListeners();
      },
    );
  }

  Future<void> showInterstitialAd() async {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
      _isInterstitialLoaded = false;
      _interstitialAd = null;
      notifyListeners();
      loadInterstitialAd();
    }
  }

  Future<int> showRewardedAd() async {
    int rewardAmount = 0;
    if (_isRewardedLoaded && _rewardedAd != null) {
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          rewardAmount = reward.amount.toInt();
        },
      );
      _isRewardedLoaded = false;
      _rewardedAd = null;
      notifyListeners();
      loadRewardedAd();
    }
    return rewardAmount;
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _isBannerLoaded = false;
    notifyListeners();
  }

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

  Widget buildBannerAdWidget() {
    if (_isBannerLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
