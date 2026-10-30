import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/empty_view.dart';
import 'package:pos/core/widgets/end_of_list_indicator.dart';
import 'package:pos/core/widgets/error_view.dart';

import '../../domain/entities/sale_item.dart';
import '../controllers/sale_item_list_controller.dart';
import '../widgets/sale_item_card.dart';
import '../widgets/sale_item_filter_sheet.dart';

class SaleItemListView extends GetView<SaleItemListController> {
  const SaleItemListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Sale Items',
        centerTitle: true,
        showbackArrow: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Item',
            onPressed: () async {
              final result = await Get.toNamed(Routes.SALE_ITEM_ADD);
              if (result == true) {
                controller.refreshList();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(Routes.SALE_ITEM_ADD);
          if (result == true) {
            controller.refreshList();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
      body: ResponsiveCenter(
        maxWidth: 720,
        child: Column(
          children: [
            // ── Search & Filter Section ───────────────────────────────────
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
                        onChanged: (val) {
                          controller.searchQuery.value = val;
                        },
                        decoration: InputDecoration(
                          hintText: 'Search sale items...',
                          prefixIcon:
                              const Icon(Iconsax.search_normal, size: 20),
                          suffixIcon: controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon:
                                      const Icon(Icons.close_rounded, size: 18),
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    controller.searchQuery.value = '';
                                  },
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
                    final hasActiveFilters =
                        controller.selectedCategoryId.value != null ||
                            controller.selectedBrandId.value != null ||
                            controller.selectedIsActive.value != null;

                    return Badge(
                      isLabelVisible: hasActiveFilters,
                      smallSize: 8,
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.filter_list_rounded, size: 22),
                        tooltip: 'Filter Items',
                        style: hasActiveFilters
                            ? IconButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onPrimaryContainer,
                              )
                            : null,
                        onPressed: () =>
                            SaleItemFilterSheet.show(context, controller),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ── Sale Items Paged List ─────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(
                  () => controller.pagingController.refresh(),
                ),
                child: PagedListView<int, SaleItem>(
                  pagingController: controller.pagingController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    80, // Space for FAB
                  ),
                  builderDelegate: PagedChildBuilderDelegate<SaleItem>(
                    firstPageProgressIndicatorBuilder: (_) =>
                        const SaleItemListSkeleton(),
                    newPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                    firstPageErrorIndicatorBuilder: (context) => ErrorView(
                      message: controller.pagingController.error?.toString() ??
                          'Unable to load sale items.',
                      onRetry: () => controller.pagingController.refresh(),
                    ),
                    noItemsFoundIndicatorBuilder: (context) => EmptyView(
                      icon: Iconsax.box,
                      title: 'No sale items found',
                      message: controller.searchQuery.value.isNotEmpty ||
                              controller.selectedCategoryId.value != null
                          ? 'Try adjusting your search or filters.'
                          : 'Create your first sale item to start selling.',
                      actionLabel: 'Add Item',
                      onAction: () async {
                        final result = await Get.toNamed(Routes.SALE_ITEM_ADD);
                        if (result == true) {
                          controller.refreshList();
                        }
                      },
                    ),
                    noMoreItemsIndicatorBuilder: (context) =>
                        const EndOfListIndicator(),
                    itemBuilder: (context, item, index) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Slidable(
                        key: ValueKey(item.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) async {
                                final result = await Get.toNamed(
                                  Routes.SALE_ITEM_EDIT,
                                  arguments: item,
                                );
                                if (result == true) {
                                  controller.refreshList();
                                }
                              },
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              icon: Icons.edit_rounded,
                              label: 'Edit',
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(AppRadius.md),
                                bottomLeft: Radius.circular(AppRadius.md),
                              ),
                            ),
                            SlidableAction(
                              onPressed: (_) =>
                                  controller.confirmAndDelete(item.id),
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                              icon: Icons.delete_rounded,
                              label: 'Delete',
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(AppRadius.md),
                                bottomRight: Radius.circular(AppRadius.md),
                              ),
                            ),
                          ],
                        ),
                        child: SaleItemCard(
                          item: item,
                          onTap: () async {
                            final result = await Get.toNamed(
                              Routes.SALE_ITEM_DETAIL,
                              arguments: item,
                            );
                            if (result == true) {
                              controller.refreshList();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
