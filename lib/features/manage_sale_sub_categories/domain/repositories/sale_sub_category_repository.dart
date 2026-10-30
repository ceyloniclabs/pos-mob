import '../entities/sale_sub_category.dart';

abstract class SaleSubCategoryRepository {
  Future<List<SaleSubCategory>> getSaleSubCategories({Map<String, dynamic>? filters});
  Future<String> createSaleSubCategory(SaleSubCategory saleSubCategory);
  Future<String> updateSaleSubCategory(int id, SaleSubCategory saleSubCategory);
  Future<String> deleteSaleSubCategory(int id);
}
