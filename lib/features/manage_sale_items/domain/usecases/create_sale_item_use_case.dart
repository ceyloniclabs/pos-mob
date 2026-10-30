import 'dart:io';
import '../entities/sale_item.dart';
import '../repositories/sale_item_repository.dart';

class CreateSaleItemUseCase {
  final SaleItemRepository repository;

  CreateSaleItemUseCase(this.repository);

  Future<String> execute(SaleItem saleItem, List<File>? photos) async {
    return await repository.createSaleItem(saleItem, photos);
  }
}
