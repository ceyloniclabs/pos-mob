import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/status_badge.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_selection_bottom_sheet_controller.dart';

class CustomerSelectionBottomSheet extends StatelessWidget {
  final bool allowWalkIn;
  final Customer? selectedCustomer;
  final void Function(Customer?)? onCustomerSelected;

  const CustomerSelectionBottomSheet({
    super.key,
    this.allowWalkIn = false,
    this.selectedCustomer,
    this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerSelectionBottomSheetController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Customer',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.vGapXxs,
                        Text(
                          'Search by name, phone, or email',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Get.toNamed(Routes.CUSTOMER_ADD);
                      if (result != null) {
                        controller.refreshList();
                        if (result is Customer && context.mounted) {
                          Navigator.of(context).pop(result);
                        }
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            AppSpacing.vGapXs,

            // Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, or email...',
                  prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: controller.clearSearch,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mdAll,
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdAll,
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdAll,
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Optional Walk-in Option (for Sales POS)
            if (allowWalkIn) ...[
              AppSpacing.vGapXs,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  onTap: () {
                    // Returning null represents Walk-in customer
                    onCustomerSelected?.call(null);
                    Navigator.of(context).pop(null);
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                        child: Icon(Iconsax.user, size: 18.sp),
                      ),
                      AppSpacing.hGapSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Walk-in Customer (Default)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AppSpacing.vGapXxs,
                            Text(
                              'Anonymous quick counter checkout',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedCustomer == null)
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                          size: 20.sp,
                        ),
                    ],
                  ),
                ),
              ),
            ],

            AppSpacing.vGapSm,

            // Paginated Customer List
            Flexible(
              child: PagedListView<int, Customer>.separated(
                pagingController: controller.pagingController,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                separatorBuilder: (context, index) => AppSpacing.vGapXs,
                builderDelegate: PagedChildBuilderDelegate<Customer>(
                  firstPageProgressIndicatorBuilder: (context) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  newPageProgressIndicatorBuilder: (context) => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ),
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (context) {
                    final isSearching = controller.searchQuery.value.isNotEmpty;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xl,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSearching ? Iconsax.user_search : Iconsax.user,
                            size: 44.sp,
                            color: colorScheme.outline,
                          ),
                          AppSpacing.vGapSm,
                          Text(
                            isSearching
                                ? 'No customers found matching "${controller.searchQuery.value}"'
                                : 'No customers available',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AppSpacing.vGapMd,
                          OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Get.toNamed(
                                Routes.CUSTOMER_ADD,
                              );
                              if (result != null) {
                                controller.refreshList();
                                if (result is Customer && context.mounted) {
                                  Navigator.of(context).pop(result);
                                }
                              }
                            },
                            icon: const Icon(Icons.person_add_alt_1, size: 18),
                            label: const Text('Add New Customer'),
                          ),
                        ],
                      ),
                    );
                  },
                  firstPageErrorIndicatorBuilder: (context) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 36.sp, color: colorScheme.error),
                          AppSpacing.vGapSm,
                          Text(
                            'Failed to load customers',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                          AppSpacing.vGapSm,
                          TextButton.icon(
                            onPressed: () => controller.refreshList(),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  itemBuilder: (context, customer, index) {
                    final initials = customer.name.trim().isNotEmpty
                        ? customer.name
                            .trim()
                            .split(' ')
                            .map((e) => e.isNotEmpty ? e[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase()
                        : '?';

                    final isSelected = selectedCustomer?.id == customer.id;

                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      onTap: () {
                        onCustomerSelected?.call(customer);
                        Navigator.of(context).pop(customer);
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          AppSpacing.hGapSm,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        customer.name,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (customer
                                        .membershipLevel
                                        .isNotEmpty) ...[
                                      AppSpacing.hGapXs,
                                      StatusBadge(
                                        label: customer.membershipLevel
                                            .toUpperCase(),
                                        type: StatusType.info,
                                      ),
                                    ],
                                  ],
                                ),
                                AppSpacing.vGapXxs,
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.call,
                                      size: 13.sp,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    AppSpacing.hGapXxs,
                                    Text(
                                      customer.phone.isNotEmpty
                                          ? customer.phone
                                          : 'No phone',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    if (customer.email.isNotEmpty) ...[
                                      AppSpacing.hGapXs,
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          color: colorScheme.outlineVariant,
                                        ),
                                      ),
                                      AppSpacing.hGapXs,
                                      Expanded(
                                        child: Text(
                                          customer.email,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.hGapXs,
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              size: 20.sp,
                              color: colorScheme.primary,
                            )
                          else
                            Icon(
                              Icons.chevron_right,
                              size: 18.sp,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
