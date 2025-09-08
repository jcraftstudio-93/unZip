import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() {
    return _instance;
  }

  AdManager._internal();

  // 실제 앱 등록 시 테스트 ID 대신 본인 광고 단위 ID로 교체해야 함
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';  // 테스트 배너 광고 ID
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // 테스트 전면 광고 ID

  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  void initialize() {
    MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );

    _bannerAd.load();
  }

  BannerAdWidget getBannerWidget() {
    if (_isBannerAdLoaded) {
      return BannerAdWidget(ad: _bannerAd);
    } else {
      return BannerAdWidget.empty();
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
    }
  }
}

// BannerAdWidget 클래스를 분리해서 간편하게 배너 광고 표시하도록 함
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatelessWidget {
  final BannerAd? ad;

  const BannerAdWidget({super.key, this.ad});

  const BannerAdWidget.empty({super.key}) : ad = null;

  @override
  Widget build(BuildContext context) {
    if (ad == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: ad!.size.width.toDouble(),
      height: ad!.size.height.toDouble(),
      child: AdWidget(ad: ad!),
    );
  }
}
