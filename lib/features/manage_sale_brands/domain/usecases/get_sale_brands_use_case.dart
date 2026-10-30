import '../entities/sale_brand.dart';
import '../repositories/sale_brand_repository.dart';

class GetSaleBrandsUseCase {
  final SaleBrandRepository repository;

  GetSaleBrandsUseCase(this.repository);

  Future<List<SaleBrand>> execute({Map<String, dynamic>? filters}) {
    return repository.getSaleBrands(filters: filters);
  }
}
