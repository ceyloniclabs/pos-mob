import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/utils/app_date_time_utils.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/features/manage_sales/domain/entities/sale.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_details_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_invoice_url_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/update_card_reference_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/update_sale_use_case.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_controller.dart';
import 'package:pos/core/widgets/pdf_viewer/app_pdf_viewer_screen.dart';

class SaleDetailsController extends GetxController {
  final GetSaleDetailsUseCase getSaleDetailsUseCase;
  final UpdateSaleUseCase updateSaleUseCase;
  final UpdateCardReferenceUseCase updateCardReferenceUseCase;
  final GetSaleInvoiceUrlUseCase getSaleInvoiceUrlUseCase;

  SaleDetailsController({
    required this.getSaleDetailsUseCase,
    required this.updateSaleUseCase,
    required this.updateCardReferenceUseCase,
    required this.getSaleInvoiceUrlUseCase,
  });

  final Rx<Sale?> sale = Rx<Sale?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingStatus = false.obs;

  int? get saleId {
    if (sale.value != null) return sale.value!.id;
    if (Get.arguments is int) return Get.arguments as int;
    if (Get.arguments is Sale) return (Get.arguments as Sale).id;
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Sale) {
      sale.value = Get.arguments as Sale;
    }
    if (saleId != null) {
      loadSaleDetails();
    }
  }

  Future<void> loadSaleDetails() async {
    final id = saleId;
    if (id == null) return;

    try {
      if (sale.value == null) {
        isLoading.value = true;
      }
      final result = await getSaleDetailsUseCase.execute(id);
      sale.value = result;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to load sale details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeSale({required String paymentMethod}) async {
    final currentSale = sale.value;
    if (currentSale == null) return;

    try {
      isUpdatingStatus.value = true;

      // Build updated sale entity — no raw Map in controller
      final updatedSale = currentSale.copyWith(
        saleStatus: 'completed',
        paymentMethod: paymentMethod,
        saleDate: currentSale.saleDate.isNotEmpty
            ? AppDateTimeUtils.toUtcDateOnly(
                AppDateTimeUtils.parseServerUtc(currentSale.saleDate) ??
                    DateTime.now(),
              )!
            : AppDateTimeUtils.toUtcDateOnly(DateTime.now())!,
      );

      final message =
          await updateSaleUseCase.execute(currentSale.id, updatedSale);
      ScaffoldMessageUtils.showSuccess(message);

      // Refresh both current details and sales list
      await loadSaleDetails();
      if (Get.isRegistered<SaleController>()) {
        Get.find<SaleController>().pagingController.refresh();
      }
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to complete sale: $e');
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> continueToEdit() async {
    final currentSale = sale.value;
    if (currentSale == null) return;

    final result = await Get.toNamed(Routes.SALE_ADD, arguments: currentSale);
    if (result == true) {
      await loadSaleDetails();
      if (Get.isRegistered<SaleController>()) {
        Get.find<SaleController>().pagingController.refresh();
      }
    }
  }

  Future<bool> updateCardReference(String transactionId) async {
    final currentSale = sale.value;
    if (currentSale == null) return false;

    try {
      isUpdatingStatus.value = true;
      await updateCardReferenceUseCase.execute(
        currentSale.id,
        transactionId,
        status: currentSale.saleStatus,
      );
      ScaffoldMessageUtils.showSuccess('Card reference updated successfully');
      await loadSaleDetails();
      if (Get.isRegistered<SaleController>()) {
        SaleController.to.refreshSales();
      }
      return true;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to update card reference: $e');
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> openSaleInvoice(BuildContext context) async {
    final currentSale = sale.value;
    if (currentSale == null) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      final invoiceUrl = await getSaleInvoiceUrlUseCase.execute(currentSale.id);
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (context.mounted) {
        final invoiceTitle = 'Sales Invoice #${currentSale.id}';
        final invoiceFileName = 'invoice_${currentSale.id}.pdf';

        await AppPdfViewerScreen.openDirect(
          context,
          url: invoiceUrl,
          title: invoiceTitle,
          fileName: invoiceFileName,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ScaffoldMessageUtils.showError('Failed to retrieve invoice: $e');
    }
  }
}
