import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_data_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/activity_log_entity.dart';
import 'activity_detail_bottom_sheet.dart';

class ActivityLogCard extends StatelessWidget {
  const ActivityLogCard({
    super.key,
    required this.log,
    this.onTap,
  });

  final ActivityLogEntity log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final semantics = context.semanticColors;

    final (icon, color) = _getActivityVisuals(context, log.action);
    final roleColor = log.isAdmin ? scheme.primary : semantics.info;
    final timeLabel =
        AppDataFormatter.customTimeAgo(log.createdAt.toIso8601String());

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap ?? () => ActivityDetailBottomSheet.show(context, log),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container with action-semantic tint
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smAll,
                ),
                child: Icon(icon, color: color, size: 20),
              ),

              AppSpacing.hGapMd,

              // Action and User information (Middle - Expanded for maximum space)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.action,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGapXxs,
                    Row(
                      children: [
                        Icon(
                          Iconsax.user,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        AppSpacing.hGapXxs,
                        Expanded(
                          child: Text(
                            log.userName,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.hGapSm,

              // Trailing column: Role Badge on top & Time-ago on bottom (Chevron removed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.xsAll,
                    ),
                    child: Text(
                      log.role.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: roleColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  AppSpacing.vGapXxs,
                  Text(
                    timeLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static (IconData, Color) _getActivityVisuals(
      BuildContext context, String action) {
    final theme = Theme.of(context);
    final semantics = context.semanticColors;
    final lower = action.toLowerCase();

    if (lower.contains('delete')) {
      return (Iconsax.trash, theme.colorScheme.error);
    } else if (lower.contains('damage')) {
      return (Iconsax.warning_2, theme.colorScheme.error);
    } else if (lower.contains('create') || lower.contains('add')) {
      return (Iconsax.add_circle, semantics.success);
    } else if (lower.contains('update') || lower.contains('edit')) {
      return (Iconsax.edit_2, theme.colorScheme.primary);
    } else if (lower.contains('logged in') || lower.contains('login')) {
      return (Iconsax.login, semantics.info);
    } else if (lower.contains('logged out') || lower.contains('logout')) {
      return (Iconsax.logout, theme.colorScheme.onSurfaceVariant);
    } else if (lower.contains('payment')) {
      return (Iconsax.card, semantics.warning);
    } else if (lower.contains('rental')) {
      return (Iconsax.calendar_1, theme.colorScheme.primary);
    } else if (lower.contains('sale')) {
      return (Iconsax.shopping_bag, semantics.success);
    } else if (lower.contains('customer') || lower.contains('user')) {
      return (Iconsax.user, semantics.info);
    } else if (lower.contains('voucher') || lower.contains('promo')) {
      return (Iconsax.discount_shape, semantics.warning);
    } else {
      return (Iconsax.activity, theme.colorScheme.primary);
    }
  }
}
