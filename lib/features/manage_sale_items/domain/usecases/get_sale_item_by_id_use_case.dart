import '../entities/sale_item.dart';
import '../repositories/sale_item_repository.dart';

class GetSaleItemByIdUseCase {
  final SaleItemRepository repository;

  GetSaleItemByIdUseCase(this.repository);

  Future<SaleItem> execute(int id) async {
    return await repository.getSaleItemById(id);
  }
}
