import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_semantic_colors.dart';

/// Modernized StatusChip utilizing AppSemanticColors and accessible icon + text styling.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.bgColor,
    this.textColor,
    this.icon,
  });

  final String status;
  final Color? bgColor;
  final Color? textColor;
  final IconData? icon;

  IconData? get _defaultIcon {
    return switch (status.toLowerCase()) {
      'available' || 'active' || 'paid' || 'approved' => Icons.check_circle_outline_rounded,
      'not_available' ||
      'inactive' ||
      'overdue' ||
      'cancelled' ||
      'late' =>
        Icons.error_outline_rounded,
      'damage' || 'repair' => Icons.build_circle_outlined,
      'pending' || 'partially_paid' => Icons.hourglass_empty_rounded,
      'completed' || 'returned' || 'rented' => Icons.info_outline_rounded,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.semanticColors;

    final effectiveFg = textColor ??
        switch (status.toLowerCase()) {
          'available' || 'active' || 'paid' || 'approved' => semantics.success,
          'damage' || 'repair' => semantics.repair,
          'not_available' ||
          'inactive' ||
          'overdue' ||
          'cancelled' ||
          'late' =>
            theme.colorScheme.error,
          'pending' || 'partially_paid' => semantics.warning,
          'completed' || 'returned' || 'rented' => semantics.info,
          _ => theme.colorScheme.onSurfaceVariant,
        };

    final effectiveBg = bgColor ??
        switch (status.toLowerCase()) {
          'available' || 'active' || 'paid' || 'approved' => semantics.success.withValues(alpha: 0.14),
          'damage' || 'repair' => semantics.repair.withValues(alpha: 0.16),
          'not_available' ||
          'inactive' ||
          'overdue' ||
          'cancelled' ||
          'late' =>
            theme.colorScheme.error.withValues(alpha: 0.14),
          'pending' || 'partially_paid' => semantics.warning.withValues(alpha: 0.16),
          'completed' || 'returned' || 'rented' => semantics.info.withValues(alpha: 0.14),
          _ => theme.colorScheme.surfaceContainerHighest,
        };

    final effectiveIcon = icon ?? _defaultIcon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (effectiveIcon != null) ...[
            Icon(effectiveIcon, size: 14, color: effectiveFg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              status.toUpperCase().replaceAll('_', ' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: effectiveFg,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
