import '../models/gift_voucher_model.dart';

abstract class GiftVoucherDataSource {
  Future<List<GiftVoucherModel>> fetchGiftVouchers({
    int? page,
    int? perPage,
    String? search,
    String? status,
  });

  Future<GiftVoucherModel> fetchGiftVoucherById(int id);

  Future<GiftVoucherModel> createGiftVoucher(GiftVoucherModel voucher);

  Future<GiftVoucherModel> updateGiftVoucher(GiftVoucherModel voucher);

  Future<void> deleteGiftVoucher(int id);
}
