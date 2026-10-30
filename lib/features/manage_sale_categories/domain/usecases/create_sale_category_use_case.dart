import '../entities/sale_category.dart';
import '../repositories/sale_category_repository.dart';

class CreateSaleCategoryUseCase {
  final SaleCategoryRepository repository;

  CreateSaleCategoryUseCase(this.repository);

  Future<String> execute(SaleCategory saleCategory) {
    return repository.createSaleCategory(saleCategory);
  }
}
