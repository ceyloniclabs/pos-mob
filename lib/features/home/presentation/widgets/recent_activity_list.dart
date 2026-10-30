import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_pages.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_data_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../activity_logs/domain/entities/activity_log_entity.dart';
import '../../../activity_logs/presentation/widgets/activity_detail_bottom_sheet.dart';
import '../../../activity_logs/presentation/widgets/activity_log_card.dart';
import '../../../activity_logs/presentation/widgets/activity_log_skeleton.dart';
import '../../domain/entities/dashboard_entity.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({
    super.key,
    required this.activities,
    this.recentLogs,
    this.isLoadingLogs = false,
  });

  final List<ActivityEntity> activities;
  final List<ActivityLogEntity>? recentLogs;
  final bool isLoadingLogs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final hasLogs = recentLogs != null && recentLogs!.isNotEmpty;
    final hasLegacyActivities = activities.isNotEmpty;
    final hasAnyData = hasLogs || hasLegacyActivities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Activity',
          padding: EdgeInsets.zero,
          actionLabel: (hasAnyData || recentLogs != null) ? 'View all' : null,
          onAction: () => Get.toNamed(Routes.ACTIVITY_LOGS),
        ),
        AppSpacing.gapSm,

        // 1. Loading Skeleton for recent audit logs
        if (isLoadingLogs && (recentLogs == null || recentLogs!.isEmpty))
          Column(
            children: List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                child: ActivityLogSkeleton(),
              ),
            ),
          )
        // 2. Real Activity Logs (Admin view)
        else if (recentLogs != null && recentLogs!.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLogs!.take(5).length,
            separatorBuilder: (_, _) => AppSpacing.gapXs,
            itemBuilder: (context, index) {
              final log = recentLogs![index];
              return ActivityLogCard(
                log: log,
                onTap: () => ActivityDetailBottomSheet.show(context, log),
              );
            },
          )
        // 3. Fallback to Legacy Activity List (Staff / Mock)
        else if (activities.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.take(5).length,
            separatorBuilder: (_, _) => AppSpacing.gapXs,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final (icon, color) =
                  _getActivityVisuals(context, activity.iconType);
              final timeLabel = AppDataFormatter.customTimeAgo(activity.time);

              return AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSpacing.vGapXxs,
                          Text(
                            timeLabel,
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        // 4. Empty State
        else
          const EmptyView(
            icon: Iconsax.activity,
            title: 'No recent activity',
            message: 'Recent transactions and rentals will show up here.',
          ),
      ],
    );
  }

  (IconData, Color) _getActivityVisuals(BuildContext context, String iconType) {
    final theme = Theme.of(context);
    final semantics = context.semanticColors;

    switch (iconType.toLowerCase()) {
      case 'rental':
        return (Iconsax.calendar_1, theme.colorScheme.primary);
      case 'sale':
        return (Iconsax.shopping_bag, semantics.success);
      case 'customer':
        return (Iconsax.user, semantics.info);
      case 'payment':
        return (Iconsax.card, semantics.warning);
      case 'damage':
        return (Iconsax.warning_2, theme.colorScheme.error);
      default:
        return (Iconsax.activity, theme.colorScheme.primary);
    }
  }
}
