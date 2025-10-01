import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Calendar-themed loading animation widget
/// Change the animationType to test different animations easily
class CalendarLoadingWidget extends StatefulWidget {
  final Color color;
  
  // CHANGE THIS TO TEST DIFFERENT ANIMATIONS:
  // 'rotating_grid' - 3D rotating week grid
  // 'flipping_pages' - Flipping calendar pages
  // 'pulsing_dates' - Pulsing date numbers
  // 'circular_months' - Circular month indicators
  final String animationType;

  const CalendarLoadingWidget({
    super.key,
    required this.color,
    this.animationType = 'circular_months', // Default animation
  });

  @override
  State<CalendarLoadingWidget> createState() => _CalendarLoadingWidgetState();
}

class _CalendarLoadingWidgetState extends State<CalendarLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Switch between different animation types
    switch (widget.animationType) {
      case 'rotating_grid':
        return _buildRotatingGrid();
      case 'flipping_pages':
        return _buildFlippingPages();
      case 'pulsing_dates':
        return _buildPulsingDates();
      case 'circular_months':
        return _buildCircularMonths();
      default:
        return _buildRotatingGrid();
    }
  }

  // Animation 1: Rotating 3D Calendar Grid
  Widget _buildRotatingGrid() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: RotatingGridPainter(
              progress: _animation.value,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }

  // Animation 2: Flipping Calendar Pages
  Widget _buildFlippingPages() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 100,
          height: 120,
          child: CustomPaint(
            painter: FlippingPagesPainter(
              progress: _animation.value,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }

  // Animation 3: Pulsing Date Numbers
  Widget _buildPulsingDates() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: PulsingDatesPainter(
              progress: _animation.value,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }

  // Animation 4: Circular Month Indicators
  Widget _buildCircularMonths() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: CircularMonthsPainter(
              progress: _animation.value,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

// Painter 1: Rotating 3D Grid
class RotatingGridPainter extends CustomPainter {
  final double progress;
  final Color color;

  RotatingGridPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final gridSize = 15.0;
    final spacing = 18.0;

    // 7 columns (days of week) x 2 rows
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 7; col++) {
        final angle = progress * 2 * math.pi;
        final delay = (col + row * 7) * 0.05;
        final itemProgress = ((progress + delay) % 1.0);
        
        // 3D rotation effect
        final rotationX = math.sin(angle + delay * math.pi) * 0.5;
        final scaleY = math.cos(angle + delay * math.pi).abs();
        
        final x = centerX + (col - 3) * spacing + rotationX * spacing;
        final y = centerY + (row - 0.5) * spacing;
        
        final opacity = 0.3 + (scaleY * 0.7);
        final cellPaint = Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x, y),
              width: gridSize,
              height: gridSize * scaleY,
            ),
            const Radius.circular(3),
          ),
          cellPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(RotatingGridPainter oldDelegate) => true;
}

// Painter 2: Flipping Pages
class FlippingPagesPainter extends CustomPainter {
  final double progress;
  final Color color;

  FlippingPagesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final pageWidth = 60.0;
    final pageHeight = 80.0;

    // Multiple pages with stagger
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.2;
      final pageProgress = ((progress + delay) % 1.0);
      final flipAngle = pageProgress * math.pi;
      
      final scaleX = math.cos(flipAngle).abs();
      final opacity = 0.3 + (scaleX * 0.7);

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final backPaint = Paint()
        ..color = color.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.fill;

      // Draw flipping page
      final yOffset = (i - 1) * 30.0;
      
      if (math.cos(flipAngle) > 0) {
        // Front side
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX, centerY + yOffset),
              width: pageWidth * scaleX,
              height: pageHeight,
            ),
            const Radius.circular(4),
          ),
          paint,
        );
      } else {
        // Back side
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX, centerY + yOffset),
              width: pageWidth * scaleX,
              height: pageHeight,
            ),
            const Radius.circular(4),
          ),
          backPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FlippingPagesPainter oldDelegate) => true;
}

// Painter 3: Pulsing Dates
class PulsingDatesPainter extends CustomPainter {
  final double progress;
  final Color color;

  PulsingDatesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final baseRadius = 8.0;

    // 3 concentric circles of dates
    for (int ring = 0; ring < 3; ring++) {
      final radius = 25.0 + (ring * 15.0);
      final count = 6 + (ring * 2);
      
      for (int i = 0; i < count; i++) {
        final angle = (i / count) * 2 * math.pi;
        final delay = (ring * 0.15) + (i / count) * 0.3;
        final itemProgress = ((progress + delay) % 1.0);
        
        final pulse = math.sin(itemProgress * 2 * math.pi);
        final scale = 0.6 + (pulse * 0.4);
        final opacity = 0.3 + (pulse.abs() * 0.7);

        final x = centerX + math.cos(angle) * radius;
        final y = centerY + math.sin(angle) * radius;

        final paint = Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(x, y),
          baseRadius * scale,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PulsingDatesPainter oldDelegate) => true;
}

// Painter 4: Circular Months
class CircularMonthsPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularMonthsPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = 35.0;
    final dotRadius = 6.0;

    // 12 dots representing months
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi - (math.pi / 2);
      final delay = i * 0.08;
      final itemProgress = ((progress + delay) % 1.0);
      
      final active = itemProgress > 0.5;
      final scale = active ? 1.2 : 0.8;
      final opacity = active ? 1.0 : 0.4;

      final x = centerX + math.cos(angle) * radius;
      final y = centerY + math.sin(angle) * radius;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        dotRadius * scale,
        paint,
      );
    }

    // Center circle
    final centerPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      8.0,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(CircularMonthsPainter oldDelegate) => true;
}