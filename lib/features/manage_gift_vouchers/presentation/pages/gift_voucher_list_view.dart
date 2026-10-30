import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:pos/core/access/access_policy.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/empty_view.dart';
import 'package:pos/core/widgets/end_of_list_indicator.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/gift_voucher_controller.dart';
import '../widgets/gift_voucher_card.dart';
import '../widgets/gift_voucher_filter_sheet.dart';

class GiftVoucherListView extends GetView<GiftVoucherController> {
  const GiftVoucherListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = AuthController.to.user.value?.role;
    final canManagePromotions = AccessPolicy.allows(
      role,
      AppPermission.managePromotions,
    );

    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Gift Vouchers',
        showbackArrow: true,
        centerTitle: true,
        actions: [
          if (canManagePromotions)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add Gift Voucher',
              onPressed: () async {
                controller.initForm();
                final result = await Get.toNamed(Routes.GIFT_VOUCHER_ADD);
                if (result == true) {
                  controller.fetchGiftVouchers();
                }
              },
            ),
        ],
      ),
      floatingActionButton: canManagePromotions
          ? FloatingActionButton.extended(
              onPressed: () async {
                controller.initForm();
                final result = await Get.toNamed(Routes.GIFT_VOUCHER_ADD);
                if (result == true) {
                  controller.fetchGiftVouchers();
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Gift Voucher'),
            )
          : null,
      body: ResponsiveCenter(
        maxWidth: 720,
        child: Column(
          children: [
            // ── Search and Filter Row ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => TextField(
                        controller: controller.searchController,
                        onChanged: (value) =>
                            controller.searchQuery.value = value,
                        decoration: InputDecoration(
                          hintText: 'Search by code or owner...',
                          prefixIcon:
                              const Icon(Iconsax.search_normal, size: 20),
                          suffixIcon: controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  tooltip: 'Clear search',
                                  onPressed: controller.clearSearch,
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapSm,
                  Obx(() {
                    final hasActiveFilters = controller.selectedStatus.value !=
                        GiftVoucherStatus.all;

                    return Badge(
                      isLabelVisible: hasActiveFilters,
                      smallSize: 8,
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.filter_list_rounded, size: 22),
                        tooltip: 'Filter Vouchers',
                        style: hasActiveFilters
                            ? IconButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onPrimaryContainer,
                              )
                            : null,
                        onPressed: () =>
                            GiftVoucherFilterSheet.show(context, controller),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ── Voucher List with Skeleton & Empty States ──────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: GiftVoucherListSkeleton(),
                  );
                }

                final vouchers = controller.filteredGiftVouchers;

                if (vouchers.isEmpty) {
                  return EmptyView(
                    icon: Iconsax.card_pos,
                    title: 'No gift vouchers found',
                    message: controller.searchQuery.value.isNotEmpty
                        ? 'Try adjusting your search criteria.'
                        : 'Create your first gift voucher to get started.',
                    actionLabel:
                        canManagePromotions ? 'Add Gift Voucher' : null,
                    onAction: canManagePromotions
                        ? () async {
                            controller.initForm();
                            final result =
                                await Get.toNamed(Routes.GIFT_VOUCHER_ADD);
                            if (result == true) {
                              controller.fetchGiftVouchers();
                            }
                          }
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchGiftVouchers,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      80, // Space for FAB
                    ),
                    itemCount: vouchers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == vouchers.length) {
                        return const EndOfListIndicator();
                      }

                      final voucher = vouchers[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Slidable(
                          key: ValueKey(voucher.id ?? voucher.code),
                          endActionPane: canManagePromotions
                              ? ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) async {
                                        controller.initForm(voucher);
                                        final result = await Get.toNamed(
                                          Routes.GIFT_VOUCHER_EDIT,
                                          arguments: voucher,
                                        );
                                        if (result == true) {
                                          controller.fetchGiftVouchers();
                                        }
                                      },
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                      icon: Icons.edit_rounded,
                                      label: 'Edit',
                                      borderRadius: BorderRadius.only(
                                        topLeft:
                                            Radius.circular(AppRadius.md),
                                        bottomLeft:
                                            Radius.circular(AppRadius.md),
                                      ),
                                    ),
                                    SlidableAction(
                                      onPressed: (_) =>
                                          controller.confirmAndDelete(voucher),
                                      backgroundColor: theme.colorScheme.error,
                                      foregroundColor:
                                          theme.colorScheme.onError,
                                      icon: Icons.delete_rounded,
                                      label: 'Delete',
                                      borderRadius: BorderRadius.only(
                                        topRight:
                                            Radius.circular(AppRadius.md),
                                        bottomRight:
                                            Radius.circular(AppRadius.md),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          child: GiftVoucherCard(voucher: voucher),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
