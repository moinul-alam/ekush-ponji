// lib/core/services/ad_service.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ekush_ponji/app/config/ad_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BANNER NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class BannerLoadedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoaded() => state = true;
  void setUnloaded() => state = false;
}

final bannerLoadedProvider =
    NotifierProvider<BannerLoadedNotifier, bool>(BannerLoadedNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// AD SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class AdService {
  final Ref _ref;

  AdService(this._ref) {
    if (AdConfig.enableBannerAds) _loadBanner();
    if (AdConfig.enableInterstitialAds) _loadInterstitial();
  }

  // ── Banner ────────────────────────────────────────────────────
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  BannerAd? get bannerAd => _bannerLoaded ? _bannerAd : null;

  // ── Interstitial ──────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _interstitialReady = false;

  // ── Session frequency caps ────────────────────────────────────
  int _interstitialsShownThisSession = 0;
  static const int _maxPerSession = 3;

  DateTime? _lastShownAt;
  static const Duration _minInterval = Duration(minutes: 5);

  // ─────────────────────────────────────────────────────────────
  // BANNER
  // Reads the real device screen width in logical pixels so the
  // adaptive banner fills the full bottom bar on any screen size.
  // Falls back to 360 if the view is not yet available.
  // ─────────────────────────────────────────────────────────────

  Future<void> _loadBanner() async {
    if (!AdConfig.enableBannerAds) return;

    // Read real logical screen width from the platform view.
    // This is safe inside an async method — the view is always
    // available by the time this executes.
    int screenWidth = 360; // fallback for safety
    try {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      screenWidth =
          (view.physicalSize.width / view.devicePixelRatio).truncate();
    } catch (e) {
      debugPrint('⚠️ AdService: could not read screen width, using 360 — $e');
    }

    AdSize adSize;
    try {
      final adaptive =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
              screenWidth);
      adSize = adaptive ?? AdSize.banner;
    } catch (e) {
      debugPrint('⚠️ AdService: adaptive size failed, using fixed — $e');
      adSize = AdSize.banner;
    }

    _bannerAd = BannerAd(
      adUnitId: AdConfig.banner,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint(
              '✅ AdService: banner loaded (${adSize.width}×${adSize.height})');
          _bannerLoaded = true;
          _ref.read(bannerLoadedProvider.notifier).setLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ AdService: banner failed — ${error.message}');
          ad.dispose();
          _bannerAd = null;
          _bannerLoaded = false;
          _ref.read(bannerLoadedProvider.notifier).setUnloaded();
          Future.delayed(const Duration(seconds: 60), _loadBanner);
        },
      ),
    );
    _bannerAd!.load();
  }

  // ─────────────────────────────────────────────────────────────
  // INTERSTITIAL
  // ─────────────────────────────────────────────────────────────

  void _loadInterstitial() {
    if (!AdConfig.enableInterstitialAds) return;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialReady = true;
          debugPrint('✅ AdService: interstitial loaded');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _interstitialReady = false;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint(
                  '❌ AdService: interstitial failed to show — ${error.message}');
              ad.dispose();
              _interstitialAd = null;
              _interstitialReady = false;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint(
              '❌ AdService: interstitial failed to load — ${error.message}');
          _interstitialReady = false;
          Future.delayed(const Duration(seconds: 60), _loadInterstitial);
        },
      ),
    );
  }

  bool get _canShow {
    if (!AdConfig.enableInterstitialAds) return false;
    if (!_interstitialReady || _interstitialAd == null) return false;
    if (_interstitialsShownThisSession >= _maxPerSession) return false;
    if (_lastShownAt != null &&
        DateTime.now().difference(_lastShownAt!) < _minInterval) return false;
    return true;
  }

  void showInterstitialIfAvailable({VoidCallback? onClosed}) {
    if (!_canShow) {
      onClosed?.call();
      return;
    }

    _interstitialsShownThisSession++;
    _lastShownAt = DateTime.now();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        onClosed?.call();
        ad.dispose();
        _interstitialAd = null;
        _interstitialReady = false;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            '❌ AdService: interstitial failed to show — ${error.message}');
        onClosed?.call();
        ad.dispose();
        _interstitialAd = null;
        _interstitialReady = false;
        _loadInterstitial();
      },
    );

    _interstitialAd!.show();
    debugPrint('📢 AdService: showing interstitial '
        '($_interstitialsShownThisSession/$_maxPerSession this session)');
  }

  // ─────────────────────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────────────────────

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService(ref);
  ref.onDispose(service.dispose);
  return service;
});
