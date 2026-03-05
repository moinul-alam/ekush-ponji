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

  // Animation durations
  static const _logoDuration = Duration(milliseconds: 1200);
  static const _textDuration = Duration(milliseconds: 800);
  static const _glowDuration = Duration(milliseconds: 2000);
  static const _textDelay = Duration(milliseconds: 400);

  // Design constants
  static const double logoSize = 140.0;
  static const _verticalSpacing = 40.0;
  static const _taglineSpacing = 12.0;
  static const _shadowAlpha = 51; // 0.2 opacity

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeControllers() {
    _logoController = AnimationController(
      vsync: this,
      duration: _logoDuration,
    );

    _textController = AnimationController(
      vsync: this,
      duration: _textDuration,
    );

    // Glow pulses continuously but softly
    _glowController = AnimationController(
      vsync: this,
      duration: _glowDuration,
    )..repeat(reverse: true);
  }

  void _initializeAnimations() {
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Glow radius pulses between 0.85 and 1.0 scale — subtle breathing effect
    _glowPulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startAnimationSequence() async {
    await _logoController.forward();
    if (!mounted) return;
    await Future.delayed(_textDelay);
    if (!mounted) return;
    await _textController.forward();
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
        ),
        const SizedBox(height: _verticalSpacing),
        _AnimatedAppName(
          textController: _textController,
          textSlide: _textSlide,
          textFade: _textFade,
        ),
        const SizedBox(height: _taglineSpacing),
        _AnimatedTagline(
          textController: _textController,
          textFade: _textFade,
        ),
      ],
    );
  }
}

// ─── Logo with transparent background + glow ───────────────────────────────

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.logoController,
    required this.glowController,
    required this.logoScale,
    required this.logoRotation,
    required this.logoFade,
    required this.glowPulse,
  });

  final AnimationController logoController;
  final AnimationController glowController;
  final Animation<double> logoScale;
  final Animation<double> logoRotation;
  final Animation<double> logoFade;
  final Animation<double> glowPulse;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                primaryColor: primaryColor,
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
    required this.primaryColor,
  });

  final double glowPulse;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    const size = _LogoSplashWidgetState.logoSize;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ambient glow — largest, most transparent
          _GlowRing(
            size: size * 1.5 * glowPulse,
            color: Colors.white,
            opacity: 0.06,
          ),
          // Middle glow ring
          _GlowRing(
            size: size * 1.2 * glowPulse,
            color: Colors.white,
            opacity: 0.10,
          ),
          // Inner tight glow — closest to logo
          _GlowRing(
            size: size * 1.0,
            color: Colors.white,
            opacity: 0.08 * glowPulse,
          ),
          // The logo itself — no background, no border
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.calendar_month_rounded,
                  size: 90,
                  color: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowRing extends StatelessWidget {
  const _GlowRing({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
  });

  final AnimationController textController;
  final Animation<Offset> textSlide;
  final Animation<double> textFade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: textController,
      builder: (context, _) {
        return SlideTransition(
          position: textSlide,
          child: FadeTransition(
            opacity: textFade,
            child: Text(
              'Ekush Ponji',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
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
  });

  final AnimationController textController;
  final Animation<double> textFade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: textController,
      builder: (context, _) {
        return FadeTransition(
          opacity: textFade,
          child: Text(
            'Bengali Calendar & Events',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.80),
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
}