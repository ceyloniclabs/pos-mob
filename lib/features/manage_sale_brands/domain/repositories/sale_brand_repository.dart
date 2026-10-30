import '../entities/sale_brand.dart';

abstract class SaleBrandRepository {
  Future<List<SaleBrand>> getSaleBrands({Map<String, dynamic>? filters});
  Future<String> createSaleBrand(SaleBrand brand);
  Future<String> updateSaleBrand(int id, SaleBrand brand);
  Future<String> deleteSaleBrand(int id);
}
