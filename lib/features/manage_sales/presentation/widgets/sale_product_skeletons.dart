import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';

class SaleProductCardSkeleton extends StatelessWidget {
  const SaleProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and stock pill skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(
                width: 55,
                height: 14,
                borderRadius: AppRadius.smAll,
              ),
              SkeletonLoader(
                width: 38,
                height: 14,
                borderRadius: AppRadius.smAll,
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Image Skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 90.h,
            borderRadius: AppRadius.smAll,
          ),
          SizedBox(height: 6.h),

          // Title Skeleton
          const SkeletonLoader(
            width: 110,
            height: 14,
            borderRadius: AppRadius.smAll,
          ),
          AppSpacing.vGapXxs,

          // Price Skeleton
          const SkeletonLoader(
            width: 75,
            height: 14,
            borderRadius: AppRadius.smAll,
          ),
          SizedBox(height: 6.h),

          // Button Skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 32.h,
            borderRadius: AppRadius.smAll,
          ),
        ],
      ),
    );
  }
}

class SaleProductGridSkeleton extends StatelessWidget {
  const SaleProductGridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final rows = (itemCount / 2).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              const Expanded(child: SaleProductCardSkeleton()),
              SizedBox(width: 12.w),
              const Expanded(child: SaleProductCardSkeleton()),
            ],
          ),
        );
      }),
    );
  }
}

class SaleProductTileSkeleton extends StatelessWidget {
  const SaleProductTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          // Image skeleton
          SkeletonLoader(
            width: 64.w,
            height: 64.w,
            borderRadius: AppRadius.smAll,
          ),
          AppSpacing.gapMd,

          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(
                  width: 50,
                  height: 12,
                  borderRadius: AppRadius.smAll,
                ),
                AppSpacing.vGapXxs,
                SkeletonLoader(
                  width: 120,
                  height: 14,
                  borderRadius: AppRadius.smAll,
                ),
                AppSpacing.vGapXxs,
                SkeletonLoader(
                  width: 70,
                  height: 14,
                  borderRadius: AppRadius.smAll,
                ),
              ],
            ),
          ),
          AppSpacing.gapSm,

          // Right column: Stock & Button skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SkeletonLoader(
                width: 36,
                height: 14,
                borderRadius: AppRadius.smAll,
              ),
              SizedBox(height: 8.h),
              SkeletonLoader(
                width: 76.w,
                height: 32.h,
                borderRadius: AppRadius.smAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SaleProductListSkeleton extends StatelessWidget {
  const SaleProductListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SaleProductTileSkeleton(),
        ),
      ),
    );
  }
}
