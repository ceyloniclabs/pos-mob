import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
import 'package:pos/core/widgets/error_view.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_list_controller.dart';
import 'package:pos/features/manage_customers/presentation/widgets/customer_card.dart';
import 'package:pos/features/manage_customers/presentation/widgets/customer_filter_sheet.dart';

class CustomerListView extends GetView<CustomerListController> {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = AuthController.to.user.value?.role;
    final canManageCustomers = AccessPolicy.allows(
      role,
      AppPermission.manageCustomers,
    );

    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Customers',
        showbackArrow: true,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Customer',
            onPressed: () async {
              final result = await Get.toNamed(Routes.CUSTOMER_ADD);
              if (result == true) {
                controller.pagingController.refresh();
              }
            },
          ),
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: 720,
        child: Column(
          children: [
            // Search and filter row
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
                          hintText: 'Search by name, phone, or email...',
                          prefixIcon: const Icon(
                            Iconsax.search_normal,
                            size: 20,
                          ),
                          suffixIcon: controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
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
                    final hasActiveFilters =
                        controller.selectedType.value !=
                            CustomerFilterType.all ||
                        controller.selectedMembership.value !=
                            MembershipFilterLevel.all;

                    return Badge(
                      isLabelVisible: hasActiveFilters,
                      smallSize: 8,
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.filter_list_rounded, size: 22),
                        tooltip: 'Filter Customers',
                        style: hasActiveFilters
                            ? IconButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onPrimaryContainer,
                              )
                            : null,
                        onPressed: () =>
                            CustomerFilterSheet.show(context, controller),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Customer List View with full state coverage
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    Future.sync(() => controller.pagingController.refresh()),
                child: PagedListView<int, Customer>(
                  pagingController: controller.pagingController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  builderDelegate: PagedChildBuilderDelegate<Customer>(
                    firstPageProgressIndicatorBuilder: (_) =>
                        const CustomerListSkeleton(),
                    newPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                    firstPageErrorIndicatorBuilder: (context) => ErrorView(
                      message:
                          controller.pagingController.error?.toString() ??
                          'Unable to load customers.',
                      onRetry: () => controller.pagingController.refresh(),
                    ),
                    noItemsFoundIndicatorBuilder: (context) => EmptyView(
                      icon: Iconsax.people,
                      title: 'No customers found',
                      message: controller.searchQuery.value.isNotEmpty
                          ? 'Try adjusting your search criteria.'
                          : 'Add your first customer to begin rentals.',
                      actionLabel: 'Add Customer',
                      onAction: () async {
                        final result = await Get.toNamed(Routes.CUSTOMER_ADD);
                        if (result == true) {
                          controller.pagingController.refresh();
                        }
                      },
                    ),
                    noMoreItemsIndicatorBuilder: (context) =>
                        const EndOfListIndicator(),
                    itemBuilder: (context, customer, index) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Slidable(
                        key: ValueKey(customer.id),
                        endActionPane: canManageCustomers
                            ? ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) async {
                                      final result = await Get.toNamed(
                                        Routes.CUSTOMER_EDIT,
                                        arguments: customer,
                                      );
                                      if (result == true) {
                                        controller.pagingController.refresh();
                                      }
                                    },
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    icon: Icons.edit_rounded,
                                    label: 'Edit',
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(AppRadius.md),
                                      bottomLeft: Radius.circular(AppRadius.md),
                                    ),
                                  ),
                                  SlidableAction(
                                    onPressed: (_) => controller
                                        .confirmAndDelete(customer.id!),
                                    backgroundColor: theme.colorScheme.error,
                                    foregroundColor: theme.colorScheme.onError,
                                    icon: Icons.delete_rounded,
                                    label: 'Delete',
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(AppRadius.md),
                                      bottomRight: Radius.circular(
                                        AppRadius.md,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                        child: CustomerCard(customer: customer),
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
