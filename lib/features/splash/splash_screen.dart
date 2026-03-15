// lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/features/splash/widgets/logo_splash_widget.dart';
import 'package:ekush_ponji/features/splash/widgets/app_loading_widget.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read destination once — provider caches the Hive result.
    // Using ref.read (not watch) because this never needs to rebuild.
    final destination = ref.read(initialDestinationProvider);

    ref.listen<bool>(appReadyProvider, (_, isReady) {
      if (!isReady) return;
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

  // Cached paints — created once in the constructor, never on paint().
  late final Paint _topRightPaint;
  late final Paint _centerPaint;
  late final Paint _bottomLeftPaint;

  _BackgroundPainter({required this.size}) {
    _topRightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1A4A8A).withValues(alpha: 0.45),
          const Color(0xFF1A4A8A).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.12),
        radius: size.width * 0.65,
      ));

    _centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0D2A5E).withValues(alpha: 0.6),
          const Color(0xFF0D2A5E).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.42),
        radius: size.width * 0.7,
      ));

    _bottomLeftPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0A3366).withValues(alpha: 0.4),
          const Color(0xFF0A3366).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.1, size.height * 0.88),
        radius: size.width * 0.55,
      ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.12),
      size.width * 0.65,
      _topRightPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.42),
      size.width * 0.7,
      _centerPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.88),
      size.width * 0.55,
      _bottomLeftPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) => false;
}