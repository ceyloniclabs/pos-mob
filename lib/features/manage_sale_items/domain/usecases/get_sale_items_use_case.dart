import '../entities/sale_item.dart';
import '../repositories/sale_item_repository.dart';

class GetSaleItemsUseCase {
  final SaleItemRepository repository;

  GetSaleItemsUseCase(this.repository);

  Future<List<SaleItem>> execute({Map<String, dynamic>? filters}) async {
    return await repository.getSaleItems(filters: filters);
  }
}
