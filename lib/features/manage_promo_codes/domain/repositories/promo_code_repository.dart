import '../entities/promo_code.dart';

abstract class PromoCodeRepository {
  Future<List<PromoCode>> getPromoCodes({
    int? page,
    int? perPage,
    String? search,
    String? status,
  });

  Future<PromoCode> getPromoCodeById(int id);

  Future<PromoCode> createPromoCode(PromoCode promoCode);

  Future<PromoCode> updatePromoCode(PromoCode promoCode);

  Future<void> deletePromoCode(int id);
}
