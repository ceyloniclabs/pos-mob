import 'package:pos/core/models/base_get_list_response_model.dart';
import '../../domain/entities/sale_category.dart';
import '../../domain/repositories/sale_category_repository.dart';
import '../datasources/sale_category_data_source.dart';
import '../models/sale_category_model.dart';

class SaleCategoryRepositoryImpl implements SaleCategoryRepository {
  final SaleCategoryDataSource _dataSource;

  SaleCategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<SaleCategory>> getSaleCategories({
    Map<String, dynamic>? filters,
  }) async {
    final models = await _dataSource.getSaleCategories(filters: filters);
    final entities = models.map((model) => model.toEntity()).toList();
    if (models is PaginatedList<SaleCategoryModel>) {
      return PaginatedList<SaleCategory>(entities, meta: models.meta);
    }
    return entities;
  }

  @override
  Future<String> createSaleCategory(SaleCategory saleCategory) async {
    return await _dataSource.createSaleCategory(
      saleCategory.name,
      saleCategory.description,
    );
  }

  @override
  Future<String> updateSaleCategory(int id, SaleCategory saleCategory) async {
    return await _dataSource.updateSaleCategory(
      id,
      saleCategory.name,
      saleCategory.description,
    );
  }

  @override
  Future<String> deleteSaleCategory(int id) async {
    return await _dataSource.deleteSaleCategory(id);
  }
}
