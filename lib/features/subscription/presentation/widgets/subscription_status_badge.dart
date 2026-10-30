import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_semantic_colors.dart';
import 'package:pos/core/theme/app_spacing.dart';

class SubscriptionStatusBadge extends StatelessWidget {
  final String status;
  final bool isExpired;

  const SubscriptionStatusBadge({
    super.key,
    required this.status,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    final semantics = context.semanticColors;
    final theme = Theme.of(context);

    Color bg;
    Color fg;
    IconData icon;
    String label;

    final normalized = status.trim().toLowerCase();

    if (isExpired || normalized == 'expired') {
      bg = theme.colorScheme.error.withValues(alpha: 0.12);
      fg = theme.colorScheme.error;
      icon = Iconsax.close_circle;
      label = 'EXPIRED';
    } else if (normalized == 'active') {
      bg = semantics.success.withValues(alpha: 0.12);
      fg = semantics.success;
      icon = Iconsax.tick_circle;
      label = 'ACTIVE';
    } else if (normalized == 'upcoming') {
      bg = theme.colorScheme.primary.withValues(alpha: 0.12);
      fg = theme.colorScheme.primary;
      icon = Iconsax.clock;
      label = 'UPCOMING';
    } else {
      bg = theme.colorScheme.surfaceContainerHighest;
      fg = theme.colorScheme.onSurfaceVariant;
      icon = Iconsax.info_circle;
      label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
