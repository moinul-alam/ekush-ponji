// lib/features/splash/widgets/logo_splash_widget.dart

import 'package:flutter/material.dart';

/// Splash animation sequence:
///   Entry  — logo scales 0.7→1.0 + fades in (600ms easeOutBack)
///             title slides up 20px + fades in (500ms easeOutCubic, 200ms delay)
///   Idle   — logo gently pulses scale 1.0→1.04→1.0 (1800ms loop)
///             plays after entry completes, keeps splash alive if app not ready
///
/// [onAnimationComplete] fires once when the entry animation finishes.
class LogoSplashWidget extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const LogoSplashWidget({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<LogoSplashWidget> createState() => _LogoSplashWidgetState();
}

class _LogoSplashWidgetState extends State<LogoSplashWidget>
    with TickerProviderStateMixin {
  // Entry animation controller (runs once, 700ms)
  late final AnimationController _entryController;

  // Idle pulse controller (loops after entry, 1800ms)
  late final AnimationController _pulseController;

  // Entry — logo
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // Entry — title
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleFade;

  // Idle — logo pulse
  late final Animation<double> _pulseScale;

  bool _entryDone = false;

  @override
  void initState() {
    super.initState();

    // ── Entry controller (0.0 → 1.0 = 700ms) ─────────────────────────────────
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Logo: scale 0.7→1.0 with easeOutBack, fade 0→1 faster
    _logoScale = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.86, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOut),
      ),
    );

    // Title: slide 20px→0 + fade 0→1, starts at 200ms (interval 0.29)
    final titleCurve = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.29, 1.0, curve: Curves.easeOutCubic),
    );
    _titleSlide = Tween<double>(begin: 20.0, end: 0.0).animate(titleCurve);
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(titleCurve);

    // ── Idle pulse controller (loops after entry, 1800ms per cycle) ───────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Run entry, then notify + start idle pulse
    _entryController.forward().then((_) {
      if (!mounted) return;
      setState(() => _entryDone = true);
      widget.onAnimationComplete?.call();
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _pulseController]),
      builder: (context, _) {
        final logoScaleValue =
            _entryDone ? _pulseScale.value : _logoScale.value;
        final logoOpacity = _entryDone ? 1.0 : _logoFade.value;
        final titleOpacity = _entryDone ? 1.0 : _titleFade.value;
        final titleOffset = _entryDone ? 0.0 : _titleSlide.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Logo ──────────────────────────────────────────────────────────
            Opacity(
              opacity: logoOpacity,
              child: Transform.scale(
                scale: logoScaleValue,
                child: Image.asset(
                  'assets/images/header_logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.calendar_month_rounded,
                    size: 120,
                    color:
                        Color(0xFF006B54), // primary green — visible on white
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Title ─────────────────────────────────────────────────────────
            Opacity(
              opacity: titleOpacity,
              child: Transform.translate(
                offset: Offset(0, titleOffset),
                child: Image.asset(
                  'assets/images/app_title.png',
                  height: 44,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => const Text(
                    'একুশ পঞ্জি',
                    style: TextStyle(
                      fontFamily: 'Kalpurush',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color:
                          Color(0xFF006B54), // primary green — visible on white
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
