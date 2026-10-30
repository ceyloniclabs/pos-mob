import 'dart:io';

import '../entities/sale_item.dart';
import '../repositories/sale_item_repository.dart';

class UpdateSaleItemUseCase {
  final SaleItemRepository repository;

  UpdateSaleItemUseCase(this.repository);

  Future<String> execute(int id, SaleItem saleItem, List<File>? photos) async {
    return await repository.updateSaleItem(id, saleItem, photos);
  }
}
