import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/utils/app_logger.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/features/manage_sales/domain/entities/sale.dart';
import 'package:pos/features/manage_sales/domain/usecases/delete_sale_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_invoice_url_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sales_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/update_card_reference_use_case.dart';
import 'package:pos/core/widgets/pdf_viewer/app_pdf_viewer_screen.dart';

class SaleController extends GetxController {
  static SaleController get to => Get.find<SaleController>();

  final GetSalesUseCase getSalesUseCase;
  final DeleteSaleUseCase deleteSaleUseCase;
  final UpdateCardReferenceUseCase updateCardReferenceUseCase;
  final GetSaleInvoiceUrlUseCase getSaleInvoiceUrlUseCase;

  SaleController({
    required this.getSalesUseCase,
    required this.deleteSaleUseCase,
    required this.updateCardReferenceUseCase,
    required this.getSaleInvoiceUrlUseCase,
  });

  static const int _pageSize = 10;

  final PagingController<int, Sale> pagingController =
      PagingController(
        firstPageKey: 1,
        invisibleItemsThreshold: 1,
      );

  // Search & Filter Observables
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxBool isFiltersVisible = false.obs;
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();

    pagingController.addPageRequestListener(
      (pageKey) {
        getSales(pageKey);
      },
    );

    _searchWorker = debounce(
      searchQuery,
      (_) => pagingController.refresh(),
      time: const Duration(milliseconds: 350),
    );
  }

  bool get hasActiveFilters =>
      selectedStatus.value != 'all' || selectedDate.value != null;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    pagingController.refresh();
  }

  void clearDate() {
    selectedDate.value = null;
    pagingController.refresh();
  }

  void setStatus(String status) {
    selectedStatus.value = status;
    pagingController.refresh();
  }

  void clearStatus() {
    selectedStatus.value = 'all';
    pagingController.refresh();
  }

  void resetFilters() {
    selectedStatus.value = 'all';
    selectedDate.value = null;
    pagingController.refresh();
  }

  void refreshSales() {
    try {
      pagingController.refresh();
    } catch (e) {
      AppLogger.error('Error refreshing sales list: $e');
    }
  }

  Future<void> getSales(int pageKey) async {
    try {
      final filters = <String, dynamic>{
        'per_page': _pageSize,
        if (searchQuery.value.trim().isNotEmpty)
          'search': searchQuery.value.trim(),
        if (selectedStatus.value != 'all')
          'status': selectedStatus.value,
        if (selectedDate.value != null)
          'date': selectedDate.value!.toIso8601String().substring(0, 10),
      };

      AppLogger.debug('📦 [SaleController] Fetching sales: page=$pageKey, filters=$filters');

      final result = await getSalesUseCase.execute(
        page: pageKey,
        filters: filters,
      );

      AppLogger.debug(
        '📦 [SaleController] Page $pageKey loaded ${result.length} sales (hasMore: ${result is PaginatedList ? (result as PaginatedList).hasMore : false})',
      );

      if (isClosed) return;
      pagingController.appendPageResult(
        newItems: result,
        currentPageKey: pageKey,
        defaultPageSize: _pageSize,
        idSelector: (s) => s.id,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get sales on page $pageKey: $error',
          error: error, stackTrace: stackTrace);
      if (isClosed) return;
      pagingController.error = error;
    }
  }

  Future<void> deleteSale(Sale sale) async {
    try {
      await deleteSaleUseCase.execute(sale.id);
      ScaffoldMessageUtils.showSuccess('Sale deleted successfully');
      pagingController.refresh();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete sale: $e',
          error: e, stackTrace: stackTrace);
      ScaffoldMessageUtils.showError('Failed to delete sale: ${e.toString()}');
    }
  }

  Future<bool> updateCardReference(
    int saleId,
    String transactionId, {
    String status = 'completed',
  }) async {
    try {
      await updateCardReferenceUseCase.execute(
        saleId,
        transactionId,
        status: status,
      );
      ScaffoldMessageUtils.showSuccess('Card reference updated successfully');
      pagingController.refresh();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update card reference: $e',
          error: e, stackTrace: stackTrace);
      ScaffoldMessageUtils.showError(
          'Failed to update card reference: ${e.toString()}');
      return false;
    }
  }

  Future<void> openSaleInvoice(BuildContext context, Sale sale) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      final invoiceUrl = await getSaleInvoiceUrlUseCase.execute(sale.id);
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (context.mounted) {
        final invoiceTitle = 'Sales Invoice #${sale.id}';
        final invoiceFileName = 'invoice_${sale.id}.pdf';

        await AppPdfViewerScreen.openDirect(
          context,
          url: invoiceUrl,
          title: invoiceTitle,
          fileName: invoiceFileName,
        );
      }
    } catch (e, stackTrace) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      AppLogger.error('Failed to get invoice URL: $e',
          error: e, stackTrace: stackTrace);
      ScaffoldMessageUtils.showError('Failed to retrieve invoice: ${e.toString()}');
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchWorker?.dispose();
    pagingController.dispose();
    super.onClose();
  }
}
