import '../repositories/sale_repository.dart';

class GetSaleInvoiceUrlUseCase {
  final SaleRepository _repository;

  GetSaleInvoiceUrlUseCase(this._repository);

  Future<String> execute(int id) {
    return _repository.getSaleInvoiceUrl(id);
  }
}
