import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';

class HomeDashboardSkeleton extends StatelessWidget {
  const HomeDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Banner Skeleton ──────────────────────────────────────────────
        const SkeletonLoader(
          width: double.infinity,
          height: 104,
          borderRadius: AppRadius.lgAll,
        ),
        AppSpacing.gapLg,

        // ── Quick Stats Skeleton ─────────────────────────────────────────
        const SkeletonLoader(width: 120, height: 20),
        AppSpacing.gapSm,
        Row(
          children: const [
            Expanded(child: _StatCardSkeleton()),
            AppSpacing.gapSm,
            Expanded(child: _StatCardSkeleton()),
          ],
        ),
        AppSpacing.gapSm,
        Row(
          children: const [
            Expanded(child: _StatCardSkeleton()),
            AppSpacing.gapSm,
            Expanded(child: _StatCardSkeleton()),
          ],
        ),
        AppSpacing.gapXl,

        // ── Quick Actions Skeleton ───────────────────────────────────────
        const SkeletonLoader(width: 130, height: 20),
        AppSpacing.gapSm,
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 480;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isCompact ? 2 : 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: isCompact ? 2.3 : 1.15,
              children: List.generate(
                2,
                (_) => const SkeletonLoader(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: AppRadius.mdAll,
                ),
              ),
            );
          },
        ),
        AppSpacing.gapXl,

        // ── Recent Activity Skeleton ─────────────────────────────────────
        const SkeletonLoader(width: 140, height: 20),
        AppSpacing.gapSm,
        ...List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: AppCard(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  SkeletonLoader(
                    width: 40,
                    height: 40,
                    borderRadius: AppRadius.smAll,
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(width: 160, height: 16),
                        AppSpacing.vGapXxs,
                        SkeletonLoader(width: 80, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: 32, height: 32, borderRadius: AppRadius.smAll),
          AppSpacing.gapSm,
          SkeletonLoader(width: 50, height: 24),
          AppSpacing.gapXxs,
          SkeletonLoader(width: 90, height: 14),
        ],
      ),
    );
  }
}
