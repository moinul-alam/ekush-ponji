// lib/features/splash/widgets/logo_splash_widget.dart

import 'package:flutter/material.dart';

class LogoSplashWidget extends StatefulWidget {
  const LogoSplashWidget({super.key});

  @override
  State<LogoSplashWidget> createState() => _LogoSplashWidgetState();
}

class _LogoSplashWidgetState extends State<LogoSplashWidget>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _glowController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotation;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _glowPulse;

  static const _logoDuration  = Duration(milliseconds: 1000);
  static const _textDuration  = Duration(milliseconds: 700);
  static const _glowDuration  = Duration(milliseconds: 2400);
  static const _textDelay     = Duration(milliseconds: 300);

  static const double logoSize      = 140.0;
  static const double _vertSpacing  = 36.0;
  static const double _tagSpacing   = 10.0;

  // Blue palette — matches the logo's own blue tones
  static const Color _glowBlue     = Color(0xFF3A8EF6);
  static const Color _glowCyan     = Color(0xFF29C5F6);
  static const Color _textColor    = Color(0xFFE8F1FF);
  static const Color _taglineColor = Color(0xFF8BAFD4);

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
    _glowController = AnimationController(vsync: this, duration: _glowDuration)
      ..repeat(reverse: true);
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

    // Glow breathes between 0.88 and 1.0
    _glowPulse = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
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
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedLogo(
          logoController: _logoController,
          glowController: _glowController,
          logoScale: _logoScale,
          logoRotation: _logoRotation,
          logoFade: _logoFade,
          glowPulse: _glowPulse,
          glowBlue: _glowBlue,
          glowCyan: _glowCyan,
        ),
        const SizedBox(height: _vertSpacing),
        _AnimatedAppName(
          textController: _textController,
          textSlide: _textSlide,
          textFade: _textFade,
          textColor: _textColor,
        ),
        const SizedBox(height: _tagSpacing),
        _AnimatedTagline(
          textController: _textController,
          textFade: _textFade,
          taglineColor: _taglineColor,
        ),
      ],
    );
  }
}

// ─── Logo ──────────────────────────────────────────────────────────────────

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.logoController,
    required this.glowController,
    required this.logoScale,
    required this.logoRotation,
    required this.logoFade,
    required this.glowPulse,
    required this.glowBlue,
    required this.glowCyan,
  });

  final AnimationController logoController;
  final AnimationController glowController;
  final Animation<double> logoScale;
  final Animation<double> logoRotation;
  final Animation<double> logoFade;
  final Animation<double> glowPulse;
  final Color glowBlue;
  final Color glowCyan;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([logoController, glowController]),
      builder: (context, _) {
        return Transform.scale(
          scale: logoScale.value,
          child: Transform.rotate(
            angle: logoRotation.value,
            child: Opacity(
              opacity: logoFade.value,
              child: _LogoWithGlow(
                glowPulse: glowPulse.value,
                glowBlue: glowBlue,
                glowCyan: glowCyan,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoWithGlow extends StatelessWidget {
  const _LogoWithGlow({
    required this.glowPulse,
    required this.glowBlue,
    required this.glowCyan,
  });

  final double glowPulse;
  final Color glowBlue;
  final Color glowCyan;

  @override
  Widget build(BuildContext context) {
    const size = _LogoSplashWidgetState.logoSize;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outermost ambient blue halo
          _GlowCircle(
            diameter: size * 1.8 * glowPulse,
            color: glowBlue,
            opacity: 0.08,
          ),
          // Mid blue ring
          _GlowCircle(
            diameter: size * 1.35 * glowPulse,
            color: glowBlue,
            opacity: 0.16,
          ),
          // Inner cyan bloom — closest to logo, matches its highlights
          _GlowCircle(
            diameter: size * 1.05,
            color: glowCyan,
            opacity: 0.12 * glowPulse,
          ),
          // Logo — no tint, no overlay, renders cleanly on dark bg
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.calendar_month_rounded,
                size: 90,
                color: Color(0xFF3A8EF6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

// ─── App name ──────────────────────────────────────────────────────────────

class _AnimatedAppName extends StatelessWidget {
  const _AnimatedAppName({
    required this.textController,
    required this.textSlide,
    required this.textFade,
    required this.textColor,
  });

  final AnimationController textController;
  final Animation<Offset> textSlide;
  final Animation<double> textFade;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: textController,
      builder: (context, _) {
        return SlideTransition(
          position: textSlide,
          child: FadeTransition(
            opacity: textFade,
            child: Text(
              'Ekush Ponji',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: const Color(0xFF3A8EF6).withValues(alpha: 0.4),
                    offset: const Offset(0, 0),
                    blurRadius: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Tagline ───────────────────────────────────────────────────────────────

class _AnimatedTagline extends StatelessWidget {
  const _AnimatedTagline({
    required this.textController,
    required this.textFade,
    required this.taglineColor,
  });

  final AnimationController textController;
  final Animation<double> textFade;
  final Color taglineColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: textController,
      builder: (context, _) {
        return FadeTransition(
          opacity: textFade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Bangla, English & Arabic calendar with Holidays\nNamaz Times, Events & more.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: taglineColor,
                letterSpacing: 0.4,
                height: 1.6,
              ),
            ),
          ),
        );
      },
    );
  }
}