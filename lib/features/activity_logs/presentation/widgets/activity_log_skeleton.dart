import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';

class ActivityLogSkeleton extends StatelessWidget {
  const ActivityLogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SkeletonLoader(
            width: 42,
            height: 42,
            borderRadius: AppRadius.smAll,
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(width: 140, height: 16),
                AppSpacing.vGapXxs,
                SkeletonLoader(width: 95, height: 12),
              ],
            ),
          ),
          AppSpacing.hGapSm,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: const [
              SkeletonLoader(
                width: 48,
                height: 18,
                borderRadius: AppRadius.xsAll,
              ),
              AppSpacing.vGapXxs,
              SkeletonLoader(width: 42, height: 11),
            ],
          ),
        ],
      ),
    );
  }
}
