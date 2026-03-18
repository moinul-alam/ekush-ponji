// lib/features/home/widgets/home_date_greeter_widget.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calendar/services/bengali_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/services/hijri_calendar_service.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

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

// ── Main widget ───────────────────────────────────────────────

class HomeDateGreeterWidget extends ConsumerStatefulWidget {
  const HomeDateGreeterWidget({super.key});

  @override
  ConsumerState<HomeDateGreeterWidget> createState() =>
      _HomeDateGreeterWidgetState();
}

class _HomeDateGreeterWidgetState extends ConsumerState<HomeDateGreeterWidget>
    with TickerProviderStateMixin {
  // ── Period state ────────────────────────────────────────────
  late _TimePeriod _period;
  Timer? _boundaryTimer;

  // ── Entrance animation ──────────────────────────────────────
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Icon pulse ──────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Period cross-fade ───────────────────────────────────────
  late AnimationController _crossFadeController;
  late Animation<double> _crossFadeAnim;

  // ── Watermark rotation ──────────────────────────────────────
  late AnimationController _watermarkRotationController;

  @override
  void initState() {
    super.initState();
    _period = _currentPeriod();
    _setupEntranceAnimation();
    _setupPulseAnimation();
    _setupCrossFadeAnimation();
    _setupWatermarkRotation();
    _scheduleBoundaryTimer();
    _watermarkRotationController.repeat();
    _entranceController.forward().then((_) {
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

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

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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

  void _setupWatermarkRotation() {
    _watermarkRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    );
  }

  void _scheduleBoundaryTimer() {
    _boundaryTimer?.cancel();
    _boundaryTimer = Timer(
      Duration(milliseconds: _msUntilNextHour()),
      _onHourBoundary,
    );
  }

  void _onHourBoundary() {
    final newPeriod = _currentPeriod();
    if (newPeriod != _period) {
      _crossFadeController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() => _period = newPeriod);
          _crossFadeController.reverse();
        }
      });
    }
    _scheduleBoundaryTimer();
  }

  @override
  void dispose() {
    _boundaryTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    _crossFadeController.dispose();
    _watermarkRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final colors = _period.colors(brightness);

    final bengaliDate =
        ref.watch(bengaliCalendarServiceProvider).getBengaliDate(now);
    final hijriDate = ref.watch(hijriCalendarServiceProvider).getHijriDate(now);

    final gradientStart = colors[0];
    final gradientEnd = colors[1];
    final textColor = colors[2];
    final iconColor = colors[3];

    final greeting = _period.greeting(l10n);
    final dayName = l10n.getDayName(now.weekday);
    final todayIsDayName = '${l10n.todayIsDayName} $dayName';

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
                  // ── Greeter header ─────────────────────
                  _GreeterHeader(
                    period: _period,
                    gradientStart: gradientStart,
                    gradientEnd: gradientEnd,
                    textColor: textColor,
                    iconColor: iconColor,
                    pulseAnim: _pulseAnim,
                    watermarkRotation: _watermarkRotationController,
                    greeting: greeting,
                    todayIsDayName: todayIsDayName,
                  ),

                  // ── Gregorian ──────────────────────────
                  _DateRow(
                    dayNum: now.day.toString(),
                    monthYearEra: '${_enMonths[now.month]} ${now.year} AD',
                    seasonOrIcon:
                        _SeasonOrIcon.season(_enGregorianSeason(now.month)),
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    textColor: theme.colorScheme.onTertiaryContainer,
                  ),

                  // ── Bengali ────────────────────────────
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

                  // ── Hijri ──────────────────────────────
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
  final Animation<double> pulseAnim;
  final AnimationController watermarkRotation;
  final String greeting;
  final String todayIsDayName;

  const _GreeterHeader({
    required this.period,
    required this.gradientStart,
    required this.gradientEnd,
    required this.textColor,
    required this.iconColor,
    required this.pulseAnim,
    required this.watermarkRotation,
    required this.greeting,
    required this.todayIsDayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            // ── Watermark ────────────────────────────────
            Positioned(
              right: -10,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.09,
                child: AnimatedBuilder(
                  animation: watermarkRotation,
                  builder: (context, child) => Transform.rotate(
                    angle: watermarkRotation.value * 2 * math.pi,
                    child: child,
                  ),
                  child: Icon(period.icon, size: 90, color: iconColor),
                ),
              ),
            ),

            // ── Text ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      letterSpacing: -0.5,
                      height: 1.1,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: '$greeting  '),
                      TextSpan(
                        text: todayIsDayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: textColor,
                          letterSpacing: -0.5,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
