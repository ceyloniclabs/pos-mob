import '../entities/sale_brand.dart';
import '../repositories/sale_brand_repository.dart';

class UpdateSaleBrandUseCase {
  final SaleBrandRepository repository;

  UpdateSaleBrandUseCase(this.repository);

  Future<String> execute(int id, SaleBrand brand) {
    return repository.updateSaleBrand(id, brand);
  }
}
