import '../../domain/entities/payment_invoice.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/repositories/payment_invoice_repository.dart';
import '../datasources/payment_invoice_data_source.dart';

class PaymentInvoiceRepositoryImpl implements PaymentInvoiceRepository {
  final PaymentInvoiceDataSource _dataSource;

  PaymentInvoiceRepositoryImpl(this._dataSource);

  @override
  Future<PaymentInvoice> getPaymentInvoice(int rentalId) async {
    final model = await _dataSource.getPaymentInvoice(rentalId);
    return model.toEntity();
  }

  @override
  Future<String> recordPayment(PaymentRecord record) async {
    final payload = {
      "rental_id": record.rentalId,
      "amount": record.amount,
      "payment_method": record.paymentMethod.toLowerCase(),
      "payment_type": record.paymentType,
      "transaction_id": record.transactionId,
    };
    return await _dataSource.recordPayment(payload);
  }

  @override
  Future<String> getBillUrl(int rentalId) async {
    return await _dataSource.getBillUrl(rentalId);
  }
}
