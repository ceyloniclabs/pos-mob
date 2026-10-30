import '../repositories/sale_sub_category_repository.dart';

class DeleteSaleSubCategoryUseCase {
  final SaleSubCategoryRepository repository;

  DeleteSaleSubCategoryUseCase(this.repository);

  Future<String> execute(int id) {
    return repository.deleteSaleSubCategory(id);
  }
}
