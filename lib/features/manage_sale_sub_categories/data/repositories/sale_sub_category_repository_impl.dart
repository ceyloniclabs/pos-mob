import 'package:pos/core/models/base_get_list_response_model.dart';
import '../models/sale_sub_category_model.dart';
import '../../domain/entities/sale_sub_category.dart';
import '../../domain/repositories/sale_sub_category_repository.dart';
import '../datasources/sale_sub_category_data_source.dart';

class SaleSubCategoryRepositoryImpl implements SaleSubCategoryRepository {
  final SaleSubCategoryDataSource _dataSource;

  SaleSubCategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<SaleSubCategory>> getSaleSubCategories({
    Map<String, dynamic>? filters,
  }) async {
    final models = await _dataSource.getSaleSubCategories(filters: filters);
    final entities = models.map((model) => model.toEntity()).toList();
    if (models is PaginatedList<SaleSubCategoryModel>) {
      return PaginatedList<SaleSubCategory>(entities, meta: models.meta);
    }
    return entities;
  }

  @override
  Future<String> createSaleSubCategory(SaleSubCategory saleSubCategory) async {
    return await _dataSource.createSaleSubCategory(
      saleSubCategory.name,
      saleSubCategory.saleCategoryId,
      saleSubCategory.description,
    );
  }

  @override
  Future<String> updateSaleSubCategory(
    int id,
    SaleSubCategory saleSubCategory,
  ) async {
    return await _dataSource.updateSaleSubCategory(
      id,
      saleSubCategory.name,
      saleSubCategory.saleCategoryId,
      saleSubCategory.description,
    );
  }

  @override
  Future<String> deleteSaleSubCategory(int id) async {
    return await _dataSource.deleteSaleSubCategory(id);
  }
}
