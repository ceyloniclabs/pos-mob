import '../entities/gift_voucher.dart';
import '../repositories/gift_voucher_repository.dart';

class GetGiftVoucherByIdUseCase {
  final GiftVoucherRepository repository;

  GetGiftVoucherByIdUseCase(this.repository);

  Future<GiftVoucher> execute(int id) {
    return repository.getGiftVoucherById(id);
  }
}
