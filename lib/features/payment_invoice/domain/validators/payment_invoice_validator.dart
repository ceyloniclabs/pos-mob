class PaymentInvoiceValidator {
  static String? validatePaymentAmount(String? amountText) {
    if (amountText == null || amountText.trim().isEmpty) {
      return 'Please enter a payment amount';
    }
    final double? amount = double.tryParse(amountText.trim());
    if (amount == null || amount < 0) {
      return 'Invalid payment amount';
    }
    return null;
  }

  static String? validatePaymentMethod(String? method) {
    if (method == null || method.trim().isEmpty) {
      return 'Please select a payment method';
    }
    return null;
  }
}
