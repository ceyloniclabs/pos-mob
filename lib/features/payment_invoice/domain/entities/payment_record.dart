import '../validators/payment_invoice_validator.dart';

class PaymentRecord {
  final int rentalId;
  final double amount;
  final String paymentMethod;
  final String paymentType;
  final String? transactionId;

  PaymentRecord({
    required this.rentalId,
    required this.amount,
    required this.paymentMethod,
    this.paymentType = 'full',
    this.transactionId,
  }) {
    final amountError = PaymentInvoiceValidator.validatePaymentAmount(amount.toString());
    if (amountError != null) {
      throw ArgumentError(amountError);
    }
    final methodError = PaymentInvoiceValidator.validatePaymentMethod(paymentMethod);
    if (methodError != null) {
      throw ArgumentError(methodError);
    }
  }
}
