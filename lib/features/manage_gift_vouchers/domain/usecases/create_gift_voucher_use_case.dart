import '../entities/gift_voucher.dart';
import '../repositories/gift_voucher_repository.dart';

class CreateGiftVoucherUseCase {
  final GiftVoucherRepository repository;

  CreateGiftVoucherUseCase(this.repository);

  Future<GiftVoucher> execute(GiftVoucher giftVoucher) {
    return repository.createGiftVoucher(giftVoucher);
  }
}
