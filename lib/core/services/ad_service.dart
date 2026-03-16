// lib/core/services/ad_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AD UNIT IDs — test IDs, TODO: replace before release
// ─────────────────────────────────────────────────────────────────────────────

class _AdUnitIds {
  _AdUnitIds._();

  static const String androidBanner =
      'ca-app-pub-3940256099942544/6300978111'; // TODO: replace with real ID
  static const String androidInterstitial =
      'ca-app-pub-3940256099942544/1033173712'; // TODO: replace with real ID

  static const String iosBanner =
      'ca-app-pub-3940256099942544/2934735716'; // TODO: replace with real ID
  static const String iosInterstitial =
      'ca-app-pub-3940256099942544/4411468910'; // TODO: replace with real ID

  static String get banner =>
      defaultTargetPlatform == TargetPlatform.iOS ? iosBanner : androidBanner;

  static String get interstitial => defaultTargetPlatform == TargetPlatform.iOS
      ? iosInterstitial
      : androidInterstitial;
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER NOTIFIER
// Watched by AppAdBannerBottom — flips to true when banner loads.
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
// MobileAds.instance.initialize() is called separately in app_initializer.
// AdService just loads ads — safe to call after MobileAds is initialized.
// ─────────────────────────────────────────────────────────────────────────────

class AdService {
  final Ref _ref;

  AdService(this._ref) {
    // Both ads load on construction — RootScaffold owns the banner widget
    // permanently so AdWidget is never duplicated across screen changes.
    _loadBanner();
    _loadInterstitial();
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
  static const Duration _minInterval = Duration(minutes: 3);

  // ─────────────────────────────────────────────────────────────
  // BANNER — adaptive width
  // Takes the screen width in logical pixels as an int.
  // Call loadBanner(screenWidth) from AppAdBannerBottom once context
  // is available, so we get the correct device width.
  // Falls back to AdSize.banner (320×50) if adaptive call fails.
  // ─────────────────────────────────────────────────────────────

  Future<void> _loadBanner() async {
    AdSize adSize;
    try {
      // 360 is a safe default logical width covering most Android phones.
      // The adaptive API returns the best size for this width.
      const int defaultWidth = 360;
      final adaptive = await AdSize
          .getCurrentOrientationAnchoredAdaptiveBannerAdSize(defaultWidth);
      adSize = adaptive ?? AdSize.banner;
    } catch (e) {
      debugPrint('⚠️ AdService: adaptive size failed, using fixed — $e');
      adSize = AdSize.banner;
    }

    _bannerAd = BannerAd(
      adUnitId: _AdUnitIds.banner,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('✅ AdService: banner loaded (${adSize.width}×${adSize.height})');
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
    InterstitialAd.load(
      adUnitId: _AdUnitIds.interstitial,
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
    debugPrint(
        '📢 AdService: showing interstitial ($_interstitialsShownThisSession/$_maxPerSession this session)');
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