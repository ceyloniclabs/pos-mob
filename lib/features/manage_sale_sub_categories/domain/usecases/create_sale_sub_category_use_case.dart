import '../entities/sale_sub_category.dart';
import '../repositories/sale_sub_category_repository.dart';

class CreateSaleSubCategoryUseCase {
  final SaleSubCategoryRepository repository;

  CreateSaleSubCategoryUseCase(this.repository);

  Future<String> execute(SaleSubCategory saleSubCategory) {
    return repository.createSaleSubCategory(saleSubCategory);
  }
}
