import '../entities/gift_voucher.dart';
import '../repositories/gift_voucher_repository.dart';

class UpdateGiftVoucherUseCase {
  final GiftVoucherRepository repository;

  UpdateGiftVoucherUseCase(this.repository);

  Future<GiftVoucher> execute(GiftVoucher giftVoucher) {
    return repository.updateGiftVoucher(giftVoucher);
  }
}
