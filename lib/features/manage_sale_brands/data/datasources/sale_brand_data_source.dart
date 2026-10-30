import '../models/sale_brand_model.dart';

abstract class SaleBrandDataSource {
  Future<List<SaleBrandModel>> getSaleBrands({Map<String, dynamic>? filters});
  Future<String> createSaleBrand(String name, int saleCategoryId);
  Future<String> updateSaleBrand(int id, String name, int saleCategoryId);
  Future<String> deleteSaleBrand(int id);
}
