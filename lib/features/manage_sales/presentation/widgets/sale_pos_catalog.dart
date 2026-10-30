import 'package:cached_network_image/cached_network_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/empty_view.dart';
import 'package:pos/features/manage_sale_items/domain/entities/sale_item.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';
import 'package:pos/features/manage_sales/presentation/widgets/sale_category_filter_sheet.dart';
import 'package:pos/features/manage_sales/presentation/widgets/sale_product_skeletons.dart';

class SalePosCatalog extends GetView<SaleCreateController> {
  const SalePosCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Filter Bar matching CustomerListView
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
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search items by name...',
                      prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                      suffixIcon: controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              tooltip: 'Clear search',
                              onPressed: () {
                                controller.searchController.clear();
                                controller.searchQuery.value = '';
                                controller.productsPagingController.refresh();
                              },
                            )
                          : IconButton(
                              icon: const Icon(Iconsax.scan_barcode, size: 20),
                              tooltip: 'Scan Item QR',
                              onPressed: controller.openContinuousQrScanner,
                            ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.gapSm,
              Obx(
                () => IconButton.filledTonal(
                  icon: Icon(
                    controller.isGridView.value
                        ? Iconsax.row_vertical
                        : Iconsax.grid_1,
                    size: 20,
                  ),
                  tooltip: controller.isGridView.value
                      ? 'List View'
                      : 'Grid View',
                  onPressed: () => controller.isGridView.value =
                      !controller.isGridView.value,
                ),
              ),
              AppSpacing.gapXs,
              Obx(() {
                final hasFilter = controller.selectedCategory.value != null;
                return Badge(
                  isLabelVisible: hasFilter,
                  smallSize: 8,
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.filter_list_rounded, size: 22),
                    tooltip: 'Filter Category',
                    style: hasFilter
                        ? IconButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.primaryContainer,
                            foregroundColor:
                                theme.colorScheme.onPrimaryContainer,
                          )
                        : null,
                    onPressed: () =>
                        SaleCategoryFilterSheet.show(context, controller),
                  ),
                );
              }),
            ],
          ),
        ),

        // Products Grid or List with full Skeleton State & Infinite Scroll
        Expanded(
          child: Obx(
            () => RefreshIndicator(
              onRefresh: () async =>
                  controller.productsPagingController.refresh(),
              child: controller.isGridView.value
                  ? PagedGridView<int, SaleItem>(
                      pagingController: controller.productsPagingController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.82,
                      ),
                      builderDelegate: PagedChildBuilderDelegate<SaleItem>(
                        itemBuilder: (context, product, index) =>
                            _buildProductCard(context, product),
                        firstPageProgressIndicatorBuilder: (_) =>
                            const SaleProductGridSkeleton(),
                        newPageProgressIndicatorBuilder: (_) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        noItemsFoundIndicatorBuilder: (context) =>
                            _buildEmptyState(context),
                      ),
                    )
                  : PagedListView<int, SaleItem>.separated(
                      pagingController: controller.productsPagingController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      builderDelegate: PagedChildBuilderDelegate<SaleItem>(
                        itemBuilder: (context, product, index) =>
                            _buildProductListTile(context, product),
                        firstPageProgressIndicatorBuilder: (_) =>
                            const SaleProductListSkeleton(),
                        newPageProgressIndicatorBuilder: (_) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        noItemsFoundIndicatorBuilder: (context) =>
                            _buildEmptyState(context),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductListTile(BuildContext context, SaleItem product) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Obx(() {
      final cartQty = controller.getItemCartQuantity(product.id);
      final isInCart = cartQty > 0;
      final isOutOfStock = product.stockQuantity <= 0;

      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        backgroundColor: isInCart
            ? theme.colorScheme.primary.withValues(alpha: 0.04)
            : null,
        child: Row(
          children: [
            // Image
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.smAll,
              ),
              clipBehavior: Clip.antiAlias,
              child: product.photos.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.photos.first,
                      memCacheWidth: 200,
                      memCacheHeight: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Iconsax.image,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20.w,
                      ),
                    )
                  : Icon(
                      Iconsax.image,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20.w,
                    ),
            ),
            AppSpacing.gapMd,

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.categoryName ?? 'Item',
                    style: textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGapXxs,
                  Text(
                    product.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGapXxs,
                  Text(
                    AppDataFormatter.formatCurrency(product.sellingPrice),
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapSm,

            // Stock & Stepper / Add
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStockBadge(context, product),
                SizedBox(height: 10.h),
                if (!isInCart)
                  SizedBox(
                    height: 34.h,
                    width: 76.w,
                    child: FilledButton.tonalIcon(
                      onPressed: isOutOfStock
                          ? null
                          : () => controller.incrementProduct(product),
                      icon: const Icon(Icons.add_rounded, size: 14),
                      label: const Text('Add'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.smAll,
                        ),
                        textStyle: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 34.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: AppRadius.smAll,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => controller.decrementProduct(product),
                          borderRadius: AppRadius.smAll,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            child: Icon(
                              Icons.remove_rounded,
                              size: 16.w,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        Text(
                          '$cartQty',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        InkWell(
                          onTap: () => controller.incrementProduct(product),
                          borderRadius: AppRadius.smAll,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 16.w,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductCard(BuildContext context, SaleItem product) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Obx(() {
      final cartQty = controller.getItemCartQuantity(product.id);
      final isInCart = cartQty > 0;
      final isOutOfStock = product.stockQuantity <= 0;

      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        backgroundColor: isInCart
            ? theme.colorScheme.primary.withValues(alpha: 0.04)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tag: Category & Stock Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    product.categoryName ?? 'Item',
                    style: textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStockBadge(context, product),
              ],
            ),
            SizedBox(height: 6.h),

            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.smAll,
                ),
                clipBehavior: Clip.antiAlias,
                child: product.photos.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.photos.first,
                        memCacheWidth: 300,
                        memCacheHeight: 300,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Iconsax.image,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 24.w,
                        ),
                      )
                    : Icon(
                        Iconsax.image,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 24.w,
                      ),
              ),
            ),
            SizedBox(height: 6.h),

            // Product Name
            Text(
              product.name,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vGapXxs,

            // Price
            Text(
              AppDataFormatter.formatCurrency(product.sellingPrice),
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 6.h),

            // Action: Quick Add / Stepper
            if (!isInCart)
              SizedBox(
                width: double.infinity,
                height: 32.h,
                child: FilledButton.tonalIcon(
                  onPressed: isOutOfStock
                      ? null
                      : () => controller.incrementProduct(product),
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.smAll,
                    ),
                    textStyle: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 32.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppRadius.smAll,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => controller.decrementProduct(product),
                      borderRadius: AppRadius.smAll,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          size: 16.w,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Text(
                      '$cartQty',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.incrementProduct(product),
                      borderRadius: AppRadius.smAll,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 16.w,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStockBadge(BuildContext context, SaleItem product) {
    final theme = Theme.of(context);
    final isOutOfStock = product.stockQuantity <= 0;
    final isLowStock = product.stockQuantity < 5;

    final Color badgeBg;
    final Color badgeText;
    final String label;

    if (isOutOfStock) {
      badgeBg = theme.colorScheme.errorContainer;
      badgeText = theme.colorScheme.onErrorContainer;
      label = 'No Stock';
    } else if (isLowStock) {
      badgeBg = Colors.amber.withValues(alpha: 0.16);
      badgeText = Colors.amber.shade900;
      label = '${product.stockQuantity} left';
    } else {
      badgeBg = theme.colorScheme.surfaceContainerHighest;
      badgeText = theme.colorScheme.onSurfaceVariant;
      label = '${product.stockQuantity} in stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: badgeText,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyView(
      icon: Iconsax.box_search,
      title: 'No Products Found',
      message: controller.searchQuery.value.isNotEmpty
          ? 'Try adjusting your search query.'
          : (controller.selectedCategory.value != null
              ? 'No items found in selected category.'
              : 'No items available in the catalog.'),
      actionLabel: (controller.searchQuery.value.isNotEmpty ||
              controller.selectedCategory.value != null)
          ? 'Reset Filter'
          : null,
      onAction: () {
        controller.searchController.clear();
        controller.searchQuery.value = '';
        controller.selectedCategory.value = null;
        controller.productsPagingController.refresh();
      },
    );
  }
}
