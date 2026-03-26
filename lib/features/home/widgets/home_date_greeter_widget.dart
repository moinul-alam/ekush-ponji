// lib/features/home/widgets/home_date_greeter_widget.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calendar/services/bengali_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/services/hijri_calendar_service.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:ekush_ponji/features/home/home_viewmodel.dart';
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart';
import 'package:ekush_ponji/features/words/words_viewmodel.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

// ── Constants ─────────────────────────────────────────────────

const String _shimmerCapableKey = 'greeter_shimmer_capable';
const int _frameCheckCount = 5;
const double _frameThresholdMs = 18.0;

// ── Time period ───────────────────────────────────────────────

enum _TimePeriod { morning, afternoon, evening, night }

_TimePeriod _currentPeriod() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return _TimePeriod.morning;
  if (hour >= 12 && hour < 17) return _TimePeriod.afternoon;
  if (hour >= 17 && hour < 21) return _TimePeriod.evening;
  return _TimePeriod.night;
}

int _msUntilNextHour() {
  final now = DateTime.now();
  final next = DateTime(now.year, now.month, now.day, now.hour + 1);
  return next.difference(now).inMilliseconds;
}

extension _PeriodData on _TimePeriod {
  IconData get icon {
    switch (this) {
      case _TimePeriod.morning:
        return Icons.wb_sunny_rounded;
      case _TimePeriod.afternoon:
        return Icons.wb_sunny_outlined;
      case _TimePeriod.evening:
        return Icons.wb_twilight_rounded;
      case _TimePeriod.night:
        return Icons.nights_stay_rounded;
    }
  }

  String greeting(AppLocalizations l10n) {
    switch (this) {
      case _TimePeriod.morning:
        return l10n.goodMorning;
      case _TimePeriod.afternoon:
        return l10n.goodAfternoon;
      case _TimePeriod.evening:
        return l10n.goodEvening;
      case _TimePeriod.night:
        return l10n.goodNight;
    }
  }

  List<Color> colors(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (this) {
      case _TimePeriod.morning:
        return isDark
            ? [
                const Color(0xFFB56A00),
                const Color(0xFF00513F),
                const Color(0xFFFFE0B2),
                const Color(0xFFFFCC80)
              ]
            : [
                const Color(0xFFFFB74D),
                const Color(0xFF7FF9D4),
                const Color(0xFF3E2000),
                const Color(0xFF7A4100)
              ];
      case _TimePeriod.afternoon:
        return isDark
            ? [
                const Color(0xFF00513F),
                const Color(0xFF244C5A),
                const Color(0xFF7FF9D4),
                const Color(0xFFA5CCDF)
              ]
            : [
                const Color(0xFF7FF9D4),
                const Color(0xFFC1E8FB),
                const Color(0xFF002117),
                const Color(0xFF006B54)
              ];
      case _TimePeriod.evening:
        return isDark
            ? [
                const Color(0xFF7A2200),
                const Color(0xFF334B42),
                const Color(0xFFFFCCBC),
                const Color(0xFFFF8A65)
              ]
            : [
                const Color(0xFFFF7043),
                const Color(0xFFCCE8DB),
                const Color(0xFF3E0A00),
                const Color(0xFF8B2500)
              ];
      case _TimePeriod.night:
        return isDark
            ? [
                const Color(0xFF1A237E),
                const Color(0xFF0D2B1F),
                const Color(0xFFBBDEFB),
                const Color(0xFF90CAF9)
              ]
            : [
                const Color(0xFF303F9F),
                const Color(0xFF1B4332),
                const Color(0xFFE8EAF6),
                const Color(0xFFBBDEFB)
              ];
    }
  }
}

// ── Gregorian helpers ─────────────────────────────────────────

const List<String> _enMonths = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _enGregorianSeason(int month) {
  if (month >= 3 && month <= 5) return 'Spring';
  if (month >= 6 && month <= 8) return 'Summer';
  if (month >= 9 && month <= 11) return 'Autumn';
  return 'Winter';
}

// ── Performance checker ───────────────────────────────────────

