import '../repositories/payment_invoice_repository.dart';

import '../entities/payment_record.dart';

class RecordPaymentInvoiceUseCase {
  final PaymentInvoiceRepository repository;

  RecordPaymentInvoiceUseCase(this.repository);

  Future<String> execute(PaymentRecord record) {
    return repository.recordPayment(record);
  }
}
