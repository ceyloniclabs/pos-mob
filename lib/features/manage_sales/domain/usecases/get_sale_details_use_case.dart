import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

class GetSaleDetailsUseCase {
  final SaleRepository repository;

  GetSaleDetailsUseCase(this.repository);

  Future<Sale> execute(int id) {
    return repository.getSaleById(id);
  }
}
