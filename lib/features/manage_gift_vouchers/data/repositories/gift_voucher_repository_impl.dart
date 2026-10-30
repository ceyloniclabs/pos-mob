import '../../domain/entities/gift_voucher.dart';
import '../../domain/repositories/gift_voucher_repository.dart';
import '../datasources/gift_voucher_data_source.dart';
import '../models/gift_voucher_model.dart';

class GiftVoucherRepositoryImpl implements GiftVoucherRepository {
  final GiftVoucherDataSource dataSource;

  GiftVoucherRepositoryImpl(this.dataSource);

  @override
  Future<List<GiftVoucher>> getGiftVouchers({
    int? page,
    int? perPage,
    String? search,
    String? status,
  }) {
    return dataSource.fetchGiftVouchers(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
    );
  }

  @override
  Future<GiftVoucher> getGiftVoucherById(int id) {
    return dataSource.fetchGiftVoucherById(id);
  }

  @override
  Future<GiftVoucher> createGiftVoucher(GiftVoucher giftVoucher) {
    final model = GiftVoucherModel.fromEntity(giftVoucher);
    return dataSource.createGiftVoucher(model);
  }

  @override
  Future<GiftVoucher> updateGiftVoucher(GiftVoucher giftVoucher) {
    final model = GiftVoucherModel.fromEntity(giftVoucher);
    return dataSource.updateGiftVoucher(model);
  }

  @override
  Future<void> deleteGiftVoucher(int id) {
    return dataSource.deleteGiftVoucher(id);
  }
}
