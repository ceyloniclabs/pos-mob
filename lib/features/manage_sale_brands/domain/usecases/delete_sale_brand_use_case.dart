import '../repositories/sale_brand_repository.dart';

class DeleteSaleBrandUseCase {
  final SaleBrandRepository repository;

  DeleteSaleBrandUseCase(this.repository);

  Future<String> execute(int id) {
    return repository.deleteSaleBrand(id);
  }
}
