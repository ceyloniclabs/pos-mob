import '../entities/payment_invoice.dart';
import '../entities/payment_record.dart';

abstract class PaymentInvoiceRepository {
  Future<PaymentInvoice> getPaymentInvoice(int rentalId);
  Future<String> recordPayment(PaymentRecord record);
  Future<String> getBillUrl(int rentalId);
}
