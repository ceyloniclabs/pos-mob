import 'dart:io';

import 'package:pos/core/models/base_get_list_response_model.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/repositories/sale_item_repository.dart';
import '../datasources/sale_item_data_source.dart';
import '../models/sale_item_inventory_model.dart';

class SaleItemRepositoryImpl implements SaleItemRepository {
  final SaleItemDataSource _dataSource;

  SaleItemRepositoryImpl(this._dataSource);

  @override
  Future<List<SaleItem>> getSaleItems({Map<String, dynamic>? filters}) async {
    final models = await _dataSource.getSaleItems(filters: filters);
    final entities = models.map((model) => model.toEntity()).toList();
    if (models is PaginatedList<SaleItemInventoryModel>) {
      return PaginatedList<SaleItem>(entities, meta: models.meta);
    }
    return entities;
  }

  @override
  Future<SaleItem> getSaleItemById(int id) async {
    final model = await _dataSource.getSaleItemById(id);
    return model.toEntity();
  }

  @override
  Future<String> createSaleItem(SaleItem saleItem, List<File>? photos) async {
    final model = SaleItemInventoryModel.fromEntity(saleItem);
    return await _dataSource.createSaleItem(model, photos);
  }

  @override
  Future<String> updateSaleItem(
    int id,
    SaleItem saleItem,
    List<File>? photos,
  ) async {
    final model = SaleItemInventoryModel.fromEntity(saleItem);
    return await _dataSource.updateSaleItem(id, model, photos);
  }

  @override
  Future<String> deleteSaleItem(int id) async {
    return await _dataSource.deleteSaleItem(id);
  }
}
