import '../entities/sale_category.dart';
import '../repositories/sale_category_repository.dart';

class UpdateSaleCategoryUseCase {
  final SaleCategoryRepository repository;

  UpdateSaleCategoryUseCase(this.repository);

  Future<String> execute(int id, SaleCategory saleCategory) {
    return repository.updateSaleCategory(id, saleCategory);
  }
}
