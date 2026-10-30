import 'dart:io';

import '../models/sale_item_inventory_model.dart';

abstract class SaleItemDataSource {
  Future<List<SaleItemInventoryModel>> getSaleItems({Map<String, dynamic>? filters});
  Future<SaleItemInventoryModel> getSaleItemById(int id);
  Future<String> createSaleItem(
    SaleItemInventoryModel model,
    List<File>? photos,
  );
  Future<String> updateSaleItem(
    int id,
    SaleItemInventoryModel model,
    List<File>? photos,
  );
  Future<String> deleteSaleItem(int id);
}
