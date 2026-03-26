// Can be placed at the bottom of calendar_screen.dart or in its own file:
// lib/features/calendar/widgets/month_year_picker_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class MonthYearPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final AppLocalizations l10n;
  final void Function(int year, int month) onSelected;

  const MonthYearPickerDialog({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.l10n,
    required this.onSelected,
  });

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int _year;
  late int _month;
  late TextEditingController _yearController;
  bool _yearEditMode = false;
  final _yearFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
    _yearController = TextEditingController(text: _year.toString());
  }

  @override
  void dispose() {
    _yearController.dispose();
    _yearFocusNode.dispose();
    super.dispose();
  }

  void _commitYearInput() {
    final parsed = int.tryParse(_yearController.text);
    if (parsed != null && parsed >= 1900 && parsed <= 2100) {
      setState(() {
        _year = parsed;
        _yearEditMode = false;
      });
    } else {
      // Reset to last valid year
      _yearController.text = _year.toString();
      setState(() => _yearEditMode = false);
    }
  }

  void _incrementYear(int delta) {
    setState(() {
      _year = (_year + delta).clamp(1900, 2100);
      _yearController.text = _year.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = widget.l10n;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Title ─────────────────────────────────────
            Text(
              l10n.selectMonth,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),

            const SizedBox(height: 20),

            // ── Year selector ──────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Decrement
                  _YearArrowButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _incrementYear(-1),
                    cs: cs,
                  ),

                  // Year display / edit field
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _yearEditMode = true;
                        _yearController.text = _year.toString();
                        _yearController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _yearController.text.length,
                        );
                      });
                      Future.microtask(() => _yearFocusNode.requestFocus());
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: _yearEditMode
                          ? SizedBox(
                              key: const ValueKey('input'),
                              width: 90,
                              child: TextField(
                                controller: _yearController,
                                focusNode: _yearFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: cs.primary),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: cs.primary, width: 2),
                                  ),
                                ),
                                onSubmitted: (_) => _commitYearInput(),
                                onEditingComplete: _commitYearInput,
                              ),
                            )
                          : Container(
                              key: const ValueKey('display'),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.localizeNumber(_year),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.edit_outlined,
                                      size: 14, color: cs.onSurfaceVariant),
                                ],
                              ),
                            ),
                    ),
                  ),

                  // Increment
                  _YearArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _incrementYear(1),
                    cs: cs,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Month grid ─────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == _month;
                return GestureDetector(
                  onTap: () {
                    if (_yearEditMode) _commitYearInput();
                    setState(() => _month = month);
                    widget.onSelected(_year, month);
                    Navigator.of(context).pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary
                          : cs.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.3),
                              width: 1,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.getMonthName(month),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected ? cs.onPrimary : cs.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ── Cancel ─────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small arrow button ─────────────────────────────────────────
class _YearArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _YearArrowButton({
    required this.icon,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 22, color: cs.onSurface),
      ),
    );
  }
}
