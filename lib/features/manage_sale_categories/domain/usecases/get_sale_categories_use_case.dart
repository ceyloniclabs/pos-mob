import '../entities/sale_category.dart';
import '../repositories/sale_category_repository.dart';

class GetSaleCategoriesUseCase {
  final SaleCategoryRepository repository;

  GetSaleCategoriesUseCase(this.repository);

  Future<List<SaleCategory>> execute({Map<String, dynamic>? filters}) {
    return repository.getSaleCategories(filters: filters);
  }
}
