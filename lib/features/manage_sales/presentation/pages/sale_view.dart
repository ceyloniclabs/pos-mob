import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/empty_view.dart';
import 'package:pos/core/widgets/end_of_list_indicator.dart';
import 'package:pos/core/widgets/error_view.dart';
import 'package:pos/features/manage_sales/domain/entities/sale.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_controller.dart';
import 'package:pos/features/manage_sales/presentation/widgets/add_card_reference_dialog.dart';
import 'package:pos/features/manage_sales/presentation/widgets/sale_card.dart';
import 'package:pos/features/manage_sales/presentation/widgets/sale_filter_sheet.dart';

class SaleView extends GetView<SaleController> {
  const SaleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Sales',
        centerTitle: true,
        showbackArrow: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New Sale',
            onPressed: () async {
              final result = await Get.toNamed(Routes.SALE_ADD);
              if (result == true) {
                controller.pagingController.refresh();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(Routes.SALE_ADD);
          if (result == true) {
            controller.pagingController.refresh();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Sale'),
      ),
      body: ResponsiveCenter(
        maxWidth: 720,
        child: Column(
          children: [
            // Search & Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: (val) => controller.searchQuery.value = val,
                      decoration: InputDecoration(
                        hintText: 'Search sales by invoice, ref...',
                        prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                        suffixIcon: Obx(
                          () => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: controller.clearSearch,
                                )
                              : const SizedBox.shrink(),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapSm,
                  Obx(() {
                    final hasActiveFilters = controller.hasActiveFilters;
                    final theme = Theme.of(context);

                    return Badge(
                      isLabelVisible: hasActiveFilters,
                      smallSize: 8,
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.filter_list_rounded, size: 22),
                        tooltip: 'Filter Sales',
                        style: hasActiveFilters
                            ? IconButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onPrimaryContainer,
                              )
                            : null,
                        onPressed: () => SaleFilterSheet.show(
                          context,
                          controller: controller,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Active Filter Chips
            Obx(() {
              if (!controller.hasActiveFilters) return const SizedBox.shrink();
              final theme = Theme.of(context);
              final scheme = theme.colorScheme;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (controller.selectedStatus.value != 'all')
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: InputChip(
                            label: Text(
                              'Status: ${controller.selectedStatus.value.capitalizeFirst}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onDeleted: controller.clearStatus,
                            deleteIconColor: scheme.primary,
                            backgroundColor: scheme.primaryContainer.withValues(
                              alpha: 0.5,
                            ),
                            side: BorderSide(
                              color: scheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      if (controller.selectedDate.value != null)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: InputChip(
                            label: Text(
                              'Date: ${DateFormat('MMM dd, yyyy').format(controller.selectedDate.value!)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onDeleted: controller.clearDate,
                            deleteIconColor: scheme.primary,
                            backgroundColor: scheme.primaryContainer.withValues(
                              alpha: 0.5,
                            ),
                            side: BorderSide(
                              color: scheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: controller.resetFilters,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                        ),
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Paginated Sales List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    Future.sync(() => controller.pagingController.refresh()),
                child: PagedListView<int, Sale>(
                  pagingController: controller.pagingController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  builderDelegate: PagedChildBuilderDelegate<Sale>(
                    firstPageProgressIndicatorBuilder: (_) =>
                        const SaleListSkeleton(),
                    newPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    ),
                    firstPageErrorIndicatorBuilder: (context) => ErrorView(
                      message: controller.pagingController.error?.toString() ??
                          'Unable to load sales records.',
                      onRetry: () => controller.pagingController.refresh(),
                    ),
                    noItemsFoundIndicatorBuilder: (_) => EmptyView(
                      icon: Iconsax.receipt_2,
                      title: 'No sales records found',
                      message:
                          'Recorded sales and checkout invoices will appear here.',
                      actionLabel: 'Create Sale',
                      onAction: () async {
                        final result = await Get.toNamed(Routes.SALE_ADD);
                        if (result == true) {
                          controller.pagingController.refresh();
                        }
                      },
                    ),
                    noMoreItemsIndicatorBuilder: (context) =>
                        const EndOfListIndicator(),
                    itemBuilder: (context, sale, index) =>
                        _buildSaleItem(context, sale),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleItem(BuildContext context, Sale sale) {
    final theme = Theme.of(context);

    final isPending = sale.saleStatus.trim().toLowerCase() == 'pending';
    final isCompleted = sale.saleStatus.trim().toLowerCase() == 'completed';
    final isCard = sale.paymentMethod.trim().toLowerCase() == 'card';

    final showEdit = isPending;
    final showCardRef = isCompleted && isCard;
    final showDelete = isPending;
    final showInvoice = isCompleted;

    final actions = <Widget>[];

    if (showCardRef) {
      final hasRef =
          sale.transactionId != null && sale.transactionId!.trim().isNotEmpty;
      actions.add(
        SlidableAction(
          onPressed: (_) async {
            await AddCardReferenceDialog.show(
              context,
              sale: sale,
              onSave: (ref) => controller.updateCardReference(sale.id, ref),
            );
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          icon: Icons.credit_card_rounded,
          label: hasRef ? 'Edit Ref' : 'Add Ref',
          borderRadius: AppRadius.mdAll,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      );
    } else if (showEdit) {
      actions.add(
        SlidableAction(
          onPressed: (_) async {
            final result = await Get.toNamed(Routes.SALE_ADD, arguments: sale);
            if (result == true) {
              controller.pagingController.refresh();
            }
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          icon: Icons.edit_rounded,
          label: 'Edit',
          borderRadius: AppRadius.mdAll,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      );
    }

    if (showDelete) {
      actions.add(
        SlidableAction(
          onPressed: (_) => _showDeleteDialog(context, sale),
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          icon: Icons.delete_rounded,
          label: 'Delete',
          borderRadius: AppRadius.mdAll,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      );
    }

    if (showInvoice) {
      actions.add(
        SlidableAction(
          onPressed: (_) => controller.openSaleInvoice(context, sale),
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          icon: Icons.receipt_long_rounded,
          label: 'Invoice',
          borderRadius: AppRadius.mdAll,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      );
    }

    final cardContent = SaleCard(
      sale: sale,
      onTap: () async {
        final result = await Get.toNamed(Routes.SALE_DETAILS, arguments: sale);
        if (result == true) {
          controller.pagingController.refresh();
        }
      },
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: actions.isEmpty
          ? cardContent
          : Slidable(
              key: ValueKey(sale.id),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: actions,
              ),
              child: cardContent,
            ),
    );
  }

  void _showDeleteDialog(BuildContext context, Sale sale) {
    showConfirmDeleteDialog(
      title: 'Delete Sale',
      message:
          'Are you sure you want to delete sale "${sale.transactionId ?? '#${sale.id}'}"? This action cannot be undone.',
      onConfirm: () {
        controller.deleteSale(sale);
      },
    );
  }
}
