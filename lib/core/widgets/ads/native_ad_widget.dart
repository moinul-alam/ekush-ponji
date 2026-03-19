// lib/core/widgets/ads/native_ad_widget.dart
//
// Self-contained native ad widget.
// Drop <NativeAdWidget /> anywhere in a list — it handles
// loading, rendering, and disposal internally.
// Returns SizedBox.shrink() when enableNativeAds is false.

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ekush_ponji/app/config/ad_config.dart';

class NativeAdWidget extends StatefulWidget {
  /// Visual style variant — use [NativeAdStyle.card] for list screens,
  /// [NativeAdStyle.section] for gazette-type section separators.
  final NativeAdStyle style;

  const NativeAdWidget({
    super.key,
    this.style = NativeAdStyle.card,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

enum NativeAdStyle {
  /// Standard card — used in flat lists (events, reminders, saved quotes/words)
  card,

  /// Section separator style — used in gazette-type holiday sections
  section,
}

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
    // Kill switch — render nothing if native ads are disabled
    if (!AdConfig.enableNativeAds) return const SizedBox.shrink();

    // Not loaded yet — render nothing (no placeholder jump)
    if (!_isLoaded || _nativeAd == null) return const SizedBox.shrink();

    return widget.style == NativeAdStyle.section
        ? _buildSectionStyle(context)
        : _buildCardStyle(context);
  }

  // ── Card style — matches list item cards ─────────────────────
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
        children: [
          // "Ad" label
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              ],
            ),
          ),
          // Native ad content
          SizedBox(
            height: 72,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }

  // ── Section style — matches gazette section separators ────────
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
        children: [
          // "Sponsored" label matching section header style
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
          // Native ad content
          SizedBox(
            height: 72,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }
}
