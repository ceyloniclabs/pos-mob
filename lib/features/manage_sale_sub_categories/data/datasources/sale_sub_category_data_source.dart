import '../models/sale_sub_category_model.dart';

abstract class SaleSubCategoryDataSource {
  Future<List<SaleSubCategoryModel>> getSaleSubCategories({Map<String, dynamic>? filters});
  Future<String> createSaleSubCategory(String name, int saleCategoryId, String? description);
  Future<String> updateSaleSubCategory(int id, String name, int saleCategoryId, String? description);
  Future<String> deleteSaleSubCategory(int id);
}
