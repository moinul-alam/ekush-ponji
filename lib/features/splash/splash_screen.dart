import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/splash/widgets/logo_splash_widget.dart';
import 'package:ekush_ponji/features/splash/widgets/app_loading_widget.dart';

// ✅ ConsumerStatefulWidget so we can watch Riverpod providers
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    // ✅ Listen to appReadyProvider — navigates the moment it flips true
    ref.listen<bool>(appReadyProvider, (_, isReady) {
      if (isReady && mounted) {
        context.go(RouteNames.home);
      }
    });

    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
              theme.colorScheme.primaryContainer,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundCircles(size),
            const Center(
              child: LogoSplashWidget(),
            ),
            Positioned(
              bottom: 72,
              left: 0,
              right: 0,
              child: Center(
                child: AppLoadingWidget(
                  color: Colors.white.withValues(alpha: 0.75),
                  animationType: AnimationType.bouncingWeekdays,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCircles(Size size) {
    const circleAlpha = 20;
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: _BackgroundCircle(size: 280, alpha: circleAlpha),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: _BackgroundCircle(size: 120, alpha: circleAlpha - 6),
        ),
        Positioned(
          bottom: -120,
          left: -80,
          child: _BackgroundCircle(size: 380, alpha: circleAlpha),
        ),
        Positioned(
          bottom: 80,
          left: 60,
          child: _BackgroundCircle(size: 100, alpha: circleAlpha - 6),
        ),
      ],
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({required this.size, required this.alpha});

  final double size;
  final int alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
  }
}