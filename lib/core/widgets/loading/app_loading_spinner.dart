import 'package:flutter/material.dart';

class AppLoadingSpinner extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const AppLoadingSpinner({
    super.key,
    this.size = 28,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}
