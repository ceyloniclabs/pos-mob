import '../models/sale_category_model.dart';

abstract class SaleCategoryDataSource {
  Future<List<SaleCategoryModel>> getSaleCategories({Map<String, dynamic>? filters});
  Future<String> createSaleCategory(String name, String? description);
  Future<String> updateSaleCategory(int id, String name, String? description);
  Future<String> deleteSaleCategory(int id);
}
