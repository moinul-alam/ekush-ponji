// lib/core/widgets/ads/native_ad_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ekush_ponji/app/config/ad_config.dart';

class NativeAdWidget extends StatefulWidget {
  final NativeAdStyle style;

  /// When [style] is [NativeAdStyle.card], overrides outer margin (default 16h / 4v).
  final EdgeInsetsGeometry? cardMargin;

  /// When [style] is [NativeAdStyle.card], overrides corner radius (default 12).
  final double? cardBorderRadius;

  /// When [style] is [NativeAdStyle.card], overrides surface tint (default 0.5).
  final double? cardSurfaceAlpha;

  const NativeAdWidget({
    super.key,
    this.style = NativeAdStyle.card,
    this.cardMargin,
    this.cardBorderRadius,
    this.cardSurfaceAlpha,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

enum NativeAdStyle { card, section }

class _NativeAdWidgetState extends State<NativeAdWidget> {
  double _adHeightFor(BuildContext context) {
    // Android native templates include media assets; keep a larger host height
    // to avoid "ad too small" validation issues on video/image creatives.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final screenSize = MediaQuery.sizeOf(context);
      final isCompact = screenSize.height <
              AdConfig.nativeCompactHeightThreshold ||
          screenSize.shortestSide < AdConfig.nativeCompactShortestSideThreshold;
      final isVeryCompact =
          screenSize.height < AdConfig.nativeVeryCompactHeightThreshold ||
              screenSize.shortestSide <
                  AdConfig.nativeVeryCompactShortestSideThreshold;

      final base = widget.style == NativeAdStyle.section
          ? AdConfig.nativeSectionBaseHeightAndroid
          : AdConfig.nativeCardBaseHeightAndroid;
      final reduced = isVeryCompact
          ? (base - AdConfig.nativeVeryCompactReductionAndroid)
          : isCompact
              ? (base - AdConfig.nativeCompactReductionAndroid)
              : base;

      // Keep lower bound high enough for media + text native layouts.
      return reduced.clamp(
        AdConfig.nativeMinHeightAndroid,
        AdConfig.nativeMaxHeightAndroid,
      );
    }
    return widget.style == NativeAdStyle.section
        ? AdConfig.nativeSectionHeightDefault
        : AdConfig.nativeCardHeightDefault;
  }

  NativeAd? _nativeAd;
  bool _isLoaded = false;
  int _noFillRetries = 0;

  @override
  void initState() {
    super.initState();
    if (AdConfig.enableNativeAds) {
      _loadAd();
    }
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdConfig.native,
      factoryId: 'ekushNativeAd',
      nativeAdOptions: NativeAdOptions(
        videoOptions: VideoOptions(
          startMuted: true,
          clickToExpandRequested: false,
          customControlsRequested: false,
        ),
        adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        shouldReturnUrlsForImageAssets: false,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          _noFillRetries = 0;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _nativeAd = null;
          final isNoFill = error.code == 3;
          if (AdConfig.nativeRetryOnNoFill &&
              isNoFill &&
              _noFillRetries < AdConfig.nativeNoFillMaxRetries &&
              mounted) {
            _noFillRetries++;
            debugPrint(
              '⚠️ NativeAd no fill (code 3), retry '
              '$_noFillRetries/${AdConfig.nativeNoFillMaxRetries} in '
              '${AdConfig.nativeNoFillRetrySeconds}s',
            );
            Future<void>.delayed(
              Duration(seconds: AdConfig.nativeNoFillRetrySeconds),
              () {
                if (!mounted || !AdConfig.enableNativeAds) return;
                _loadAd();
              },
            );
            return;
          }
          _noFillRetries = 0;
          debugPrint('❌ NativeAd failed to load: ${error.message}');
        },
      ),
      request: const AdRequest(),
    );
    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdConfig.enableNativeAds) return const SizedBox.shrink();
    if (!_isLoaded || _nativeAd == null) return const SizedBox.shrink();

    return widget.style == NativeAdStyle.section
        ? _buildSectionStyle(context)
        : _buildCardStyle(context);
  }

  Widget _buildCardStyle(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final adHeight = _adHeightFor(context);
    final margin = widget.cardMargin ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4);
    final radius = widget.cardBorderRadius ?? 12.0;
    final surfaceAlpha = widget.cardSurfaceAlpha ?? 0.5;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: surfaceAlpha),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Ad',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          // AdWidget MUST have a fixed height — it cannot infer its own size.
          SizedBox(
            width: double.infinity,
            height: adHeight,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionStyle(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final adHeight = _adHeightFor(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border(
          left: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.6),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 14,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'Sponsored',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: adHeight,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }
}
