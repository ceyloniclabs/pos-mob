import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

class UpdateSaleUseCase {
  final SaleRepository repository;

  UpdateSaleUseCase(this.repository);

  Future<String> execute(int id, Sale sale) {
    return repository.updateSale(id, sale);
  }
}
