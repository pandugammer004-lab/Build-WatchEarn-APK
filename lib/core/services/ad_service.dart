import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_ids.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    // Set test device IDs if needed
    RequestConfiguration config = RequestConfiguration(
      testDeviceIds: <String>[], // Add your test device IDs here
    );
    await MobileAds.instance.updateRequestConfiguration(config);
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
          debugPrint('BannerAd failed to load: $error');
        },
      ),
    );
  }

  Future<void> loadInterstitialAd({
    required Function(InterstitialAd) onLoaded,
    required VoidCallback onFailed,
  }) async {
    await InterstitialAd.load(
      adUnitId: AdIds.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint('InterstitialAd failed to show: $error');
            },
          );
          onLoaded(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          onFailed();
        },
      ),
    );
  }

  Future<void> loadRewardedAd({
    required Function(RewardedAd) onLoaded,
    required VoidCallback onFailed,
  }) async {
    await RewardedAd.load(
      adUnitId: AdIds.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint('RewardedAd failed to show: $error');
            },
          );
          onLoaded(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          onFailed();
        },
      ),
    );
  }
}
