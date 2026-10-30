import '../entities/gift_voucher.dart';

abstract class GiftVoucherRepository {
  Future<List<GiftVoucher>> getGiftVouchers({
    int? page,
    int? perPage,
    String? search,
    String? status,
  });

  Future<GiftVoucher> getGiftVoucherById(int id);

  Future<GiftVoucher> createGiftVoucher(GiftVoucher giftVoucher);

  Future<GiftVoucher> updateGiftVoucher(GiftVoucher giftVoucher);

  Future<void> deleteGiftVoucher(int id);
}
