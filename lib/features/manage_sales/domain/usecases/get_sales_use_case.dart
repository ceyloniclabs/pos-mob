import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

class GetSalesUseCase {
  final SaleRepository repository;

  GetSalesUseCase(this.repository);

  Future<List<Sale>> execute({int page = 1, Map<String, dynamic>? filters}) {
    return repository.getSales(page: page, filters: filters);
  }
}
