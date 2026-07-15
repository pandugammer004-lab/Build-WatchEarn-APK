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

  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;

  int _videoCountForAd = 0;
  int get videoCountForAd => _videoCountForAd;

  AdProvider() {
    _adService.initialize();
  }

  Future<void> loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAd = ad as BannerAd;
          _isBannerLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: AdService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (err) {
          debugPrint('InterstitialAd failed to load: $err');
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: AdService.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (err) {
          debugPrint('RewardedAd failed to load: $err');
          _isRewardedLoaded = false;
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialLoaded = false;
          loadInterstitialAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _isInterstitialLoaded = false;
          loadInterstitialAd();
        },
      );
      await _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  Future<int> showRewardedAd() async {
    int rewardAmount = 0;
    if (_isRewardedLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedLoaded = false;
          loadRewardedAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _isRewardedLoaded = false;
          loadRewardedAd();
        },
      );
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          rewardAmount = reward.amount.toInt();
          // Use AppConfig.coinsPerAd if reward config is zero or default 1
          if (rewardAmount <= 1) rewardAmount = AppConfig.coinsPerAd;
        },
      );
      _rewardedAd = null;
    }
    return rewardAmount;
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _isBannerLoaded = false;
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
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
