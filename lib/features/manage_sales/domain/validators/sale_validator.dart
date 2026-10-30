import 'package:pos/core/utils/app_data_formatter.dart';

class SaleValidator {
  static String? validateSaleDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sale date is required';
    }
    return null;
  }

  static String? validateStaffId(int? value) {
    if (value == null || value <= 0) {
      return 'Staff member is required';
    }
    return null;
  }

  static String? validatePaymentMethod(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Payment method is required';
    }
    return null;
  }

  static String? validateSaleStatus(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sale status is required';
    }
    return null;
  }

  static String? validateItems(List<dynamic> items) {
    if (items.isEmpty) {
      return 'Please add at least one product to the sale';
    }
    return null;
  }

  static String? validateDiscount(double discount, double subtotal) {
    if (discount < 0) {
      return 'Discount amount cannot be negative';
    }
    if (discount > subtotal) {
      return 'Discount cannot exceed subtotal amount';
    }
    return null;
  }

  static String? validateCashAmountReceived(
    double amountReceived,
    double grandTotal, {
    String? currency,
  }) {
    if (amountReceived < grandTotal) {
      final receivedFormatted = AppDataFormatter.formatCurrency(
        amountReceived,
        customCurrency: currency,
      );
      final grandTotalFormatted = AppDataFormatter.formatCurrency(
        grandTotal,
        customCurrency: currency,
      );
      return 'Amount received ($receivedFormatted) is less than Grand Total ($grandTotalFormatted)';
    }
    return null;
  }
}
