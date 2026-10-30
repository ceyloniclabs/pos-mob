import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/empty_view.dart';
import 'package:pos/core/widgets/end_of_list_indicator.dart';
import 'package:pos/core/widgets/error_view.dart';

import '../../domain/entities/sale_category.dart';
import '../controllers/sale_category_list_controller.dart';
import '../widgets/sale_category_card.dart';
import '../widgets/sale_category_form_sheet.dart';

class SaleCategoryListView extends GetView<SaleCategoryListController> {
  const SaleCategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Sale Categories',
        centerTitle: true,
        showbackArrow: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Category',
            onPressed: () {
              controller.openForm();
              SaleCategoryFormSheet.show(context, controller);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.openForm();
          SaleCategoryFormSheet.show(context, controller);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
      ),
      body: ResponsiveCenter(
        maxWidth: 720,
        child: Column(
          children: [
            // ── Search Bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Obx(
                () => TextField(
                  controller: controller.searchController,
                  onChanged: (val) {
                    controller.searchQuery.value = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search sale categories...',
                    prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            tooltip: 'Clear search',
                            onPressed: () {
                              controller.clearSearch();
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

            // ── Categories Paged List ─────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(
                  () => controller.pagingController.refresh(),
                ),
                child: PagedListView<int, SaleCategory>(
                  pagingController: controller.pagingController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    80, // Space for FAB
                  ),
                  builderDelegate: PagedChildBuilderDelegate<SaleCategory>(
                    firstPageProgressIndicatorBuilder: (_) =>
                        const SaleCategoryListSkeleton(),
                    newPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                    firstPageErrorIndicatorBuilder: (context) => ErrorView(
                      message: controller.pagingController.error?.toString() ??
                          'Unable to load categories.',
                      onRetry: () => controller.pagingController.refresh(),
                    ),
                    noItemsFoundIndicatorBuilder: (context) => EmptyView(
                      icon: Iconsax.category_2,
                      title: 'No sale categories found',
                      message: controller.searchQuery.value.isNotEmpty
                          ? 'Try adjusting your search criteria.'
                          : 'Create your first sale category to organize items.',
                      actionLabel: 'Add Category',
                      onAction: () {
                        controller.openForm();
                        SaleCategoryFormSheet.show(context, controller);
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
                              onPressed: (_) {
                                controller.openForm(item);
                                SaleCategoryFormSheet.show(
                                  context,
                                  controller,
                                  item: item,
                                );
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
                        child: SaleCategoryCard(
                          category: item,
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
