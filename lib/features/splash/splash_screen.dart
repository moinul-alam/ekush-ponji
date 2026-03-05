import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/splash/widgets/logo_splash_widget.dart';
import 'package:ekush_ponji/features/splash/widgets/app_loading_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
              theme.colorScheme.primaryContainer,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles — visible but still soft
            _buildBackgroundCircles(size),

            // Main content — logo + text, vertically centered
            const Center(
              child: LogoSplashWidget(),
            ),

            // Loading indicator pinned to bottom
            Positioned(
              bottom: 72,
              left: 0,
              right: 0,
              child: Center(
                child: AppLoadingWidget(
                  color: Colors.white.withValues(alpha: 0.75),
                  animationType: AnimationType.bouncingWeekdays,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCircles(Size size) {
    // Slightly more visible (alpha 20 vs old 13) so they read as intentional
    // but still very soft against the gradient
    const circleAlpha = 20;

    return Stack(
      children: [
        // Top-right: medium circle
        Positioned(
          top: -80,
          right: -80,
          child: _BackgroundCircle(
            size: 280,
            alpha: circleAlpha,
          ),
        ),
        // Top-right: smaller inner circle for depth
        Positioned(
          top: 20,
          right: 20,
          child: _BackgroundCircle(
            size: 120,
            alpha: circleAlpha - 6,
          ),
        ),
        // Bottom-left: large circle
        Positioned(
          bottom: -120,
          left: -80,
          child: _BackgroundCircle(
            size: 380,
            alpha: circleAlpha,
          ),
        ),
        // Bottom-left: smaller inner circle for depth
        Positioned(
          bottom: 80,
          left: 60,
          child: _BackgroundCircle(
            size: 100,
            alpha: circleAlpha - 6,
          ),
        ),
      ],
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({
    required this.size,
    required this.alpha,
  });

  final double size;
  final int alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
  }
}