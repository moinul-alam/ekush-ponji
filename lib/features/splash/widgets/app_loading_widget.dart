// lib/features/splash/widgets/app_loading_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Calendar-themed loading animation widget with 10 animation styles.
/// Optimized: const constructors on painters, minimal allocations per frame.
///
/// Available types:
///   AnimationType.rotatingGrid
///   AnimationType.flippingPages
///   AnimationType.pulsingDates
///   AnimationType.circularMonths
///   AnimationType.bouncingWeekdays   ← used on splash
///   AnimationType.spiralCalendar
///   AnimationType.waveGrid
///   AnimationType.orbitingDates
///   AnimationType.morphingShapes
///   AnimationType.slidingBlocks

class AppLoadingWidget extends StatefulWidget {
  final Color color;
  final AnimationType animationType;

  const AppLoadingWidget({
    super.key,
    required this.color,
    this.animationType = AnimationType.rotatingGrid,
  });

  @override
  State<AppLoadingWidget> createState() => _AppLoadingWidgetState();
}

class _AppLoadingWidgetState extends State<AppLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: widget.animationType.size,
          height: widget.animationType.size,
          child: CustomPaint(
            painter: _getPainter(_controller.value),
          ),
        );
      },
    );
  }

  CustomPainter _getPainter(double progress) {
    return switch (widget.animationType) {
      AnimationType.rotatingGrid    => RotatingGridPainter(progress: progress, color: widget.color),
      AnimationType.flippingPages   => FlippingPagesPainter(progress: progress, color: widget.color),
      AnimationType.pulsingDates    => PulsingDatesPainter(progress: progress, color: widget.color),
      AnimationType.circularMonths  => CircularMonthsPainter(progress: progress, color: widget.color),
      AnimationType.bouncingWeekdays => BouncingWeekdaysPainter(progress: progress, color: widget.color),
      AnimationType.spiralCalendar  => SpiralCalendarPainter(progress: progress, color: widget.color),
      AnimationType.waveGrid        => WaveGridPainter(progress: progress, color: widget.color),
      AnimationType.orbitingDates   => OrbitingDatesPainter(progress: progress, color: widget.color),
      AnimationType.morphingShapes  => MorphingShapesPainter(progress: progress, color: widget.color),
      AnimationType.slidingBlocks   => SlidingBlocksPainter(progress: progress, color: widget.color),
    };
  }
}

enum AnimationType {
  rotatingGrid(size: 120.0),
  flippingPages(size: 100.0),
  pulsingDates(size: 100.0),
  circularMonths(size: 100.0),
  bouncingWeekdays(size: 140.0),
  spiralCalendar(size: 100.0),
  waveGrid(size: 120.0),
  orbitingDates(size: 100.0),
  morphingShapes(size: 100.0),
  slidingBlocks(size: 100.0);

  const AnimationType({required this.size});
  final double size;
}

// ─── Shared helpers ────────────────────────────────────────────────────────

/// Inline opacity helper — avoids Color.withOpacity allocation overhead
Color _c(Color c, double opacity) =>
    c.withValues(alpha: opacity.clamp(0.0, 1.0));

Paint _fill(Color c, double opacity) =>
    Paint()
      ..color = _c(c, opacity)
      ..style = PaintingStyle.fill;

// ─── Painters ─────────────────────────────────────────────────────────────

class RotatingGridPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _gridSize    = 15.0;
  static const _spacing     = 18.0;
  static const _rows        = 2;
  static const _cols        = 7;
  static const _cornerR     = Radius.circular(3.0);

  const RotatingGridPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final angle = progress * 2 * math.pi;

    for (int row = 0; row < _rows; row++) {
      for (int col = 0; col < _cols; col++) {
        final delay   = (col + row * _cols) * 0.05;
        final ca      = angle + delay * math.pi;
        final rotX    = math.sin(ca) * 0.5;
        final scaleY  = math.cos(ca).abs();
        final opacity = 0.3 + scaleY * 0.7;
        final x = cx + (col - 3) * _spacing + rotX * _spacing;
        final y = cy + (row - 0.5) * _spacing;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: _gridSize, height: _gridSize * scaleY),
            _cornerR,
          ),
          _fill(color, opacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RotatingGridPainter old) =>
      progress != old.progress || color != old.color;
}

class FlippingPagesPainter extends CustomPainter {
  final double progress;
  final Color color;

  const FlippingPagesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < 3; i++) {
      final p       = ((progress + i * 0.25) % 1.0);
      final scaleX  = math.cos(p * math.pi).abs();
      final front   = math.cos(p * math.pi) > 0;
      final opacity = (0.3 + scaleX * 0.7) * (front ? 1.0 : 0.5);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy + (i - 1) * 30.0), width: 60.0 * scaleX, height: 80.0),
          const Radius.circular(4.0),
        ),
        _fill(color, opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlippingPagesPainter old) =>
      progress != old.progress || color != old.color;
}

class PulsingDatesPainter extends CustomPainter {
  final double progress;
  final Color color;

