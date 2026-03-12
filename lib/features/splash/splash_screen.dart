// lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_viewmodel.dart';
import 'package:ekush_ponji/features/splash/widgets/logo_splash_widget.dart';
import 'package:ekush_ponji/features/splash/widgets/app_loading_widget.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Navigate the moment app signals ready
    ref.listen<bool>(appReadyProvider, (_, isReady) {
      if (!isReady) return;
      // First launch → onboarding, returning user → home
      final destination = isOnboardingDone()
          ? RouteNames.home
          : RouteNames.onboarding;
      context.go(destination);
    });

    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            const _SplashBackground(),
            const Center(child: LogoSplashWidget()),
            Positioned(
              bottom: 72,
              left: 0,
              right: 0,
              child: Center(
                child: AppLoadingWidget(
                  color: const Color(0xFF4DA6FF).withValues(alpha: 0.75),
                  animationType: AnimationType.bouncingWeekdays,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SizedBox.expand(
      child: CustomPaint(painter: _BackgroundPainter(size: size)),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Size size;
  const _BackgroundPainter({required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    _drawRadialGlow(
      canvas,
      center: Offset(size.width * 0.85, size.height * 0.12),
      radius: size.width * 0.65,
      color: const Color(0xFF1A4A8A),
      opacity: 0.45,
    );
    _drawRadialGlow(
      canvas,
      center: Offset(size.width * 0.5, size.height * 0.42),
      radius: size.width * 0.7,
      color: const Color(0xFF0D2A5E),
      opacity: 0.6,
    );
    _drawRadialGlow(
      canvas,
      center: Offset(size.width * 0.1, size.height * 0.88),
      radius: size.width * 0.55,
      color: const Color(0xFF0A3366),
      opacity: 0.4,
    );
  }

  void _drawRadialGlow(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double opacity,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) => false;
}