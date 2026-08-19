import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialAdLoading = false;
  bool _isRewardedAdLoading = false;
  String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-9495219818644530/2125318030'
      : 'ca-app-pub-9495219818644530/2125318030';
  String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-9495219818644530/7059603024'
      : 'ca-app-pub-9495219818644530/7059603024';
  String get rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-9495219818644530/8499154699'
      : 'ca-app-pub-9495219818644530/8499154699';
  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadRewardedAd();
  }

  void _loadInterstitialAd() {
    if (_isInterstitialAdLoading || _interstitialAd != null) return;
    _isInterstitialAdLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial Ad loaded.');
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial Ad failed to load: $error');
          _isInterstitialAdLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_interstitialAd == null) {
      debugPrint('Warning: Interstitial ad not ready.');
      onAdClosed?.call();
      _loadInterstitialAd();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
        // Load next ad immediately
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
        onAdClosed?.call();
      },
    );
    _interstitialAd!.show();
  }

  void _loadRewardedAd() {
    if (_isRewardedAdLoading || _rewardedAd != null) return;
    _isRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded Ad loaded.');
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded Ad failed to load: $error');
          _isRewardedAdLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(RewardItem) onRewarded,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) {
    if (_rewardedAd == null) {
      debugPrint('Warning: Rewarded ad not ready.');
      onAdFailed?.call();
      _loadRewardedAd();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        onAdFailed?.call();
      },
    );
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded.call(reward);
      },
    );
  }
}

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});
  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
