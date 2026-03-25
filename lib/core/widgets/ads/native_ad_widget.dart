// lib/core/widgets/ads/native_ad_widget.dart

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ekush_ponji/app/config/ad_config.dart';

class NativeAdWidget extends StatefulWidget {
  final NativeAdStyle style;

  const NativeAdWidget({
    super.key,
    this.style = NativeAdStyle.card,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

enum NativeAdStyle { card, section }

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

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
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ NativeAd failed to load: ${error.message}');
          ad.dispose();
          _nativeAd = null;
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.4),
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
                color: cs.primary.withOpacity(0.12),
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
          // 88dp matches our native layout: 8dp padding top + 40dp icon
          // + text lines + 8dp padding bottom ≈ 88dp total.
          SizedBox(
            width: double.infinity,
            height: 88,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionStyle(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        border: Border(
          left: BorderSide(
            color: cs.outlineVariant.withOpacity(0.6),
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
                  color: cs.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'Sponsored',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Same fixed height — matches native layout dimensions.
          SizedBox(
            width: double.infinity,
            height: 88,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }
}
