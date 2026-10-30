import '../entities/payment_invoice.dart';
import '../repositories/payment_invoice_repository.dart';

class GetPaymentInvoiceUseCase {
  final PaymentInvoiceRepository repository;

  GetPaymentInvoiceUseCase(this.repository);

  Future<PaymentInvoice> execute(int rentalId) {
    return repository.getPaymentInvoice(rentalId);
  }
}
