import '../repositories/sale_item_repository.dart';

class DeleteSaleItemUseCase {
  final SaleItemRepository repository;

  DeleteSaleItemUseCase(this.repository);

  Future<String> execute(int id) async {
    return await repository.deleteSaleItem(id);
  }
}
