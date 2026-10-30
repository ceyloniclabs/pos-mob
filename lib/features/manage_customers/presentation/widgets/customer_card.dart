import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/controllers/persistent_data_controller.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/scaffold_message_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../manage_sales/presentation/controllers/sale_create_controller.dart';
import '../../domain/entities/customer.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Resolve country name if available
    String? countryName;
    if (customer.countryId > 0 &&
        Get.isRegistered<PersistentDataController>()) {
      countryName = PersistentDataController.to
          .findCountryById(customer.countryId)
          ?.name;
    }

    // Determine ID or origin subtitle
    final isLocal = customer.customerType.toLowerCase() == 'local';
    final idSubtitle = isLocal
        ? (customer.nic != null && customer.nic!.isNotEmpty
              ? 'NIC: ${customer.nic}'
              : 'Local Customer')
        : (customer.passportId != null && customer.passportId!.isNotEmpty
              ? 'Passport: ${customer.passportId}'
              : (countryName != null ? 'Origin: $countryName' : 'Foreigner'));

    // Resolve profile photo URL
    ImageProvider? imageProvider;
    if (customer.profilePhoto != null && customer.profilePhoto!.isNotEmpty) {
      final photo = customer.profilePhoto!;
      final url = photo.startsWith('http')
          ? photo
          : '${EndPoints.baseUrl.replaceAll('/api/', '')}$photo';
      imageProvider = NetworkImage(url);
    }

    final trimmedName = customer.name.trim();
    final initial = trimmedName.isNotEmpty
        ? trimmedName[0].toUpperCase()
        : '?';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => Get.toNamed(Routes.CUSTOMER_DETAIL, arguments: customer),
      onLongPress: () {
        if (Get.isRegistered<SaleCreateController>()) {
          Get.find<SaleCreateController>().setCustomer(customer);
          Get.back();
          ScaffoldMessageUtils.showSuccess(
            'Customer ${customer.name} selected.',
          );
        } else {
          Get.toNamed(Routes.SALE_ADD, arguments: customer);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Avatar, Name + ID, Membership Tier ──────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                backgroundImage: imageProvider,
                onBackgroundImageError: imageProvider != null
                    ? (error, stackTrace) {}
                    : null,
                child: imageProvider == null
                    ? Text(
                        initial,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              AppSpacing.gapMd,

              // Name and Identification
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGapXxs,
                    Row(
                      children: [
                        Icon(
                          isLocal ? Iconsax.location : Iconsax.global,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        AppSpacing.gapXxs,
                        Expanded(
                          child: Text(
                            idSubtitle,
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

              // Membership Badge
              StatusBadge(
                label:
                    customer.membershipLevel.capitalizeFirst ??
                    customer.membershipLevel,
                type: _getMembershipType(customer.membershipLevel),
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

          // ── Contact Info Row ────────────────────────────────────────────
          Row(
            children: [
              // Phone
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Iconsax.call,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    AppSpacing.gapXxs,
                    Expanded(
                      child: Text(
                        customer.phone,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm,

              // Email or Country Tag
              if (customer.email.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.sms,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      AppSpacing.gapXxs,
                      Expanded(
                        child: Text(
                          customer.email,
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              else if (countryName != null)
                Text(
                  countryName,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              AppSpacing.gapXs,
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

  StatusType _getMembershipType(String level) {
    switch (level.toLowerCase()) {
      case 'platinum':
      case 'gold':
        return StatusType.warning;
      case 'silver':
        return StatusType.info;
      case 'bronze':
      default:
        return StatusType.neutral;
    }
  }
}

/// Exact skeleton component matching CustomerCard layout during loading states.
class CustomerCardSkeleton extends StatelessWidget {
  const CustomerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: Avatar, Name, Badge ────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoader(
                width: 48,
                height: 48,
                borderRadius: AppRadius.fullAll,
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: 110, height: 16),
                    AppSpacing.vGapXxs,
                    const SkeletonLoader(width: 100, height: 12),
                  ],
                ),
              ),
              const SkeletonLoader(
                width: 64,
                height: 22,
                borderRadius: AppRadius.smAll,
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

          // ── Bottom Row: Phone, Email, Chevron ───────────────────────────
          Row(
            children: const [
              Expanded(
                child: SkeletonLoader(width: double.infinity, height: 14),
              ),
              AppSpacing.gapSm,
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

/// List of CustomerCardSkeleton items used in PagedListView.
class CustomerListSkeleton extends StatelessWidget {
  const CustomerListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: CustomerCardSkeleton(),
        ),
      ),
    );
  }
}
