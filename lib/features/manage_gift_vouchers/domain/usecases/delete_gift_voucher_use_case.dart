import '../repositories/gift_voucher_repository.dart';

class DeleteGiftVoucherUseCase {
  final GiftVoucherRepository repository;

  DeleteGiftVoucherUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteGiftVoucher(id);
  }
}
