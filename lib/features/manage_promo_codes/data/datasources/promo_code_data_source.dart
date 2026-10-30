import '../models/promo_code_model.dart';

abstract class PromoCodeDataSource {
  Future<List<PromoCodeModel>> fetchPromoCodes({
    int? page,
    int? perPage,
    String? search,
    String? status,
  });

  Future<PromoCodeModel> fetchPromoCodeById(int id);

  Future<PromoCodeModel> createPromoCode(PromoCodeModel promoCode);

  Future<PromoCodeModel> updatePromoCode(PromoCodeModel promoCode);

  Future<void> deletePromoCode(int id);
}
