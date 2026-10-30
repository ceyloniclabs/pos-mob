import '../entities/promo_code.dart';
import '../repositories/promo_code_repository.dart';

class GetPromoCodesUseCase {
  final PromoCodeRepository repository;

  GetPromoCodesUseCase(this.repository);

  Future<List<PromoCode>> execute({
    int? page,
    int? perPage,
    String? search,
    String? status,
  }) {
    return repository.getPromoCodes(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
    );
  }
}
