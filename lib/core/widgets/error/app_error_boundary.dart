// lib/core/widgets/error/app_error_boundary.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/themes/color_schemes.dart';

class AppErrorBoundary extends StatefulWidget {
  final Widget child;

  const AppErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const AppErrorWidget({
    super.key,
    required this.details,
  });

  static const Color _primary = Color(0xFF006B54);
  static const Color _surface = Color(0xFFFBFDF9);
  static const Color _onSurface = Color(0xFF191C1A);
  static const Color _onSurfaceVariant = Color(0xFF404943);
  static const Color _errorColor = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: AppColorSchemes.lightColorScheme,
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: _surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // ── Icon ──────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 42,
                    color: _errorColor,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Bengali title ─────────────────────────────
                const Text(
                  'কিছু একটা ভুল হয়েছে',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _onSurface,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                // ── English title ─────────────────────────────
                const Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Bengali description ───────────────────────
                const Text(
                  'অ্যাপে একটি অপ্রত্যাশিত সমস্যা হয়েছে। অ্যাপটি বন্ধ করে আবার চালু করুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 8),

                // ── English description ───────────────────────
                const Text(
                  'An unexpected error occurred. Please close and restart the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: _onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                // ── Error detail (debug only) ─────────────────
                if (details.exceptionAsString().isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      details.exceptionAsString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: _errorColor,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
