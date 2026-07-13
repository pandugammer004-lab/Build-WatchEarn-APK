import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_ids.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      RequestConfiguration config = RequestConfiguration(
        testDeviceIds: <String>[],
      );
      await MobileAds.instance.updateRequestConfiguration(config);
    } catch (e) {
      debugPrint('AdService init error: $e');
    }
  }

  BannerAd getBannerAd({required VoidCallback onLoaded, required VoidCallback onFailed}) {
    return BannerAd(
      adUnitId: AdIds.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed();
          debugPrint('BannerAd failed: $error');
        },
      ),
    );
  }

  Future<void> loadInterstitialAd({
    required Function(InterstitialAd) onLoaded,
    required VoidCallback onFailed,
  }) async {
    try {
      await InterstitialAd.load(
        adUnitId: AdIds.interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
            );
            onLoaded(ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint('InterstitialAd failed: $error');
            onFailed();
          },
        ),
      );
    } catch (e) {
      debugPrint('loadInterstitialAd error: $e');
      onFailed();
    }
  }

  Future<void> loadRewardedAd({
    required Function(RewardedAd) onLoaded,
    required VoidCallback onFailed,
  }) async {
    try {
      await RewardedAd.load(
        adUnitId: AdIds.rewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
            );
            onLoaded(ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint('RewardedAd failed: $error');
            onFailed();
          },
        ),
      );
    } catch (e) {
      debugPrint('loadRewardedAd error: $e');
      onFailed();
    }
  }
}
