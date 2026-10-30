import '../entities/promo_code.dart';
import '../repositories/promo_code_repository.dart';

class UpdatePromoCodeUseCase {
  final PromoCodeRepository repository;

  UpdatePromoCodeUseCase(this.repository);

  Future<PromoCode> execute(PromoCode promoCode) {
    return repository.updatePromoCode(promoCode);
  }
}
