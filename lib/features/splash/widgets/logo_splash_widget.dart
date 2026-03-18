// lib/features/splash/widgets/logo_splash_widget.dart

import 'package:flutter/material.dart';

const Color _kGlowBlue = Color(0xFF3A8EF6);
const Color _kGlowCyan = Color(0xFF29C5F6);
const Color _kTextColor = Color(0xFFE8F1FF);
const Color _kTaglineColor = Color(0xFF8BAFD4);

// ── LogoSplashWidget ───────────────────────────────────────────────────────

class LogoSplashWidget extends StatefulWidget {
  const LogoSplashWidget({super.key});

  @override
  State<LogoSplashWidget> createState() => _LogoSplashWidgetState();
}

class _LogoSplashWidgetState extends State<LogoSplashWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  static const _duration = Duration(milliseconds: 500);
  static const double _logoSize = 220.0;
  static const double _vertSpacing = 36.0;
  static const double _tagSpacing = 10.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LogoWithGlow(size: _logoSize),
          const SizedBox(height: _vertSpacing),
          Text(
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
          const SizedBox(height: _tagSpacing),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'All-in-One Bangla, English & Arabic Calendar — Holidays, Events & Reminders.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _kTaglineColor,
                    letterSpacing: 0.4,
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logo with glow ────────────────────────────────────────────────────────

class _LogoWithGlow extends StatelessWidget {
  const _LogoWithGlow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _PulsingGlow(logoSize: size),
          Image.asset(
            'assets/images/splash_logo.png',
            width: size,
            height: size,
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

// ─── Pulsing Glow (isolated — never triggers parent rebuild) ───────────────

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
            _GlowCircle(
              diameter: s * 1.15 * pulse,
              color: _kGlowBlue,
              opacity: 0.08,
            ),
            _GlowCircle(
              diameter: s * 1.08 * pulse,
              color: _kGlowBlue,
              opacity: 0.16,
            ),
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
