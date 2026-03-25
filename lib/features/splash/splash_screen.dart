// lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/splash/widgets/logo_splash_widget.dart';
import 'package:ekush_ponji/main.dart' show pendingNotificationPayload;

class SplashScreen extends ConsumerStatefulWidget {
  final String initialRoute;

  const SplashScreen({
    super.key,
    required this.initialRoute,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _appReady = false;
  bool _animationDone = false;

  @override
  void initState() {
    super.initState();

    // Simulate app readiness (replace with real init later if needed)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _onAppReady();
    });
  }

  void _onAnimationComplete() {
    setState(() => _animationDone = true);
    _maybeNavigate();
  }

  void _onAppReady() {
    setState(() => _appReady = true);
    _maybeNavigate();
  }

  void _maybeNavigate() {
    if (!_appReady || !_animationDone) return;
    if (!mounted) return;

    final destination = widget.initialRoute;

    final payload = pendingNotificationPayload;

    if (payload != null && payload.isNotEmpty) {
      pendingNotificationPayload = null;
      _handlePayload(payload, fallback: destination);
      return;
    }

    context.go(destination);
  }

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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: const [
            _SplashBackground(),
            Center(
              child: _SplashLogoWrapper(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogoWrapper extends StatelessWidget {
  const _SplashLogoWrapper();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_SplashScreenState>();

    return LogoSplashWidget(
      onAnimationComplete: state?._onAnimationComplete ?? () {},
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SizedBox.expand(
      child: CustomPaint(
        painter: _BackgroundPainter(size: size),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Size size;

  late final Paint _topRightPaint;
  late final Paint _bottomLeftPaint;
  late final Paint _centerPaint;

  _BackgroundPainter({required this.size}) {
    _topRightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF006B54).withValues(alpha: 0.07),
          const Color(0xFF006B54).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.10),
        radius: size.width * 0.70,
      ));

    _bottomLeftPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3D6373).withValues(alpha: 0.06),
          const Color(0xFF3D6373).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.10, size.height * 0.90),
        radius: size.width * 0.60,
      ));

    _centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7FF9D4).withValues(alpha: 0.10),
          const Color(0xFF7FF9D4).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.50, size.height * 0.45),
        radius: size.width * 0.55,
      ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.10),
      size.width * 0.70,
      _topRightPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.10, size.height * 0.90),
      size.width * 0.60,
      _bottomLeftPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.45),
      size.width * 0.55,
      _centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => false;
}
