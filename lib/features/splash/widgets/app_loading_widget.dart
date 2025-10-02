import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Calendar-themed loading animation widget with 10 different animation styles
/// Optimized for performance with efficient repaints and modern Flutter APIs
// AnimationType.rotatingGrid
// AnimationType.flippingPages
// AnimationType.pulsingDates
// AnimationType.circularMonths
// AnimationType.bouncingWeekdays
// AnimationType.spiralCalendar
// AnimationType.waveGrid
// AnimationType.orbitingDates
// AnimationType.morphingShapes
// AnimationType.slidingBlocks

class AppLoadingWidget extends StatefulWidget {
  final Color color;
  final AnimationType animationType;

  const AppLoadingWidget({
    super.key,
    required this.color,
    this.animationType = AnimationType.waveGrid,
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
            painter: _getPainter(),
          ),
        );
      },
    );
  }

  CustomPainter _getPainter() {
    return switch (widget.animationType) {
      AnimationType.rotatingGrid => RotatingGridPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      AnimationType.flippingPages => FlippingPagesPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      AnimationType.pulsingDates => PulsingDatesPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      AnimationType.circularMonths => CircularMonthsPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      AnimationType.bouncingWeekdays => BouncingWeekdaysPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      AnimationType.spiralCalendar => SpiralCalendarPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      AnimationType.waveGrid => WaveGridPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      AnimationType.orbitingDates => OrbitingDatesPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      AnimationType.morphingShapes => MorphingShapesPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      AnimationType.slidingBlocks => SlidingBlocksPainter(
          progress: _controller.value,
          color: widget.color,
        ),
    };
  }
}

/// Enum for animation types with associated properties
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

/// Helper extension for color manipulation with alpha values
extension ColorAlpha on Color {
  Color withAlpha(int alpha) {
    return Color.fromARGB(
      alpha.clamp(0, 255),
      red,
      green,
      blue,
    );
  }

  Color withOpacityValue(double opacity) {
    return withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
  }
}

// Painter 1: Rotating 3D Grid
class RotatingGridPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _gridSize = 15.0;
  static const _spacing = 18.0;
  static const _rows = 2;
  static const _cols = 7;
  static const _cornerRadius = 3.0;

  const RotatingGridPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final angle = progress * 2 * math.pi;

    for (int row = 0; row < _rows; row++) {
      for (int col = 0; col < _cols; col++) {
        final cellIndex = col + row * _cols;
        final delay = cellIndex * 0.05;
        final cellAngle = angle + delay * math.pi;

        final rotationX = math.sin(cellAngle) * 0.5;
        final scaleY = math.cos(cellAngle).abs();
        final opacity = 0.3 + (scaleY * 0.7);

        final x = centerX + (col - 3) * _spacing + rotationX * _spacing;
        final y = centerY + (row - 0.5) * _spacing;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x, y),
              width: _gridSize,
              height: _gridSize * scaleY,
            ),
            const Radius.circular(_cornerRadius),
          ),
          Paint()
            ..color = color.withOpacityValue(opacity)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RotatingGridPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Painter 2: Flipping Pages
class FlippingPagesPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _pageWidth = 60.0;
  static const _pageHeight = 80.0;
  static const _pageCount = 3;
  static const _pageSpacing = 30.0;
  static const _cornerRadius = 4.0;

  const FlippingPagesPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < _pageCount; i++) {
      final delay = i * 0.25;
      final pageProgress = ((progress + delay) % 1.0);
      final flipAngle = pageProgress * math.pi;
      final scaleX = math.cos(flipAngle).abs();
      final baseOpacity = 0.3 + (scaleX * 0.7);
      final isFrontFacing = math.cos(flipAngle) > 0;
      final opacity = isFrontFacing ? baseOpacity : baseOpacity * 0.5;
      final yOffset = (i - 1) * _pageSpacing;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, centerY + yOffset),
            width: _pageWidth * scaleX,
            height: _pageHeight,
          ),
          const Radius.circular(_cornerRadius),
        ),
        Paint()
          ..color = color.withOpacityValue(opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlippingPagesPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Painter 3: Pulsing Dates
class PulsingDatesPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _baseRadius = 8.0;
  static const _ringCount = 3;
  static const _startRadius = 25.0;
  static const _radiusIncrement = 15.0;
  static const _baseDotsCount = 6;

  const PulsingDatesPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int ring = 0; ring < _ringCount; ring++) {
      final radius = _startRadius + (ring * _radiusIncrement);
      final dotsCount = _baseDotsCount + (ring * 2);

      for (int i = 0; i < dotsCount; i++) {
        final angle = (i / dotsCount) * 2 * math.pi;
        final delay = (ring * 0.15) + (i / dotsCount) * 0.3;
        final itemProgress = ((progress + delay) % 1.0);
        final pulse = math.sin(itemProgress * 2 * math.pi);
        final scale = 0.6 + (pulse * 0.4);
        final opacity = 0.3 + (pulse.abs() * 0.7);

        canvas.drawCircle(
          Offset(
            centerX + math.cos(angle) * radius,
            centerY + math.sin(angle) * radius,
          ),
          _baseRadius * scale,
          Paint()
            ..color = color.withOpacityValue(opacity)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PulsingDatesPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Painter 4: Circular Months
class CircularMonthsPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _monthCount = 12;
  static const _orbitRadius = 35.0;
  static const _dotRadius = 6.0;
  static const _centerDotRadius = 8.0;
  static const _activeScale = 1.2;
  static const _inactiveScale = 0.8;

  const CircularMonthsPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < _monthCount; i++) {
      final angle = (i / _monthCount) * 2 * math.pi - (math.pi / 2);
      final delay = i * 0.08;
      final itemProgress = ((progress + delay) % 1.0);
      final isActive = itemProgress > 0.5;
      final scale = isActive ? _activeScale : _inactiveScale;
      final opacity = isActive ? 1.0 : 0.4;

      canvas.drawCircle(
        Offset(
          centerX + math.cos(angle) * _orbitRadius,
          centerY + math.sin(angle) * _orbitRadius,
        ),
        _dotRadius * scale,
        Paint()
          ..color = color.withOpacityValue(opacity)
          ..style = PaintingStyle.fill,
      );
    }

    // Center circle
    canvas.drawCircle(
      Offset(centerX, centerY),
      _centerDotRadius,
      Paint()
        ..color = color.withOpacityValue(0.6)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CircularMonthsPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Painter 5: Bouncing Weekdays
class BouncingWeekdaysPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _weekdayCount = 7;
  static const _spacing = 18.0;
  static const _circleRadius = 8.0;
  static const _maxBounceHeight = 25.0;

  const BouncingWeekdaysPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < _weekdayCount; i++) {
      final delay = i * 0.14;
      final itemProgress = ((progress + delay) % 1.0);

      // Smooth bounce using sine wave
      final bounce = math.sin(itemProgress * math.pi);
      final yOffset = -bounce * _maxBounceHeight;
      final scale = 0.7 + (bounce * 0.5);
      final opacity = 0.4 + (bounce * 0.6);

      final x = centerX + (i - 3) * _spacing;
      final y = centerY + yOffset;

      canvas.drawCircle(
        Offset(x, y),
        _circleRadius * scale,
        Paint()
          ..color = color.withOpacityValue(opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BouncingWeekdaysPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Painter 6: Spiral Calendar
class SpiralCalendarPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _dotCount = 20;
  static const _maxRadius = 40.0;
  static const _spiralTurns = 4.0;
  static const _minDotSize = 4.0;
  static const _maxDotSize = 7.0;

  const SpiralCalendarPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < _dotCount; i++) {
      final t = i / _dotCount;
      final delay = t * 0.5;
      final itemProgress = ((progress + delay) % 1.0);

      // Spiral calculation with smooth expansion
      final angle = t * _spiralTurns * math.pi + (progress * 2 * math.pi);
      final radius = t * _maxRadius * itemProgress;

      final scale = 0.5 + (itemProgress * 0.7);
      final opacity = 0.3 + (itemProgress * 0.7);
      final dotSize = _minDotSize + (t * (_maxDotSize - _minDotSize));

      canvas.drawCircle(
        Offset(
          centerX + math.cos(angle) * radius,
          centerY + math.sin(angle) * radius,
        ),
        dotSize * scale,
        Paint()
          ..color = color.withOpacityValue(opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpiralCalendarPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Painter 7: Wave Grid
class WaveGridPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _cellSize = 12.0;
  static const _spacing = 15.0;
  static const _rows = 5;
  static const _cols = 7;
  static const _cornerRadius = 2.0;
  static const _waveSpeed = 2.0;

  const WaveGridPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int row = 0; row < _rows; row++) {
      for (int col = 0; col < _cols; col++) {
        final x = centerX + (col - (_cols - 1) / 2) * _spacing;
        final y = centerY + (row - (_rows - 1) / 2) * _spacing;

        // Wave effect based on distance from center
        final dx = col - (_cols - 1) / 2;
        final dy = row - (_rows - 1) / 2;
        final distance = math.sqrt(dx * dx + dy * dy);
        final wavePhase = distance * 0.3;
        final itemProgress = ((progress * _waveSpeed + wavePhase) % 1.0);

        final wave = math.sin(itemProgress * 2 * math.pi);
        final scale = 0.5 + ((wave + 1) * 0.35);
        final opacity = 0.3 + ((wave + 1) * 0.35);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x, y),
              width: _cellSize * scale,
              height: _cellSize * scale,
            ),
            const Radius.circular(_cornerRadius),
          ),
          Paint()
            ..color = color.withOpacityValue(opacity)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaveGridPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Painter 8: Orbiting Dates
class OrbitingDatesPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _orbitCount = 3;
  static const _baseOrbitRadius = 15.0;
  static const _orbitRadiusIncrement = 12.0;
  static const _baseSpeed = 1.0;
  static const _speedIncrement = 0.3;
  static const _baseDotCount = 3;
  static const _centerDotSize = 5.0;

  const OrbitingDatesPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw orbits
    for (int orbit = 0; orbit < _orbitCount; orbit++) {
      final orbitRadius = _baseOrbitRadius + (orbit * _orbitRadiusIncrement);
      final speed = _baseSpeed + (orbit * _speedIncrement);
      final dotCount = _baseDotCount + orbit;

      for (int i = 0; i < dotCount; i++) {
        final baseAngle = (i / dotCount) * 2 * math.pi;
        final angle = baseAngle + (progress * speed * 2 * math.pi);

        final scale = 1.0 - (orbit * 0.15);
        final opacity = 0.8 - (orbit * 0.2);
        final dotSize = 6.0 - (orbit * 1.0);

        canvas.drawCircle(
          Offset(
            centerX + math.cos(angle) * orbitRadius,
            centerY + math.sin(angle) * orbitRadius,
          ),
          dotSize * scale,
          Paint()
            ..color = color.withOpacityValue(opacity)
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Center dot
    canvas.drawCircle(
      Offset(centerX, centerY),
      _centerDotSize,
      Paint()
        ..color = color.withOpacityValue(0.8)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant OrbitingDatesPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Painter 9: Morphing Shapes
class MorphingShapesPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _shapeSize = 35.0;
  static const _maxCornerRadius = _shapeSize / 2;
  static const _roundedCornerRadius = 8.0;
  static const _ringRadius = _shapeSize * 0.8;
  static const _ringStrokeWidth = 2.0;
  static const _stageCount = 3;

  const MorphingShapesPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Morph between square, circle, and rounded square
    final morphProgress = (progress * _stageCount) % 1.0;
    final stage = (progress * _stageCount).floor() % _stageCount;

    final cornerRadius = switch (stage) {
      0 => morphProgress * _maxCornerRadius, // Square to Circle
      1 => (1 - morphProgress) * _maxCornerRadius +
          morphProgress * _roundedCornerRadius, // Circle to Rounded Square
      _ => (1 - morphProgress) * _roundedCornerRadius, // Rounded to Square
    };

    final pulseOpacity = 0.4 + (math.sin(progress * 2 * math.pi) * 0.3);

    // Main shape
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: _shapeSize,
          height: _shapeSize,
        ),
        Radius.circular(cornerRadius),
      ),
      Paint()
        ..color = color.withOpacityValue(pulseOpacity)
        ..style = PaintingStyle.fill,
    );

    // Outer ring
    canvas.drawCircle(
      Offset(centerX, centerY),
      _ringRadius,
      Paint()
        ..color = color.withOpacityValue(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringStrokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant MorphingShapesPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Painter 10: Sliding Blocks
class SlidingBlocksPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _blockWidth = 35.0;
  static const _blockHeight = 12.0;
  static const _stackCount = 5;
  static const _blockSpacing = 4.0;
  static const _cornerRadius = 4.0;
  static const _maxSlideDistance = 40.0;

  const SlidingBlocksPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < _stackCount; i++) {
      final delay = i * 0.15;
      final itemProgress = ((progress + delay) % 1.0);

      // Smooth slide using ease in-out
      final slidePhase = itemProgress < 0.5
          ? _easeInOutCubic(itemProgress * 2)
          : _easeInOutCubic((1 - itemProgress) * 2);

      final xOffset = (slidePhase - 0.5) * _maxSlideDistance;
      final yPos = centerY +
          (i - (_stackCount - 1) / 2) * (_blockHeight + _blockSpacing);
      final opacity = 0.4 + (slidePhase * 0.5);
      final scale = 0.8 + (slidePhase * 0.3);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX + xOffset, yPos),
            width: _blockWidth * scale,
            height: _blockHeight,
          ),
          const Radius.circular(_cornerRadius),
        ),
        Paint()
          ..color = color.withOpacityValue(opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  static double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  @override
  bool shouldRepaint(covariant SlidingBlocksPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}
