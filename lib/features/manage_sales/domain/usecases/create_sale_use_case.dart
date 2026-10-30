import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

class CreateSaleUseCase {
  final SaleRepository repository;

  CreateSaleUseCase(this.repository);

  Future<String> execute(Sale sale) {
    return repository.createSale(sale);
  }
}
