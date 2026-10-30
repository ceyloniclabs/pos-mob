import '../entities/promo_code.dart';
import '../repositories/promo_code_repository.dart';

class GetPromoCodeByIdUseCase {
  final PromoCodeRepository repository;

  GetPromoCodeByIdUseCase(this.repository);

  Future<PromoCode> execute(int id) {
    return repository.getPromoCodeById(id);
  }
}
