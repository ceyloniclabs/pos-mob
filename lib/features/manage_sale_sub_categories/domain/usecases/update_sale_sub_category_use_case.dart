import '../entities/sale_sub_category.dart';
import '../repositories/sale_sub_category_repository.dart';

class UpdateSaleSubCategoryUseCase {
  final SaleSubCategoryRepository repository;

  UpdateSaleSubCategoryUseCase(this.repository);

  Future<String> execute(int id, SaleSubCategory saleSubCategory) {
    return repository.updateSaleSubCategory(id, saleSubCategory);
  }
}
