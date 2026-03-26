// lib/core/widgets/ads/app_ad_banner_bottom.dart
//
// Persistent banner ad slot. Lives in RootScaffold — never rebuilt on
// screen changes so AdWidget is always attached to exactly one place
// in the widget tree.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ekush_ponji/app/config/ad_config.dart';
import 'package:ekush_ponji/core/services/ad_service.dart';

class AppAdBannerBottom extends ConsumerWidget {
  const AppAdBannerBottom({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kill switch
    if (!AdConfig.enableBannerAds) return const SizedBox.shrink();

    final bannerLoaded = ref.watch(bannerLoadedProvider);
    final adService = ref.read(adServiceProvider);

    if (bannerLoaded && adService.bannerAd != null) {
      final banner = adService.bannerAd!;
      return SizedBox(
        width: double.infinity,
        height: banner.size.height.toDouble(),
        child: AdWidget(ad: banner),
      );
    }

    // Placeholder — always reserves 50dp so layout never jumps
    return Container(
      height: 50,
      width: double.infinity,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.4),
    );
  }
}
