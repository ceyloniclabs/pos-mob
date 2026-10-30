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
import '../controllers/promo_code_controller.dart';
import '../widgets/promo_code_card.dart';
import '../widgets/promo_code_filter_sheet.dart';

class PromoCodeListView extends GetView<PromoCodeController> {
  const PromoCodeListView({super.key});

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
        title: 'Promo Codes',
        showbackArrow: true,
        centerTitle: true,
        actions: [
          if (canManagePromotions)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add Promo Code',
              onPressed: () async {
                controller.initForm();
                final result = await Get.toNamed(Routes.PROMO_CODE_ADD);
                if (result == true) {
                  controller.fetchPromoCodes();
                }
              },
            ),
        ],
      ),
      floatingActionButton: canManagePromotions
          ? FloatingActionButton.extended(
              onPressed: () async {
                controller.initForm();
                final result = await Get.toNamed(Routes.PROMO_CODE_ADD);
                if (result == true) {
                  controller.fetchPromoCodes();
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Promo Code'),
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
                          hintText: 'Search promo code or referral...',
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
                        PromoCodeStatus.all;

                    return Badge(
                      isLabelVisible: hasActiveFilters,
                      smallSize: 8,
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.filter_list_rounded, size: 22),
                        tooltip: 'Filter Promo Codes',
                        style: hasActiveFilters
                            ? IconButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onPrimaryContainer,
                              )
                            : null,
                        onPressed: () =>
                            PromoCodeFilterSheet.show(context, controller),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ── Promo Code List with Skeleton & Empty States ───────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: PromoCodeListSkeleton(),
                  );
                }

                final codes = controller.filteredPromoCodes;

                if (codes.isEmpty) {
                  return EmptyView(
                    icon: Iconsax.discount_shape,
                    title: 'No promo codes found',
                    message: controller.searchQuery.value.isNotEmpty
                        ? 'Try adjusting your search criteria.'
                        : 'Create your first promo code to get started.',
                    actionLabel: canManagePromotions ? 'Add Promo Code' : null,
                    onAction: canManagePromotions
                        ? () async {
                            controller.initForm();
                            final result =
                                await Get.toNamed(Routes.PROMO_CODE_ADD);
                            if (result == true) {
                              controller.fetchPromoCodes();
                            }
                          }
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchPromoCodes,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      80, // Space for FAB
                    ),
                    itemCount: codes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == codes.length) {
                        return const EndOfListIndicator();
                      }

                      final promo = codes[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Slidable(
                          key: ValueKey(promo.id ?? promo.code),
                          endActionPane: canManagePromotions
                              ? ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) async {
                                        controller.initForm(promo);
                                        final result = await Get.toNamed(
                                          Routes.PROMO_CODE_EDIT,
                                          arguments: promo,
                                        );
                                        if (result == true) {
                                          controller.fetchPromoCodes();
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
                                          controller.confirmAndDelete(promo),
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
                          child: PromoCodeCard(promoCode: promo),
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
