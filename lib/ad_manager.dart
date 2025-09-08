import 'package:google_mobile_ads/google_mobile_ads.dart';

//📝 주요 설명
//initialize() : 앱 시작 시 한 번 호출, Google Ads SDK 초기화 + 인터스티셜 광고 미리 로드
//getBannerWidget() : 배너 광고용 위젯 리턴 (UI에 붙일 때 사용)
//showInterstitialAd() : 전면 광고 보여주기
//광고 단위 ID는 반드시 실제 AdMob 콘솔에서 발급받아 변경하세요! 위 예제는 테스트용 ID입니다.


class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() {
    return _instance;
  }

  AdManager._internal();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;

  // 실제 Google AdMob 광고 단위 ID (테스트 ID로 대체 가능)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';       // 테스트 배너 ID
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // 테스트 전면광고 ID

  void initialize() {
    if (!_isInitialized) {
      MobileAds.instance.initialize().then((InitializationStatus status) {
        _isInitialized = true;
        _loadInterstitialAd();
      });
    }
  }

  // 배너 광고 위젯 반환
  BannerAd getBannerAd() {
    final BannerAd banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => print('Banner Ad loaded.'),
        onAdFailedToLoad: (ad, error) {
          print('Banner Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    banner.load();
    return banner;
  }

  // 배너 광고용 Flutter 위젯 반환 (위젯 트리에서 사용)
  Widget getBannerWidget() {
    final BannerAd bannerAd = getBannerAd();

    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
          print('Interstitial Ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial Ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _loadInterstitialAd();  // 다음 광고 준비
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('Interstitial ad is not ready yet.');
    }
  }
}
