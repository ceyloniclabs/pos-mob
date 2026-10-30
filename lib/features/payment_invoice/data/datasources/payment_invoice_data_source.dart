import '../models/payment_invoice_model.dart';

abstract class PaymentInvoiceDataSource {
  Future<PaymentInvoiceModel> getPaymentInvoice(int rentalId);
  Future<String> recordPayment(Map<String, dynamic> data);
  Future<String> getBillUrl(int rentalId);
}
