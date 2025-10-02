import 'package:flutter/material.dart';

/// A layout helper that handles the arrangement of all home widgets
/// Provides consistent spacing and responsive behavior
class HomeGridLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const HomeGridLayout({
    super.key,
    required this.children,
    this.padding,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding ?? const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children.map((child) {
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: child,
            );
          }),
        ],
      ),
    );
  }
}

/// Helper class for creating responsive grid layouts
/// Can be used for future features like 2-column layouts on tablets
class HomeGridItem extends StatelessWidget {
  final Widget child;
  final int flex;

  const HomeGridItem({
    super.key,
    required this.child,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }
}

/// Helper for creating two-column layouts when needed
class HomeGridRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double spacing;

  const HomeGridRow({
    super.key,
    required this.left,
    required this.right,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: spacing),
        Expanded(child: right),
      ],
    );
  }
}
