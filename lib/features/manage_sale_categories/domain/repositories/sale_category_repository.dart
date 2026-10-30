import '../entities/sale_category.dart';

abstract class SaleCategoryRepository {
  Future<List<SaleCategory>> getSaleCategories({Map<String, dynamic>? filters});
  Future<String> createSaleCategory(SaleCategory saleCategory);
  Future<String> updateSaleCategory(int id, SaleCategory saleCategory);
  Future<String> deleteSaleCategory(int id);
}
