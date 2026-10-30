import 'dart:io';

import '../entities/sale_item.dart';

abstract class SaleItemRepository {
  Future<List<SaleItem>> getSaleItems({Map<String, dynamic>? filters});
  Future<SaleItem> getSaleItemById(int id);
  Future<String> createSaleItem(SaleItem saleItem, List<File>? photos);
  Future<String> updateSaleItem(int id, SaleItem saleItem, List<File>? photos);
  Future<String> deleteSaleItem(int id);
}
