// lib/core/widgets/error/app_init_error_screen.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/themes/color_schemes.dart';
import 'package:ekush_ponji/features/about/about_content.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInitErrorScreen extends StatefulWidget {
  final Object error;
  final StackTrace stackTrace;
  final Future<void> Function() onRetry;

  const AppInitErrorScreen({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.onRetry,
  });

  @override
  State<AppInitErrorScreen> createState() => _AppInitErrorScreenState();
}

class _AppInitErrorScreenState extends State<AppInitErrorScreen> {
  int _retryCount = 0;
  bool _isRetrying = false;
  String? _retryError;

  static const int _maxRetries = 2;

  static const Color _primary = Color(0xFF006B54);
  static const Color _surface = Color(0xFFFBFDF9);
  static const Color _onSurface = Color(0xFF191C1A);
  static const Color _onSurfaceVariant = Color(0xFF404943);
  static const Color _errorColor = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);

  Future<void> _handleRetry() async {
    setState(() {
      _isRetrying = true;
      _retryError = null;
    });

    try {
      await widget.onRetry();
      // If retry succeeds, onRetry will call runApp again
      // so we don't need to do anything here
    } catch (e) {
      setState(() {
        _retryCount++;
        _isRetrying = false;
        _retryError = e.toString();
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showSupportOptions = _retryCount >= _maxRetries;

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
                    Icons.error_outline_rounded,
                    size: 42,
                    color: _errorColor,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Bengali title ─────────────────────────────
                const Text(
                  'অ্যাপ চালু হতে সমস্যা হয়েছে',
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
                  'Failed to start the app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Bengali description ───────────────────────
                Text(
                  showSupportOptions
                      ? 'বারবার চেষ্টা করেও সমস্যা সমাধান হচ্ছে না। অ্যাপটি পুনরায় ইনস্টল করার চেষ্টা করুন অথবা আমাদের সাথে যোগাযোগ করুন।'
                      : 'অ্যাপের প্রয়োজনীয় তথ্য লোড করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 8),

                // ── English description ───────────────────────
                Text(
                  showSupportOptions
                      ? 'The problem persists after multiple attempts. Try reinstalling the app or contact us for help.'
                      : 'Could not load app data. Please try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                // ── Retry error message ───────────────────────
                if (_retryError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _retryError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _errorColor,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // ── Retry button ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isRetrying ? null : _handleRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isRetrying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded,
                            color: Colors.white),
                    label: Text(
                      _isRetrying
                          ? 'চেষ্টা করা হচ্ছে... / Retrying...'
                          : 'আবার চেষ্টা করুন / Try Again',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                // ── Support options (after max retries) ───────
                if (showSupportOptions) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(
                        'mailto:ekushponji@gmail.com?subject=App%20Startup%20Error',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.email_outlined),
                      label: const Text(
                        'ইমেইল করুন / Email Us',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(AboutContent.websiteUrl),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.language_rounded),
                      label: const Text(
                        'ওয়েবসাইট / Website',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
