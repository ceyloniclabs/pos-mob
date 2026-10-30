import '../repositories/promo_code_repository.dart';

class DeletePromoCodeUseCase {
  final PromoCodeRepository repository;

  DeletePromoCodeUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deletePromoCode(id);
  }
}
