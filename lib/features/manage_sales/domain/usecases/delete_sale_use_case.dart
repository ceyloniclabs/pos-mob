import '../repositories/sale_repository.dart';

class DeleteSaleUseCase {
  final SaleRepository repository;

  DeleteSaleUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteSale(id);
  }
}
