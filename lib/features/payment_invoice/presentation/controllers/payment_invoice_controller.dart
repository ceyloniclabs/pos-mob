import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/widgets/common_dialog.dart';
import 'package:pos/core/widgets/pdf_viewer/app_pdf_viewer_screen.dart';
import 'package:pos/features/payment_invoice/domain/entities/payment_invoice.dart';
import 'package:pos/features/payment_invoice/domain/usecases/get_payment_invoice_use_case.dart';
import 'package:pos/features/payment_invoice/domain/usecases/record_payment_invoice_use_case.dart';
import 'package:pos/features/payment_invoice/domain/validators/payment_invoice_validator.dart';
import 'package:pos/features/payment_invoice/domain/entities/payment_record.dart';
import 'package:pos/features/payment_invoice/domain/usecases/get_bill_url_use_case.dart';

class PaymentInvoiceController extends GetxController {
  final GetPaymentInvoiceUseCase getPaymentInvoiceUseCase;
  final RecordPaymentInvoiceUseCase recordPaymentInvoiceUseCase;
  final GetBillUrlUseCase getBillUrlUseCase;

  PaymentInvoiceController({
    required this.getPaymentInvoiceUseCase,
    required this.recordPaymentInvoiceUseCase,
    required this.getBillUrlUseCase,
  });

  late dynamic rental;

  final paymentMethod = 'Cash'.obs;
  final paymentAmountController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  String errorMessage = '';

  PaymentInvoice? summary;

  @override
  void onInit() {
    super.onInit();
    rental = Get.arguments;
    fetchInvoice();
  }

  Future<void> fetchInvoice() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      summary = await getPaymentInvoiceUseCase.execute(rental.id!);
      paymentAmountController.text = summary!.balanceDue.toStringAsFixed(2);
    } catch (e, stack) {
      debugPrint("Invoice Fetch Error: $e\n$stack");
      hasError.value = true;
      errorMessage = e.toString();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.isSnackbarOpen != true) {
          Get.snackbar('Error', 'Failed to load invoice',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recordPayment() async {
    final amountText = paymentAmountController.text.trim();
    final amountError = PaymentInvoiceValidator.validatePaymentAmount(amountText);
    if (amountError != null) {
      Get.snackbar('Error', amountError,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final methodError = PaymentInvoiceValidator.validatePaymentMethod(paymentMethod.value);
    if (methodError != null) {
      Get.snackbar('Error', methodError,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final double amount = double.parse(amountText);

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      final record = PaymentRecord(
        rentalId: rental.id!,
        amount: amount,
        paymentMethod: paymentMethod.value,
      );
      final message = await recordPaymentInvoiceUseCase.execute(record);

      Get.back(); // close loading dialog

      await CommonDialog.showSuccessDialog(
        title: 'Payment Successful',
        message: message.isNotEmpty
            ? message
            : 'Payment recorded successfully!',
        buttonText: 'Return to Home',
        onConfirm: () {
          Get.offAllNamed(Routes.MAIN);
        },
      );
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar('Error', 'Failed to record payment: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> downloadDetailedBill() async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      final url = await getBillUrlUseCase.execute(rental.id!);
      Get.back(); // close loading
      final context = Get.context;
      if (context != null && context.mounted) {
        await AppPdfViewerScreen.openDirect(
          context,
          url: url,
          title: 'Detailed Bill #${rental.id ?? ''}',
          fileName: 'rental_bill_${rental.id}.pdf',
        );
      }
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar('Error', 'Failed to get bill URL: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    paymentAmountController.dispose();
    super.onClose();
  }
}