class _PerformanceChecker {
  static Future<bool> isShimmerCapable() async {
    final prefs = await SharedPreferences.getInstance();

    // Return cached result if available
    if (prefs.containsKey(_shimmerCapableKey)) {
      return prefs.getBool(_shimmerCapableKey) ?? false;
    }

    // Measure average frame time over _frameCheckCount frames
    final frameTimes = <double>[];
    final completer = Completer<bool>();

    int frameCount = 0;
    int? lastTimestamp;

    late void Function(Duration) frameCallback;
    frameCallback = (Duration timestamp) {
      final ms = timestamp.inMicroseconds / 1000.0;
      if (lastTimestamp != null) {
        frameTimes.add(ms - lastTimestamp!);
      }
      lastTimestamp = ms.toInt();
      frameCount++;

      if (frameCount < _frameCheckCount) {
        SchedulerBinding.instance.scheduleFrameCallback(frameCallback);
      } else {
        final avg = frameTimes.isEmpty
            ? 0.0
            : frameTimes.reduce((a, b) => a + b) / frameTimes.length;
        final capable = avg <= _frameThresholdMs;
        prefs.setBool(_shimmerCapableKey, capable);
        completer.complete(capable);
      }
    };

    SchedulerBinding.instance.scheduleFrameCallback(frameCallback);
    return completer.future;
  }
}

// ── Main widget ───────────────────────────────────────────────

class HomeDateGreeterWidget extends ConsumerStatefulWidget {
  const HomeDateGreeterWidget({super.key});

  @override
  ConsumerState<HomeDateGreeterWidget> createState() =>
      _HomeDateGreeterWidgetState();
}

