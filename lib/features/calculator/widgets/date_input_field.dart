// lib/features/calculator/widgets/date_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class DateInputField extends StatefulWidget {
  final String label;
  final String? subtitle;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool hasError;
  final String? errorText;
  final Function(DateTime?)? onDateChanged;
  final GlobalKey<DateInputFieldState>? nextDateFieldKey;

  const DateInputField({
    super.key,
    required this.label,
    this.subtitle,
    this.selectedDate,
    required this.onTap,
    this.onClear,
    this.hasError = false,
    this.errorText,
    this.onDateChanged,
    this.nextDateFieldKey,
  });

  @override
  State<DateInputField> createState() => DateInputFieldState();
}

class DateInputFieldState extends State<DateInputField> {
  late FocusNode _dayFocus;
  late FocusNode _monthFocus;
  late FocusNode _yearFocus;

  late TextEditingController _dayController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;

  /// Public method to focus the day field from parent widget
  void focusDayField() {
    _dayFocus.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
    _initializeControllers();
  }

  void _initializeFocusNodes() {
    _dayFocus = FocusNode();
    _monthFocus = FocusNode();
    _yearFocus = FocusNode();
  }

  void _initializeControllers() {
    _dayController = TextEditingController();
    _monthController = TextEditingController();
    _yearController = TextEditingController();
    _updateControllersFromDate();
  }

  @override
  void didUpdateWidget(DateInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _updateControllersFromDate();
    }
  }

  @override
  void dispose() {
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _updateControllersFromDate() {
    if (widget.selectedDate != null) {
      _dayController.text = widget.selectedDate!.day.toString().padLeft(2, '0');
      _monthController.text =
          widget.selectedDate!.month.toString().padLeft(2, '0');
      _yearController.text = widget.selectedDate!.year.toString();
    } else {
      _dayController.clear();
      _monthController.clear();
      _yearController.clear();
    }
  }

  void _validateAndEmitDate() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);

    if (day != null && month != null && year != null) {
      try {
        final date = DateTime(year, month, day);
        if (date.day == day && date.month == month && date.year == year) {
          widget.onDateChanged?.call(date);
        }
      } catch (e) {
        widget.onDateChanged?.call(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';

    // Localized placeholder hints
    // Bengali uses the word (দিন/মাস/বছর), English uses the abbreviation (DD/MM/YYYY)
    final dayHint = isBn ? l10n.day : 'DD'; // দিন / DD
    final monthHint = isBn ? l10n.month : 'MM'; // মাস / MM
    final yearHint = isBn ? l10n.year : 'YYYY'; // বছর / YYYY

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Input Container
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.hasError
                  ? colorScheme.error
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Date segments row + action buttons ──────────
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        widget.subtitle != null ? 4 : 12,
                      ),
                      child: Row(
                        children: [
                          _buildDateSegment(
                            controller: _dayController,
                            focusNode: _dayFocus,
                            nextFocusNode: _monthFocus,
                            hint: dayHint,
                            maxLength: 2,
                            maxValue: 31,
                          ),
                          _buildSeparator(),
                          _buildDateSegment(
                            controller: _monthController,
                            focusNode: _monthFocus,
                            nextFocusNode: _yearFocus,
                            hint: monthHint,
                            maxLength: 2,
                            maxValue: 12,
                          ),
                          _buildSeparator(),
                          _buildDateSegment(
                            controller: _yearController,
                            focusNode: _yearFocus,
                            hint: yearHint,
                            maxLength: 4,
                            isYear: true,
                            isLastField: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Action Buttons (Clear + Calendar Picker)
                  _buildActionButtons(colorScheme),
                ],
              ),

              // ── Subtitle hint inside the box ─────────────────
              if (widget.subtitle != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.subtitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Error Message
        if (widget.errorText != null) _buildErrorMessage(colorScheme),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '/',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.selectedDate != null && widget.onClear != null)
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: widget.onClear,
            tooltip: 'Clear',
          ),
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              Icons.calendar_today_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
            onPressed: widget.onTap,
            tooltip: AppLocalizations.of(context).selectDate,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: colorScheme.error,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSegment({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String hint,
    required int maxLength,
    int? maxValue,
    bool isYear = false,
    bool isLastField = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      flex: isYear ? 2 : 1,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLength),
          if (maxValue != null) _DateValueInputFormatter(maxValue),
        ],
        onChanged: (value) => _handleFieldChange(
          value,
          maxLength,
          nextFocusNode,
          isLastField,
        ),
      ),
    );
  }

  void _handleFieldChange(
    String value,
    int maxLength,
    FocusNode? nextFocusNode,
    bool isLastField,
  ) {
    if (value.length == maxLength && isLastField) {
      _validateAndEmitDate();
    }
    if (value.length == maxLength) {
      if (isLastField && widget.nextDateFieldKey != null) {
        widget.nextDateFieldKey!.currentState?.focusDayField();
      } else if (nextFocusNode != null) {
        nextFocusNode.requestFocus();
      }
    }
  }
}

/// Input formatter to prevent values exceeding maximum
class _DateValueInputFormatter extends TextInputFormatter {
  final int maxValue;

  _DateValueInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final value = int.tryParse(newValue.text);
    if (value == null) return oldValue;

    if (value > maxValue) return oldValue;

    if (newValue.text.length == 1 && value * 10 > maxValue) {
      return TextEditingValue(
        text: newValue.text.padLeft(2, '0'),
        selection: const TextSelection.collapsed(offset: 2),
      );
    }

    return newValue;
  }
}
