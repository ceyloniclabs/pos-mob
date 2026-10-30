import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

/// Centralized CustomDropdown decoration matching Material 3 theme and design tokens.
/// Adheres to AppTheme input field styling with surfaceContainerLow fill and outlineVariant borders.
CustomDropdownDecoration buildCustomDropdownDecoration(
  BuildContext context, {
  Color? closedFillColor,
  Color? expandedFillColor,
  Border? closedBorder,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return CustomDropdownDecoration(
    closedFillColor: closedFillColor ?? colorScheme.surfaceContainerLow,
    expandedFillColor: expandedFillColor ?? colorScheme.surfaceContainerLow,
    expandedBorder: Border.all(
      color: colorScheme.primary,
      width: 1.5,
    ),
    closedBorder: closedBorder ??
        Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
    closedBorderRadius: BorderRadius.circular(12),
    expandedBorderRadius: BorderRadius.circular(12),
    searchFieldDecoration: SearchFieldDecoration(
      fillColor: Colors.transparent,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      textStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      contentPadding: EdgeInsets.zero,
    ),
    closedErrorBorder: Border.all(
      color: colorScheme.error,
      width: 1,
    ),
    closedErrorBorderRadius: BorderRadius.circular(12),
    errorStyle: TextStyle(
      color: colorScheme.error,
      fontSize: 12,
    ),
    headerStyle: textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    listItemStyle: textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
    ),
    listItemDecoration: ListItemDecoration(
      selectedColor: colorScheme.primary.withValues(alpha: 0.12),
      highlightColor: colorScheme.surfaceContainerHighest,
    ),
  );
}

CustomDropdownDisabledDecoration buildCustomDropdownDisabledDecoration(
  BuildContext context,
) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return CustomDropdownDisabledDecoration(
    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
    border: Border.all(
      color: colorScheme.outlineVariant,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(12),
    headerStyle: textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    hintStyle: textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
  );
}