class _HomeDateGreeterWidgetState extends ConsumerState<HomeDateGreeterWidget>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late _TimePeriod _period;
  late DateTime _lastRebuildDate;
  Timer? _boundaryTimer;
  bool _shimmerEnabled = false;

  // Entrance
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Period cross-fade
  late AnimationController _crossFadeController;
  late Animation<double> _crossFadeAnim;

  // Directional movement — behavior changes per period
  late AnimationController _directionalController;
  late Animation<double> _directionalAnim;

  // Pulse/breathe — used after sun reaches top (morning/evening)
  // and for afternoon heat haze
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Shimmer — only on capable devices
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _period = _currentPeriod();
    final now = DateTime.now();
    _lastRebuildDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addObserver(this);
    _setupEntranceAnimation();
    _setupCrossFadeAnimation();
    _setupDirectionalAnimation();
    _setupPulseAnimation();
    _setupShimmerAnimation();
    _scheduleBoundaryTimer();
    _startAnimations();
    _checkPerformance();
  }

  // ── Setup ──────────────────────────────────────────────────

  void _setupEntranceAnimation() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _setupCrossFadeAnimation() {
    _crossFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _crossFadeAnim = CurvedAnimation(
      parent: _crossFadeController,
      curve: Curves.easeInOut,
    );
  }

  void _setupDirectionalAnimation() {
    _directionalController = AnimationController(
      vsync: this,
      duration: _directionalDuration,
    );
    _directionalAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _directionalController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _setupShimmerAnimation() {
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  // ── Directional duration per period ───────────────────────

  Duration get _directionalDuration {
    switch (_period) {
      case _TimePeriod.morning:
        return const Duration(milliseconds: 3000);
      case _TimePeriod.afternoon:
        return const Duration(milliseconds: 2000);
      case _TimePeriod.evening:
        return const Duration(milliseconds: 3000);
      case _TimePeriod.night:
        return const Duration(milliseconds: 8000);
    }
  }

  // ── Start animations ───────────────────────────────────────

  void _startAnimations() {
    _entranceController.forward().then((_) {
      if (!mounted) return;
      _startDirectionalForPeriod();
    });
  }

  void _startDirectionalForPeriod() {
    if (!mounted) return;
    _directionalController.duration = _directionalDuration;

    switch (_period) {
      case _TimePeriod.morning:
        // Sun rises once, then pulse begins
        _directionalController.forward().then((_) {
          if (mounted) _pulseController.repeat(reverse: true);
        });
        break;

      case _TimePeriod.afternoon:
        // Heat haze — pulse immediately
        _pulseController.repeat(reverse: true);
        break;

      case _TimePeriod.evening:
        // Sun sets once, then pulse at bottom
        _directionalController.forward().then((_) {
          if (mounted) _pulseController.repeat(reverse: true);
        });
        break;

      case _TimePeriod.night:
        // Moon arcs continuously left to right
        _directionalController.repeat();
        break;
    }
  }

  // ── Performance check ──────────────────────────────────────

  Future<void> _checkPerformance() async {
    // Also respect OS-level reduce motion setting
    final reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.reduceMotion;

    if (reduceMotion) {
      if (mounted) setState(() => _shimmerEnabled = false);
      return;
    }

    final capable = await _PerformanceChecker.isShimmerCapable();
    if (mounted) {
      setState(() {
        _shimmerEnabled = capable;
      });
      if (capable) _shimmerController.repeat();
    }
  }

  // ── Lifecycle — pause/resume animations ───────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _directionalController.stop();
        _pulseController.stop();
        _shimmerController.stop();
        break;
      case AppLifecycleState.resumed:
        _startDirectionalForPeriod();
        if (_shimmerEnabled) _shimmerController.repeat();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  // ── Period boundary ────────────────────────────────────────

  void _scheduleBoundaryTimer() {
    _boundaryTimer?.cancel();
    _boundaryTimer = Timer(
      Duration(milliseconds: _msUntilNextHour()),
      _onHourBoundary,
    );
  }

  void _onHourBoundary() {
    // Guard: widget may have been disposed before timer fired
    if (!mounted) return;

    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final dayChanged = currentDate != _lastRebuildDate;

    if (dayChanged) {
      _lastRebuildDate = currentDate;
      // Read providers only if still mounted — ref is valid while mounted
      ref.invalidate(quotesViewModelProvider);
      ref.invalidate(wordsViewModelProvider);
      ref.read(homeViewModelProvider.notifier).refresh();
    }

    final newPeriod = _currentPeriod();
    if (newPeriod != _period) {
      // Guard inside async callback too
      _crossFadeController.forward(from: 0).then((_) {
        if (!mounted) return;
        setState(() => _period = newPeriod);
        _crossFadeController.reverse();
        _directionalController.reset();
        _pulseController.reset();
        _startDirectionalForPeriod();
      });
    } else if (dayChanged && mounted) {
      setState(() {});
    }

    // Only reschedule if still mounted
    if (mounted) _scheduleBoundaryTimer();
  }

  @override
  void dispose() {
    _boundaryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _entranceController.dispose();
    _crossFadeController.dispose();
    _directionalController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = _period.colors(theme.brightness);

    final bengaliDate =
        ref.watch(bengaliCalendarServiceProvider).getBengaliDate(now);
    final hijriDate = ref.watch(hijriCalendarServiceProvider).getHijriDate(now);

    final gradientStart = colors[0];
    final gradientEnd = colors[1];
    final textColor = colors[2];
    final iconColor = colors[3];

    final greeting = _period.greeting(l10n);
    final todayIsDayName =
        '${l10n.todayIsDayName} ${l10n.getDayName(now.weekday)}';

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_crossFadeAnim),
          child: HomeSectionWidget(
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            onTap: () => context.go(RouteNames.calendar),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  _GreeterHeader(
                    period: _period,
                    gradientStart: gradientStart,
                    gradientEnd: gradientEnd,
                    textColor: textColor,
                    iconColor: iconColor,
                    directionalAnim: _directionalAnim,
                    pulseAnim: _pulseAnim,
                    shimmerAnim: _shimmerEnabled ? _shimmerAnim : null,
                    greeting: greeting,
                    todayIsDayName: todayIsDayName,
                  ),
                  _DateRow(
                    dayNum: now.day.toString(),
                    monthYearEra: '${_enMonths[now.month]} ${now.year} AD',
                    seasonOrIcon:
                        _SeasonOrIcon.season(_enGregorianSeason(now.month)),
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    textColor: theme.colorScheme.onTertiaryContainer,
                  ),
                  _DateRow(
                    dayNum: l10n.languageCode == 'bn'
                        ? bengaliDate.dayBn
                        : bengaliDate.day.toString(),
                    monthYearEra:
                        '${l10n.languageCode == 'bn' ? bengaliDate.monthNameBn : bengaliDate.monthName} '
                        '${l10n.languageCode == 'bn' ? bengaliDate.yearBn : bengaliDate.year} '
                        '${l10n.calendarShortBangla}',
                    seasonOrIcon: _SeasonOrIcon.season(
                        l10n.getBengaliSeasonName(bengaliDate.monthNumber)),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    textColor: theme.colorScheme.onPrimaryContainer,
                  ),
                  _DateRow(
                    dayNum: hijriDate.dayForLocale(l10n.languageCode),
                    monthYearEra:
                        '${hijriDate.monthNameForLocale(l10n.languageCode)} '
                        '${hijriDate.yearForLocale(l10n.languageCode)} '
                        '${l10n.calendarShortHijri}',
                    seasonOrIcon: _SeasonOrIcon.icon(),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    textColor: theme.colorScheme.onSecondaryContainer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Greeter header ────────────────────────────────────────────

class _GreeterHeader extends StatelessWidget {
  final _TimePeriod period;
  final Color gradientStart;
  final Color gradientEnd;
  final Color textColor;
  final Color iconColor;
  final Animation<double> directionalAnim;
  final Animation<double> pulseAnim;
  final Animation<double>? shimmerAnim; // null on low-end devices
  final String greeting;
  final String todayIsDayName;

  const _GreeterHeader({
    required this.period,
    required this.gradientStart,
    required this.gradientEnd,
    required this.textColor,
    required this.iconColor,
    required this.directionalAnim,
    required this.pulseAnim,
    required this.shimmerAnim,
    required this.greeting,
    required this.todayIsDayName,
  });

  // ── Icon position per period ───────────────────────────────

  // Returns Offset for the watermark icon based on period and
  // animation progress (0.0 → 1.0)
  Offset _iconOffset(double progress, double cardHeight) {
    switch (period) {
      case _TimePeriod.morning:
        // Rises from bottom to top — progress 0=bottom, 1=top
        final y = cardHeight * 0.4 * (1.0 - progress);
        return Offset(0, y);

      case _TimePeriod.afternoon:
        // Stays centered — no directional movement
        return Offset.zero;

      case _TimePeriod.evening:
        // Drifts from center downward
        final y = cardHeight * 0.3 * progress;
        return Offset(0, y);

      case _TimePeriod.night:
        // Arcs left to right using sine curve for natural path
        // X: linear sweep across card width
        // Y: sine curve gives arc shape
        final x = -30.0 + (progress * 60.0);
        final y = -20.0 * math.sin(progress * math.pi);
        return Offset(x, y);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight == double.infinity
            ? 80.0
            : constraints.maxHeight;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [gradientStart, gradientEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: gradientStart.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRect(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // ── Layer 1: Shimmer (capable devices only) ──
                if (shimmerAnim != null)
                  AnimatedBuilder(
                    animation: shimmerAnim!,
                    builder: (context, _) {
                      final pos = shimmerAnim!.value;
                      // Direction varies by period
                      final sweepPos = period == _TimePeriod.evening
                          ? 1.0 - pos // right to left for sunset
                          : period == _TimePeriod.night
                              ? 0.5 + (math.sin(pos * math.pi * 2) * 0.3)
                              : pos; // left to right for others

                      return Positioned.fill(
                        child: Opacity(
                          opacity: 0.07,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-1.5 + (sweepPos * 3), -1.0),
                                end: Alignment(-0.5 + (sweepPos * 3), 1.0),
                                colors: [
                                  Colors.transparent,
                                  iconColor.withValues(alpha: 0.9),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // ── Layer 2: Directional + pulse watermark ───
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([directionalAnim, pulseAnim]),
                    builder: (context, child) {
                      final offset =
                          _iconOffset(directionalAnim.value, cardHeight);
                      return Transform.translate(
                        offset: offset,
                        child: Transform.scale(
                          scale: pulseAnim.value,
                          child: child,
                        ),
                      );
                    },
                    // Icon built once, only transformed
                    child: Opacity(
                      opacity: 0.10,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          period.icon,
                          size: 90,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Layer 3: Text — never rebuilds ───────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          greeting,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: textColor,
                            letterSpacing: -0.5,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayIsDayName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: textColor.withValues(alpha: 0.85),
                            letterSpacing: -0.3,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Season or Icon ────────────────────────────────────────────

class _SeasonOrIcon {
  final String? season;
  final bool isIcon;

  const _SeasonOrIcon.season(this.season) : isIcon = false;
  const _SeasonOrIcon.icon()
      : season = null,
        isIcon = true;
}

// ── Date Row ──────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  final String dayNum;
  final String monthYearEra;
  final _SeasonOrIcon seasonOrIcon;
  final Color backgroundColor;
  final Color textColor;

  const _DateRow({
    required this.dayNum,
    required this.monthYearEra,
    required this.seasonOrIcon,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = textColor.withValues(alpha: 0.15);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                dayNum,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dividerColor.withValues(alpha: 0.0),
                  dividerColor,
                  dividerColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Expanded(
            child: Text(
              monthYearEra,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 1.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          if (seasonOrIcon.isIcon)
            Icon(
              Icons.mosque_outlined,
              color: textColor.withValues(alpha: 0.4),
              size: 22,
            )
          else if (seasonOrIcon.season != null &&
              seasonOrIcon.season!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                seasonOrIcon.season!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
