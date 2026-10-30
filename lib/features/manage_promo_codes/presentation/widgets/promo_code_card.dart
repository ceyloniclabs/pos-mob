import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_pages.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/promo_code.dart';

class PromoCodeCard extends StatelessWidget {
  const PromoCodeCard({
    super.key,
    required this.promoCode,
  });

  final PromoCode promoCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => Get.toNamed(
        Routes.PROMO_CODE_DETAILS,
        arguments: promoCode,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Icon, Promo Code + Referral, Status Badge ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promo Code Leading Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  Iconsax.discount_shape,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
              AppSpacing.gapMd,

              // Promo Code and Referral Partner
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promoCode.code,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGapXxs,
                    Row(
                      children: [
                        Icon(
                          Iconsax.user,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        AppSpacing.gapXxs,
                        Expanded(
                          child: Text(
                            promoCode.referral,
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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

              // Status Badge
              StatusBadge(
                label: promoCode.isActive ? 'Active' : 'Inactive',
                type: promoCode.isActive ? StatusType.success : StatusType.error,
              ),
            ],
          ),
          AppSpacing.gapSm,

          // ── Divider line ────────────────────────────────────────────────
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          AppSpacing.gapSm,

          // ── Discount Percentages and Expiration Row ─────────────────────
          Row(
            children: [
              // Sale Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smAll,
                ),
                child: Text(
                  'Sale ${promoCode.salesPercentage.toStringAsFixed(0)}%',
                  style: textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // Rent Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smAll,
                ),
                child: Text(
                  'Rent ${promoCode.rentalPercentage.toStringAsFixed(0)}%',
                  style: textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Expiry Date (takes remaining space on single line with ellipsis protection)
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Exp: ${DateFormat('MMM dd, yyyy').format(promoCode.expireDate)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Exact skeleton component matching PromoCodeCard layout during loading states.
class PromoCodeCardSkeleton extends StatelessWidget {
  const PromoCodeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: Icon Container, Code + Referral, Status Badge ────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoader(
                width: 44,
                height: 44,
                borderRadius: AppRadius.mdAll,
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: 110, height: 16),
                    AppSpacing.vGapXxs,
                    const SkeletonLoader(width: 90, height: 12),
                  ],
                ),
              ),
              const SkeletonLoader(
                width: 64,
                height: 22,
                borderRadius: AppRadius.fullAll,
              ),
            ],
          ),
          AppSpacing.gapSm,

          // ── Divider ─────────────────────────────────────────────────────
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          AppSpacing.gapSm,

          // ── Bottom Row: Discount Badges, Expiry, Chevron ─────────────────
          Row(
            children: const [
              SkeletonLoader(
                width: 48,
                height: 18,
                borderRadius: AppRadius.smAll,
              ),
              SizedBox(width: 5),
              SkeletonLoader(
                width: 48,
                height: 18,
                borderRadius: AppRadius.smAll,
              ),
              SizedBox(width: 8),
              Expanded(
                child: SkeletonLoader(width: double.infinity, height: 14),
              ),
              SizedBox(width: 4),
              SkeletonLoader(width: 16, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

/// List of PromoCodeCardSkeleton items used during initial fetch / loading.
class PromoCodeListSkeleton extends StatelessWidget {
  const PromoCodeListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: PromoCodeCardSkeleton(),
        ),
      ),
    );
  }
}
