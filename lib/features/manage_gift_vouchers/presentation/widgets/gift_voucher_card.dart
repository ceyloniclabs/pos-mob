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
import '../../domain/entities/gift_voucher.dart';

class GiftVoucherCard extends StatelessWidget {
  const GiftVoucherCard({
    super.key,
    required this.voucher,
  });

  final GiftVoucher voucher;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => Get.toNamed(
        Routes.GIFT_VOUCHER_DETAILS,
        arguments: voucher,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Icon, Voucher Code + Owner, Status Badge ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voucher Leading Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  Iconsax.card_pos,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
              AppSpacing.gapMd,

              // Voucher Code and Owner Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voucher.code,
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
                            voucher.owner,
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
                label: voucher.isActive ? 'Active' : 'Inactive',
                type: voucher.isActive ? StatusType.success : StatusType.error,
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

          // ── Balance and Expiration Row ──────────────────────────────────
          Row(
            children: [
              // Available Balance
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.wallet_3,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  AppSpacing.gapXxs,
                  Text(
                    '${voucher.currency} ${voucher.balance.toStringAsFixed(2)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd,

              // Expiry Date
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    AppSpacing.gapXxs,
                    Expanded(
                      child: Text(
                        'Exp: ${DateFormat('MMM dd, yyyy').format(voucher.expireDate)}',
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

/// Exact skeleton component matching GiftVoucherCard layout during loading states.
class GiftVoucherCardSkeleton extends StatelessWidget {
  const GiftVoucherCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: Icon Container, Code + Owner, Status Badge ───────────
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

          // ── Bottom Row: Balance, Expiry, Chevron ────────────────────────
          Row(
            children: const [
              SkeletonLoader(width: 80, height: 14),
              AppSpacing.gapMd,
              Expanded(
                child: SkeletonLoader(width: double.infinity, height: 14),
              ),
              AppSpacing.gapSm,
              SkeletonLoader(width: 16, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

/// List of GiftVoucherCardSkeleton items used during initial fetch / loading.
class GiftVoucherListSkeleton extends StatelessWidget {
  const GiftVoucherListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: GiftVoucherCardSkeleton(),
        ),
      ),
    );
  }
}
