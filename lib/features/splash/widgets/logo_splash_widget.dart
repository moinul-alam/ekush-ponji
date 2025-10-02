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
  late final AnimationController _shimmerController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotation;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _shimmerPosition;

  // Animation constants
  static const _logoDuration = Duration(milliseconds: 1200);
  static const _textDuration = Duration(milliseconds: 800);
  static const _shimmerDuration = Duration(milliseconds: 1500);
  static const _textDelay = Duration(milliseconds: 400);

  // Design constants
  static const _logoSize = 140.0;
  static const _logoRadius = 32.0;
  static const _logoPadding = 20.0;
  static const _verticalSpacing = 40.0;
  static const _taglineSpacing = 12.0;

  // Alpha values for better performance
  static const _shadowAlpha = 51; // 0.2 opacity
  static const _shimmerAlpha = 77; // 0.3 opacity
  static const _taglineAlpha = 242; // 0.95 opacity

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

    _shimmerController = AnimationController(
      vsync: this,
      duration: _shimmerDuration,
    )..repeat();
  }

  void _initializeAnimations() {
    // Logo animations with optimized curves
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoRotation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    // Text animations
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Shimmer animation
    _shimmerPosition = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startAnimationSequence() async {
    await _logoController.forward();
    if (mounted) {
      await Future.delayed(_textDelay);
      if (mounted) {
        await _textController.forward();
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedLogo(
          logoController: _logoController,
          shimmerController: _shimmerController,
          logoScale: _logoScale,
          logoRotation: _logoRotation,
          logoFade: _logoFade,
          shimmerPosition: _shimmerPosition,
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

// Extracted Logo Widget for better maintainability
class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.logoController,
    required this.shimmerController,
    required this.logoScale,
    required this.logoRotation,
    required this.logoFade,
    required this.shimmerPosition,
  });

  final AnimationController logoController;
  final AnimationController shimmerController;
  final Animation<double> logoScale;
  final Animation<double> logoRotation;
  final Animation<double> logoFade;
  final Animation<double> shimmerPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: logoController,
      builder: (context, _) {
        return Transform.scale(
          scale: logoScale.value,
          child: Transform.rotate(
            angle: logoRotation.value,
            child: Opacity(
              opacity: logoFade.value,
              child: _LogoContainer(
                shimmerController: shimmerController,
                shimmerPosition: shimmerPosition,
                primaryColor: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoContainer extends StatelessWidget {
  const _LogoContainer({
    required this.shimmerController,
    required this.shimmerPosition,
    required this.primaryColor,
  });

  final AnimationController shimmerController;
  final Animation<double> shimmerPosition;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _LogoSplashWidgetState._logoSize,
      height: _LogoSplashWidgetState._logoSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_LogoSplashWidgetState._logoRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(_LogoSplashWidgetState._shadowAlpha),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ShimmerEffect(
            shimmerController: shimmerController,
            shimmerPosition: shimmerPosition,
          ),
          _LogoImage(primaryColor: primaryColor),
        ],
      ),
    );
  }
}

class _ShimmerEffect extends StatelessWidget {
  const _ShimmerEffect({
    required this.shimmerController,
    required this.shimmerPosition,
  });

  final AnimationController shimmerController;
  final Animation<double> shimmerPosition;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, _) {
        return ClipRRect(
          borderRadius:
              BorderRadius.circular(_LogoSplashWidgetState._logoRadius),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Colors.transparent,
                  Color.fromRGBO(255, 255, 255,
                      _LogoSplashWidgetState._shimmerAlpha / 255),
                  Colors.transparent,
                ],
                stops: [
                  (shimmerPosition.value - 0.3).clamp(0.0, 1.0),
                  shimmerPosition.value.clamp(0.0, 1.0),
                  (shimmerPosition.value + 0.3).clamp(0.0, 1.0),
                ],
              ).createShader(bounds);
            },
            child: Container(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class _LogoImage extends StatelessWidget {
  const _LogoImage({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_LogoSplashWidgetState._logoPadding),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.calendar_month_rounded,
            size: 70,
            color: primaryColor,
          );
        },
      ),
    );
  }
}

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
                    color: Colors.black
                        .withAlpha(_LogoSplashWidgetState._shadowAlpha),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
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
              color: const Color.fromRGBO(
                  255, 255, 255, _LogoSplashWidgetState._taglineAlpha / 255),
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
}
