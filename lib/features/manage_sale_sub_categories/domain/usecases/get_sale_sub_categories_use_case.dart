import '../entities/sale_sub_category.dart';
import '../repositories/sale_sub_category_repository.dart';

class GetSaleSubCategoriesUseCase {
  final SaleSubCategoryRepository repository;

  GetSaleSubCategoriesUseCase(this.repository);

  Future<List<SaleSubCategory>> execute({Map<String, dynamic>? filters}) {
    return repository.getSaleSubCategories(filters: filters);
  }
}
