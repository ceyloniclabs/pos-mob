import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/loading_indicator.dart';

class SubscriptionSkeleton extends StatelessWidget {
  const SubscriptionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Card Skeleton
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        SkeletonLoader(width: 44, height: 44, borderRadius: AppRadius.smAll),
                        AppSpacing.hGapMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLoader(width: 180, height: 18),
                              SizedBox(height: 6),
                              SkeletonLoader(width: 100, height: 14),
                            ],
                          ),
                        ),
                        SkeletonLoader(width: 70, height: 24, borderRadius: AppRadius.fullAll),
                      ],
                    ),
                    AppSpacing.gapMd,
                    const SkeletonLoader(
                      width: double.infinity,
                      height: 32,
                      borderRadius: AppRadius.smAll,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SkeletonLoader(width: 120, height: 14),
                          SkeletonLoader(width: 100, height: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // History Section Header Skeleton
        Row(
          children: const [
            SkeletonLoader(width: 24, height: 24, borderRadius: AppRadius.smAll),
            AppSpacing.hGapSm,
            SkeletonLoader(width: 140, height: 16),
          ],
        ),
        AppSpacing.gapSm,

        // History items
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonLoader(width: 140, height: 16),
                      SkeletonLoader(width: 60, height: 20, borderRadius: AppRadius.fullAll),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoader(width: 90, height: 14),
                  const SizedBox(height: 8),
                  const SkeletonLoader(width: double.infinity, height: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
