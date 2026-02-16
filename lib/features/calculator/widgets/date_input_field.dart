// lib/features/calculator/widgets/date_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class DateInputField extends StatefulWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool hasError;
  final String? errorText;
  final Function(DateTime?)? onDateChanged;
  final GlobalKey<DateInputFieldState>? nextDateFieldKey; // Changed to GlobalKey

  const DateInputField({
    super.key,
    required this.label,
    this.selectedDate,
    required this.onTap,
    this.onClear,
    this.hasError = false,
    this.errorText,
    this.onDateChanged,
    this.nextDateFieldKey, // GlobalKey instead of FocusNode
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

  /// Update text controllers when selectedDate changes
  void _updateControllersFromDate() {
    if (widget.selectedDate != null) {
      _dayController.text = widget.selectedDate!.day.toString().padLeft(2, '0');
      _monthController.text = widget.selectedDate!.month.toString().padLeft(2, '0');
      _yearController.text = widget.selectedDate!.year.toString();
    } else {
      _dayController.clear();
      _monthController.clear();
      _yearController.clear();
    }
  }

  /// Validate and emit complete date when all fields are filled
  void _validateAndEmitDate() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);

    if (day != null && month != null && year != null) {
      try {
        final date = DateTime(year, month, day);
        // Verify DateTime didn't adjust the date (e.g., Feb 31 → Mar 3)
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
                  : colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Date Input Fields (DD/MM/YYYY)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _buildDateSegment(
                        controller: _dayController,
                        focusNode: _dayFocus,
                        nextFocusNode: _monthFocus,
                        hint: 'DD',
                        maxLength: 2,
                        maxValue: 31,
                      ),
                      _buildSeparator(),
                      _buildDateSegment(
                        controller: _monthController,
                        focusNode: _monthFocus,
                        nextFocusNode: _yearFocus,
                        hint: 'MM',
                        maxLength: 2,
                        maxValue: 12,
                      ),
                      _buildSeparator(),
                      _buildDateSegment(
                        controller: _yearController,
                        focusNode: _yearFocus,
                        hint: 'YYYY',
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
        ),

        // Error Message
        if (widget.errorText != null) _buildErrorMessage(colorScheme),
      ],
    );
  }

  /// Build separator between date segments
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

  /// Build action buttons (clear and calendar picker)
  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clear Button (shown only when date is selected)
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

        // Calendar Picker Button
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

  /// Build error message display
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

  /// Build individual date segment (day, month, or year field)
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
            color: colorScheme.onSurfaceVariant.withOpacity(0.4),
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

  /// Handle field value change and auto-advance focus
  void _handleFieldChange(
    String value,
    int maxLength,
    FocusNode? nextFocusNode,
    bool isLastField,
  ) {
    // Validate complete date when year is filled
    if (value.length == maxLength && isLastField) {
      _validateAndEmitDate();
    }

    // Auto-advance focus when field is complete
    if (value.length == maxLength) {
      if (isLastField && widget.nextDateFieldKey != null) {
        // Jump to next DateInputField's day field using GlobalKey
        widget.nextDateFieldKey!.currentState?.focusDayField();
      } else if (nextFocusNode != null) {
        // Move to next field within same DateInputField
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

    // Reject if value exceeds maximum
    if (value > maxValue) return oldValue;

    // Auto-pad with leading zero if single digit would exceed max when doubled
    if (newValue.text.length == 1 && value * 10 > maxValue) {
      return TextEditingValue(
        text: newValue.text.padLeft(2, '0'),
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    return newValue;
  }
}