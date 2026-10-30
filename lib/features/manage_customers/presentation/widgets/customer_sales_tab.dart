import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/empty_view.dart';
import 'package:pos/core/widgets/error_view.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_detail_controller.dart';
import 'package:pos/features/manage_sales/domain/entities/sale.dart';
import 'package:pos/features/manage_sales/presentation/widgets/sale_card.dart';

class CustomerSalesTab extends StatefulWidget {
  const CustomerSalesTab({super.key});

  @override
  State<CustomerSalesTab> createState() => _CustomerSalesTabState();
}

class _CustomerSalesTabState extends State<CustomerSalesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = Get.find<CustomerDetailController>();

    return RefreshIndicator(
      onRefresh: () => Future.sync(() => controller.refreshSales()),
      child: CustomScrollView(
        key: const PageStorageKey<String>('customer_sales_tab'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: PagedSliverList<int, Sale>(
              pagingController: controller.salesPagingController,
              builderDelegate: PagedChildBuilderDelegate<Sale>(
                firstPageProgressIndicatorBuilder: (_) =>
                    const SaleListSkeleton(itemCount: 4),
                newPageProgressIndicatorBuilder: (_) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
                firstPageErrorIndicatorBuilder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: ErrorView(
                    message: controller.salesPagingController.error?.toString() ??
                        'Unable to load sales for this customer.',
                    onRetry: () => controller.refreshSales(),
                  ),
                ),
                noItemsFoundIndicatorBuilder: (_) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: EmptyView(
                    icon: Iconsax.shopping_bag,
                    title: 'No sales found',
                    message:
                        'There are no purchase transactions for this customer.',
                    actionLabel: 'New Sale',
                    onAction: () async {
                      final result = await Get.toNamed(Routes.SALE_ADD);
                      if (result == true) {
                        controller.refreshSales();
                      }
                    },
                  ),
                ),
                itemBuilder: (context, sale, index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SaleCard(
                    sale: sale,
                    onTap: () async {
                      await Get.toNamed(
                        Routes.SALE_DETAILS,
                        arguments: sale,
                      );
                      controller.refreshSales();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
