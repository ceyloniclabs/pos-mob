import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/loading_indicator.dart';

class OperationalMetricsSkeleton extends StatelessWidget {
  const OperationalMetricsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(width: 140, height: 18),
              SkeletonLoader(
                width: 120,
                height: 26,
                borderRadius: AppRadius.smAll,
              ),
            ],
          ),
          AppSpacing.gapMd,

          // Row 1 (2 tiles)
          Row(
            children: [
              Expanded(child: _buildMetricTileSkeleton(colorScheme)),
              AppSpacing.hGapSm,
              Expanded(child: _buildMetricTileSkeleton(colorScheme)),
            ],
          ),
          AppSpacing.gapSm,

          // Row 2 (2 tiles)
          Row(
            children: [
              Expanded(child: _buildMetricTileSkeleton(colorScheme)),
              AppSpacing.hGapSm,
              Expanded(child: _buildMetricTileSkeleton(colorScheme)),
            ],
          ),
          AppSpacing.gapMd,

          // Subtle footer skeleton
          const SkeletonLoader(
            width: double.infinity,
            height: 28,
            borderRadius: AppRadius.smAll,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTileSkeleton(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonLoader(
                width: 25,
                height: 25,
                borderRadius: AppRadius.smAll,
              ),
              Spacer(),
              SkeletonLoader(
                width: 50,
                height: 14,
                borderRadius: AppRadius.xsAll,
              ),
            ],
          ),
          AppSpacing.gapSm,
          const SkeletonLoader(width: 60, height: 20),
          const SizedBox(height: 4),
          const SkeletonLoader(width: 80, height: 12),
        ],
      ),
    );
  }
}
