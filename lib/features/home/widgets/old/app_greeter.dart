// lib/features/home/widgets/app_greeter.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

// ─── Time-of-day periods ──────────────────────────────────────
enum _TimePeriod { morning, afternoon, evening, night }

_TimePeriod _currentPeriod() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return _TimePeriod.morning;
  if (hour >= 12 && hour < 17) return _TimePeriod.afternoon;
  if (hour >= 17 && hour < 21) return _TimePeriod.evening;
  return _TimePeriod.night;
}

// ─── Milliseconds until the next hour boundary ───────────────
int _msUntilNextHour() {
  final now = DateTime.now();
  final next = DateTime(now.year, now.month, now.day, now.hour + 1);
  return next.difference(now).inMilliseconds;
}

// ─── Period metadata ──────────────────────────────────────────
extension _PeriodData on _TimePeriod {
  IconData get icon {
    switch (this) {
      case _TimePeriod.morning:
        return Icons.wb_sunny_rounded;
      case _TimePeriod.afternoon:
        return Icons.wb_sunny_outlined;
      case _TimePeriod.evening:
        return Icons.wb_twilight_rounded;
      case _TimePeriod.night:
        return Icons.nights_stay_rounded;
    }
  }

  String greeting(AppLocalizations l10n) {
    switch (this) {
      case _TimePeriod.morning:
        return l10n.goodMorning;
      case _TimePeriod.afternoon:
        return l10n.goodAfternoon;
      case _TimePeriod.evening:
        return l10n.goodEvening;
      case _TimePeriod.night:
        return l10n.goodNight;
    }
  }

  /// Adapts to light/dark brightness.
  List<Color> colors(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    switch (this) {
      case _TimePeriod.morning:
        return isDark
            ? [
                const Color(0xFFB56A00), 
                const Color(0xFF00513F), 
                const Color(0xFFFFE0B2),
                const Color(0xFFFFCC80),
              ]
            : [
                const Color(0xFFFFB74D),
                const Color(0xFF7FF9D4), 
                const Color(0xFF3E2000),
                const Color(0xFF7A4100),
              ];

      case _TimePeriod.afternoon:
        return isDark
            ? [
                const Color(0xFF00513F),
                const Color(0xFF244C5A),
                const Color(0xFF7FF9D4),
                const Color(0xFFA5CCDF),
              ]
            : [
                const Color(0xFF7FF9D4),
                const Color(0xFFC1E8FB),
                const Color(0xFF002117),
                const Color(0xFF006B54),
              ];

      case _TimePeriod.evening:
        return isDark
            ? [
                const Color(0xFF7A2200),
                const Color(0xFF334B42),
                const Color(0xFFFFCCBC),
                const Color(0xFFFF8A65),
              ]
            : [
                const Color(0xFFFF7043),
                const Color(0xFFCCE8DB),
                const Color(0xFF3E0A00),
                const Color(0xFF8B2500),
              ];

      case _TimePeriod.night:
        return isDark
            ? [
                const Color(0xFF1A237E),
                const Color(0xFF0D2B1F),
                const Color(0xFFBBDEFB),
                const Color(0xFF90CAF9),
              ]
            : [
                const Color(0xFF303F9F),
                const Color(0xFF1B4332),
                const Color(0xFFE8EAF6),
                const Color(0xFFBBDEFB),
              ];
    }
  }
}

// ─── Widget ───────────────────────────────────────────────────
class AppGreeter extends StatefulWidget {
  const AppGreeter({super.key});

  @override
  State<AppGreeter> createState() => _AppGreeterState();
}

class _AppGreeterState extends State<AppGreeter>
    with TickerProviderStateMixin {
  // ── Period state ────────────────────────────────────────────
  late _TimePeriod _period;
  Timer? _boundaryTimer;

  // ── Entrance animation ──────────────────────────────────────
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Icon pulse animation ────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Period change cross-fade ────────────────────────────────
  late AnimationController _crossFadeController;
  late Animation<double> _crossFadeAnim;

  // ── Watermark rotation ──────────────────────────────────────
  late AnimationController _watermarkRotationController;

  @override
  void initState() {
    super.initState();
    _period = _currentPeriod();

    _setupEntranceAnimation();
    _setupPulseAnimation();
    _setupCrossFadeAnimation();
    _setupWatermarkRotation();
    _scheduleBoundaryTimer();

    // Watermark rotates immediately, independently
    _watermarkRotationController.repeat();

    // Start entrance, then start pulse after it completes
    _entranceController.forward().then((_) {
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

  // ── Animation setup ─────────────────────────────────────────
  void _setupEntranceAnimation() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _setupCrossFadeAnimation() {
    _crossFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _crossFadeAnim = CurvedAnimation(
      parent: _crossFadeController,
      curve: Curves.easeInOut,
    );
  }

  void _setupWatermarkRotation() {
    _watermarkRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    );
  }

  // ── Timer ────────────────────────────────────────────────────
  void _scheduleBoundaryTimer() {
    _boundaryTimer?.cancel();
    _boundaryTimer = Timer(
      Duration(milliseconds: _msUntilNextHour()),
      _onHourBoundary,
    );
  }

  void _onHourBoundary() {
    final newPeriod = _currentPeriod();
    if (newPeriod != _period) {
      _crossFadeController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() => _period = newPeriod);
          _crossFadeController.reverse();
        }
      });
    }
    _scheduleBoundaryTimer(); // reschedule for next boundary
  }

  @override
  void dispose() {
    _boundaryTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    _crossFadeController.dispose();
    _watermarkRotationController.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final l10n = AppLocalizations.of(context);
    final colors = _period.colors(brightness);

    final gradientStart = colors[0];
    final gradientEnd = colors[1];
    final textColor = colors[2];
    final iconColor = colors[3];

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          // Cross-fade on period change (fade out → update → fade in)
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_crossFadeAnim),
          child: _GreeterCard(
            period: _period,
            gradientStart: gradientStart,
            gradientEnd: gradientEnd,
            textColor: textColor,
            iconColor: iconColor,
            pulseAnim: _pulseAnim,
            watermarkRotation: _watermarkRotationController,
            greeting: _period.greeting(l10n),
          ),
        ),
      ),
    );
  }
}

// ─── Stateless card (pure UI, no logic) ──────────────────────
class _GreeterCard extends StatelessWidget {
  final _TimePeriod period;
  final Color gradientStart;
  final Color gradientEnd;
  final Color textColor;
  final Color iconColor;
  final Animation<double> pulseAnim;
  final AnimationController watermarkRotation;
  final String greeting;

  const _GreeterCard({
    required this.period,
    required this.gradientStart,
    required this.gradientEnd,
    required this.textColor,
    required this.iconColor,
    required this.pulseAnim,
    required this.watermarkRotation,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [gradientStart, gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // ── Watermark background icon ──────────────────────
            Positioned(
              right: -10,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.09,
                child: AnimatedBuilder(
                  animation: watermarkRotation,
                  builder: (context, child) => Transform.rotate(
                    angle: watermarkRotation.value * 2 * math.pi,
                    child: child,
                  ),
                  child: Icon(
                    period.icon,
                    size: 90,
                    color: iconColor,
                  ),
                ),
              ),
            ),

            // ── Foreground row ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 14),
                  Flexible(
                    child: Text(
                      greeting,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}