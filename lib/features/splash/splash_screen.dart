// lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/splash/widgets/logo_splash_widget.dart';
import 'package:ekush_ponji/main.dart' show pendingNotificationPayload;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _appReady = false;
  bool _animationDone = false;

  @override
  void initState() {
    super.initState();
    // Check if app is already ready (e.g. hot reload)
    _appReady = ref.read(appReadyProvider);
  }

  void _onAnimationComplete() {
    setState(() => _animationDone = true);
    _maybeNavigate();
  }

  void _onAppReady() {
    setState(() => _appReady = true);
    _maybeNavigate();
  }

  /// Navigates only when BOTH the app is ready AND the animation has finished.
  /// Whichever completes last triggers the navigation.
  void _maybeNavigate() {
    if (!_appReady || !_animationDone) return;
    if (!mounted) return;

    final destination = ref.read(initialDestinationProvider);

    // Check for cold-start notification payload — route directly to the
    // correct screen instead of home, consuming the payload immediately.
    final payload = pendingNotificationPayload;
    if (payload != null && payload.isNotEmpty) {
      pendingNotificationPayload = null; // consume once
      _handlePayload(payload, fallback: destination);
      return;
    }

    context.go(destination);
  }

  /// Routes to the correct screen based on notification payload.
  /// Falls back to [fallback] (home or onboarding) if unrecognised.
  void _handlePayload(String payload, {required String fallback}) {
    if (!mounted) return;

    if (payload == 'holiday') {
      context.go(fallback);
      context.push(RouteNames.holidays);
      return;
    }

    if (payload.startsWith('quote:')) {
      final index = int.tryParse(payload.substring('quote:'.length)) ?? 0;
      context.go(fallback);
      context.push(RouteNames.quotes, extra: index);
      return;
    }

    if (payload.startsWith('word:')) {
      final index = int.tryParse(payload.substring('word:'.length)) ?? 0;
      context.go(fallback);
      context.push(RouteNames.words, extra: index);
      return;
    }

    if (payload.startsWith('event:') || payload.startsWith('reminder:')) {
      final dateStr = payload.startsWith('event:')
          ? payload.substring('event:'.length)
          : payload.substring('reminder:'.length);
      try {
        final date = DateTime.parse(dateStr);
        context.go(RouteNames.calendar);
        context.push(RouteNames.calendarDayDetails, extra: date);
      } catch (_) {
        context.go(fallback);
      }
      return;
    }

    context.go(fallback);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to appReady — fires _onAppReady when background init completes
    ref.listen<bool>(appReadyProvider, (_, isReady) {
      if (isReady) _onAppReady();
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
            Center(
              child: LogoSplashWidget(
                onAnimationComplete: _onAnimationComplete,
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
