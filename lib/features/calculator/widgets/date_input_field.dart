import 'package:flutter/material.dart';

/// Date input field widget for date selection
/// Shows selected date and opens date picker on tap
class DateInputField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool hasError;
  final String? errorText;

  const DateInputField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
    this.onClear,
    this.hasError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: hasError ? colorScheme.error : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Input field
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: hasError
                  ? colorScheme.errorContainer.withOpacity(0.3)
                  : colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? colorScheme.error
                    : selectedDate != null
                        ? colorScheme.primary
                        : Colors.transparent,
                width: hasError || selectedDate != null ? 2 : 0,
              ),
            ),
            child: Row(
              children: [
                // Calendar icon
                Icon(
                  Icons.calendar_today_rounded,
                  color: hasError
                      ? colorScheme.error
                      : selectedDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),

                // Date text
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : 'Select date',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: hasError
                          ? colorScheme.error
                          : selectedDate != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                      fontWeight: selectedDate != null
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),

                // Clear button (only if date is selected)
                if (selectedDate != null && onClear != null)
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: onClear,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Error text
        if (hasError && errorText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: colorScheme.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}