// lib/features/splash/widgets/logo_splash_widget.dart

import 'package:flutter/material.dart';

class LogoSplashWidget extends StatefulWidget {
  const LogoSplashWidget({super.key});

  @override
  State<LogoSplashWidget> createState() => _LogoSplashWidgetState();
}

class _LogoSplashWidgetState extends State<LogoSplashWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
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
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Image.asset(
            'assets/images/splash_logo.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.calendar_month_rounded,
              size: 120,
              color: Color(0xFF3A8EF6),
            ),
          ),

          const SizedBox(height: 24),

          // App title banner image
          Image.asset(
            'assets/images/app_title.png',
            height: 44,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => Text(
              'একুশ পঞ্জি',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: const Color(0xFFE8F1FF),
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
