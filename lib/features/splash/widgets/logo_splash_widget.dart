// lib/features/splash/widgets/logo_splash_widget.dart

import 'package:flutter/material.dart';

// ── File-level color constants ─────────────────────────────────────────────
// Defined here so all private subwidgets share them without constructor params.

const Color _kGlowBlue     = Color(0xFF3A8EF6);
const Color _kGlowCyan     = Color(0xFF29C5F6);
const Color _kTextColor    = Color(0xFFE8F1FF);
const Color _kTaglineColor = Color(0xFF8BAFD4);

// ── LogoSplashWidget ───────────────────────────────────────────────────────

class LogoSplashWidget extends StatefulWidget {
  const LogoSplashWidget({super.key});

  @override
  State<LogoSplashWidget> createState() => _LogoSplashWidgetState();
}

class _LogoSplashWidgetState extends State<LogoSplashWidget>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotation;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  static const _logoDuration = Duration(milliseconds: 1000);
  static const _textDuration = Duration(milliseconds: 700);
  static const _textDelay    = Duration(milliseconds: 300);

  static const double _logoSize     = 220.0;
  static const double _vertSpacing  = 36.0;
  static const double _tagSpacing   = 10.0;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _startSequence();
  }

  void _initControllers() {
    _logoController = AnimationController(vsync: this, duration: _logoDuration);
    _textController = AnimationController(vsync: this, duration: _textDuration);
  }

  void _initAnimations() {
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.06, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _startSequence() async {
    await _logoController.forward();
    if (!mounted) return;
    await Future.delayed(_textDelay);
    if (!mounted) return;
    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedLogo(
          logoController: _logoController,
          logoScale: _logoScale,
          logoRotation: _logoRotation,
          logoFade: _logoFade,
        ),
        const SizedBox(height: _vertSpacing),
        _AnimatedAppName(
          textSlide: _textSlide,
          textFade: _textFade,
        ),
        const SizedBox(height: _tagSpacing),
        _AnimatedTagline(
          textFade: _textFade,
        ),
      ],
    );
  }
}

// ─── Logo ──────────────────────────────────────────────────────────────────

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.logoController,
    required this.logoScale,
    required this.logoRotation,
    required this.logoFade,
  });

  final AnimationController logoController;
  final Animation<double> logoScale;
  final Animation<double> logoRotation;
  final Animation<double> logoFade;

  @override
  Widget build(BuildContext context) {
    // Only rebuilds on logoController ticks — glow is fully isolated.
    return AnimatedBuilder(
      animation: logoController,
      builder: (context, _) {
        return Transform.scale(
          scale: logoScale.value,
          child: Transform.rotate(
            angle: logoRotation.value,
            child: Opacity(
              opacity: logoFade.value,
              child: const _LogoWithGlow(),
            ),
          ),
        );
      },
    );
  }
}

/// Logo image stacked on top of the pulsing glow rings.
/// Glow lives in its own StatefulWidget with its own AnimationController,
/// so the 2400 ms repeat loop never triggers a rebuild of the logo subtree.
class _LogoWithGlow extends StatelessWidget {
  const _LogoWithGlow();

  static const double _size = _LogoSplashWidgetState._logoSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow rings are isolated — they animate independently.
          const _PulsingGlow(logoSize: _size),
          // Logo fills the full SizedBox — no padding shrinking it.
          Image.asset(
            'assets/images/splash_logo.png',
            width: _size,
            height: _size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.calendar_month_rounded,
              size: 180,
              color: _kGlowBlue,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pulsing Glow (isolated StatefulWidget) ────────────────────────────────

/// Self-contained glow that runs its own 2400 ms repeating controller.
/// Extracting this means the logo scale/rotate/fade tree is never
/// dirtied by glow ticks.
class _PulsingGlow extends StatefulWidget {
  const _PulsingGlow({required this.logoSize});

  final double logoSize;

  @override
  State<_PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<_PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Glow breathes between 0.88 and 1.0
    _glowPulse = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.logoSize;
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final pulse = _glowPulse.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outermost ambient blue halo — hugs logo tightly
            _GlowCircle(
              diameter: s * 1.15 * pulse,
              color: _kGlowBlue,
              opacity: 0.08,
            ),
            // Mid blue ring
            _GlowCircle(
              diameter: s * 1.08 * pulse,
              color: _kGlowBlue,
              opacity: 0.16,
            ),
            // Inner cyan bloom — sits just behind the logo edge
            _GlowCircle(
              diameter: s * 1.0,
              color: _kGlowCyan,
              opacity: 0.12 * pulse,
            ),
          ],
        );
      },
    );
  }
}

/// Uses DecoratedBox + SizedBox instead of Container —
/// skips the extra layout sizing pass Container adds.
class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.diameter,
    required this.color,
    required this.opacity,
  });

  final double diameter;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

// ─── App name ──────────────────────────────────────────────────────────────

class _AnimatedAppName extends StatelessWidget {
  const _AnimatedAppName({
    required this.textSlide,
    required this.textFade,
  });

  final Animation<Offset> textSlide;
  final Animation<double> textFade;

  @override
  Widget build(BuildContext context) {
    // SlideTransition and FadeTransition have built-in repaint boundaries —
    // no manual AnimatedBuilder needed.
    return SlideTransition(
      position: textSlide,
      child: FadeTransition(
        opacity: textFade,
        child: Text(
          'Ekush Ponji',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: _kTextColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: _kGlowBlue.withValues(alpha: 0.4),
                offset: Offset.zero,
                blurRadius: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tagline ───────────────────────────────────────────────────────────────

class _AnimatedTagline extends StatelessWidget {
  const _AnimatedTagline({
    required this.textFade,
  });

  final Animation<double> textFade;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: textFade,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Text(
          'Bangla, English & Arabic calendar with Holidays\nNamaz Times, Events & more.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _kTaglineColor,
            letterSpacing: 0.4,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}