  const PulsingDatesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int ring = 0; ring < 3; ring++) {
      final radius = 25.0 + ring * 15.0;
      final count  = 6 + ring * 2;

      for (int i = 0; i < count; i++) {
        final angle = (i / count) * 2 * math.pi;
        final delay = ring * 0.15 + (i / count) * 0.3;
        final p     = ((progress + delay) % 1.0);
        final pulse = math.sin(p * 2 * math.pi);
        final scale = 0.6 + pulse * 0.4;

        canvas.drawCircle(
          Offset(cx + math.cos(angle) * radius, cy + math.sin(angle) * radius),
          8.0 * scale,
          _fill(color, 0.3 + pulse.abs() * 0.7),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PulsingDatesPainter old) =>
      progress != old.progress || color != old.color;
}

class CircularMonthsPainter extends CustomPainter {
  final double progress;
  final Color color;

  const CircularMonthsPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < 12; i++) {
      final angle  = (i / 12) * 2 * math.pi - (math.pi / 2);
      final p      = ((progress + i * 0.08) % 1.0);
      final active = p > 0.5;

      canvas.drawCircle(
        Offset(cx + math.cos(angle) * 35.0, cy + math.sin(angle) * 35.0),
        6.0 * (active ? 1.2 : 0.8),
        _fill(color, active ? 1.0 : 0.4),
      );
    }

    canvas.drawCircle(Offset(cx, cy), 8.0, _fill(color, 0.6));
  }

  @override
  bool shouldRepaint(covariant CircularMonthsPainter old) =>
      progress != old.progress || color != old.color;
}

class BouncingWeekdaysPainter extends CustomPainter {
  final double progress;
  final Color color;

  const BouncingWeekdaysPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < 7; i++) {
      final p      = ((progress + i * 0.14) % 1.0);
      final bounce = math.sin(p * math.pi);
      final scale  = 0.7 + bounce * 0.5;

      canvas.drawCircle(
        Offset(cx + (i - 3) * 18.0, cy - bounce * 25.0),
        8.0 * scale,
        _fill(color, 0.4 + bounce * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BouncingWeekdaysPainter old) =>
      progress != old.progress || color != old.color;
}

class SpiralCalendarPainter extends CustomPainter {
  final double progress;
  final Color color;

  const SpiralCalendarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < 20; i++) {
      final t     = i / 20;
      final p     = ((progress + t * 0.5) % 1.0);
      final angle = t * 4 * math.pi + progress * 2 * math.pi;
      final r     = t * 40.0 * p;

      canvas.drawCircle(
        Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r),
        (4.0 + t * 3.0) * (0.5 + p * 0.7),
        _fill(color, 0.3 + p * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpiralCalendarPainter old) =>
      progress != old.progress || color != old.color;
}

class WaveGridPainter extends CustomPainter {
  final double progress;
  final Color color;

  const WaveGridPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 7; col++) {
        final dx   = col - 3.0;
        final dy   = row - 2.0;
        final dist = math.sqrt(dx * dx + dy * dy);
        final p    = ((progress * 2 + dist * 0.3) % 1.0);
        final wave = math.sin(p * 2 * math.pi);
        final s    = 0.5 + (wave + 1) * 0.35;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx + dx * 15.0, cy + dy * 15.0),
              width: 12.0 * s, height: 12.0 * s,
            ),
            const Radius.circular(2.0),
          ),
          _fill(color, 0.3 + (wave + 1) * 0.35),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaveGridPainter old) =>
      progress != old.progress || color != old.color;
}

class OrbitingDatesPainter extends CustomPainter {
  final double progress;
  final Color color;

  const OrbitingDatesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int orbit = 0; orbit < 3; orbit++) {
      final r     = 15.0 + orbit * 12.0;
      final speed = 1.0 + orbit * 0.3;
      final count = 3 + orbit;

      for (int i = 0; i < count; i++) {
        final angle = (i / count) * 2 * math.pi + progress * speed * 2 * math.pi;
        canvas.drawCircle(
          Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r),
          (6.0 - orbit).clamp(1.0, 6.0),
          _fill(color, 0.8 - orbit * 0.2),
        );
      }
    }

    canvas.drawCircle(Offset(cx, cy), 5.0, _fill(color, 0.8));
  }

  @override
  bool shouldRepaint(covariant OrbitingDatesPainter old) =>
      progress != old.progress || color != old.color;
}

class MorphingShapesPainter extends CustomPainter {
  final double progress;
  final Color color;

  const MorphingShapesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx    = size.width / 2;
    final cy    = size.height / 2;
    final stage = (progress * 3).floor() % 3;
    final mp    = (progress * 3) % 1.0;

    final cornerR = switch (stage) {
      0 => mp * 17.5,
      1 => (1 - mp) * 17.5 + mp * 8.0,
      _ => (1 - mp) * 8.0,
    };

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 35.0, height: 35.0),
        Radius.circular(cornerR),
      ),
      _fill(color, 0.4 + math.sin(progress * 2 * math.pi) * 0.3),
    );

    canvas.drawCircle(
      Offset(cx, cy), 28.0,
      Paint()
        ..color = _c(color, 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant MorphingShapesPainter old) =>
      progress != old.progress || color != old.color;
}

class SlidingBlocksPainter extends CustomPainter {
  final double progress;
  final Color color;

  const SlidingBlocksPainter({required this.progress, required this.color});

  static double _ease(double t) =>
      t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < 5; i++) {
      final p     = ((progress + i * 0.15) % 1.0);
      final slide = p < 0.5 ? _ease(p * 2) : _ease((1 - p) * 2);
      final xOff  = (slide - 0.5) * 40.0;
      final yPos  = cy + (i - 2) * 16.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + xOff, yPos),
            width: 35.0 * (0.8 + slide * 0.3),
            height: 12.0,
          ),
          const Radius.circular(4.0),
        ),
        _fill(color, 0.4 + slide * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SlidingBlocksPainter old) =>
      progress != old.progress || color != old.color;
}