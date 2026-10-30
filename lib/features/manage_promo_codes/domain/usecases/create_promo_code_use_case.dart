import '../entities/promo_code.dart';
import '../repositories/promo_code_repository.dart';

class CreatePromoCodeUseCase {
  final PromoCodeRepository repository;

  CreatePromoCodeUseCase(this.repository);

  Future<PromoCode> execute(PromoCode promoCode) {
    return repository.createPromoCode(promoCode);
  }
}
