import '../../domain/entities/promo_code.dart';
import '../../domain/repositories/promo_code_repository.dart';
import '../datasources/promo_code_data_source.dart';
import '../models/promo_code_model.dart';

class PromoCodeRepositoryImpl implements PromoCodeRepository {
  final PromoCodeDataSource dataSource;

  PromoCodeRepositoryImpl(this.dataSource);

  @override
  Future<List<PromoCode>> getPromoCodes({
    int? page,
    int? perPage,
    String? search,
    String? status,
  }) {
    return dataSource.fetchPromoCodes(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
    );
  }

  @override
  Future<PromoCode> getPromoCodeById(int id) {
    return dataSource.fetchPromoCodeById(id);
  }

  @override
  Future<PromoCode> createPromoCode(PromoCode promoCode) {
    final model = PromoCodeModel.fromEntity(promoCode);
    return dataSource.createPromoCode(model);
  }

  @override
  Future<PromoCode> updatePromoCode(PromoCode promoCode) {
    final model = PromoCodeModel.fromEntity(promoCode);
    return dataSource.updatePromoCode(model);
  }

  @override
  Future<void> deletePromoCode(int id) {
    return dataSource.deletePromoCode(id);
  }
}
