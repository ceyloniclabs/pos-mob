import '../repositories/sale_category_repository.dart';

class DeleteSaleCategoryUseCase {
  final SaleCategoryRepository repository;

  DeleteSaleCategoryUseCase(this.repository);

  Future<String> execute(int id) {
    return repository.deleteSaleCategory(id);
  }
}
