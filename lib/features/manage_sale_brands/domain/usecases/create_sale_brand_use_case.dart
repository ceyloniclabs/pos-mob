import '../entities/sale_brand.dart';
import '../repositories/sale_brand_repository.dart';

class CreateSaleBrandUseCase {
  final SaleBrandRepository repository;

  CreateSaleBrandUseCase(this.repository);

  Future<String> execute(SaleBrand brand) {
    return repository.createSaleBrand(brand);
  }
}
