import '../repositories/payment_invoice_repository.dart';

class GetBillUrlUseCase {
  final PaymentInvoiceRepository repository;

  GetBillUrlUseCase(this.repository);

  Future<String> execute(int rentalId) {
    return repository.getBillUrl(rentalId);
  }
}
