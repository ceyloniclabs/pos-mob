import 'package:pos/core/models/base_get_list_response_model.dart';
import '../../domain/entities/sale_brand.dart';
import '../../domain/repositories/sale_brand_repository.dart';
import '../datasources/sale_brand_data_source.dart';
import '../models/sale_brand_model.dart';

class SaleBrandRepositoryImpl implements SaleBrandRepository {
  final SaleBrandDataSource _dataSource;

  SaleBrandRepositoryImpl(this._dataSource);

  @override
  Future<List<SaleBrand>> getSaleBrands({Map<String, dynamic>? filters}) async {
    final models = await _dataSource.getSaleBrands(filters: filters);
    final entities = models.map((m) => m.toEntity()).toList();
    if (models is PaginatedList<SaleBrandModel>) {
      return PaginatedList<SaleBrand>(entities, meta: models.meta);
    }
    return entities;
  }

  @override
  Future<String> createSaleBrand(SaleBrand brand) async {
    return await _dataSource.createSaleBrand(brand.name, brand.saleCategoryId);
  }

  @override
  Future<String> updateSaleBrand(int id, SaleBrand brand) async {
    return await _dataSource.updateSaleBrand(id, brand.name, brand.saleCategoryId);
  }

  @override
  Future<String> deleteSaleBrand(int id) async {
    return await _dataSource.deleteSaleBrand(id);
  }
}
