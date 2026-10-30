import '../entities/gift_voucher.dart';
import '../repositories/gift_voucher_repository.dart';

class GetGiftVouchersUseCase {
  final GiftVoucherRepository repository;

  GetGiftVouchersUseCase(this.repository);

  Future<List<GiftVoucher>> execute({
    int? page,
    int? perPage,
    String? search,
    String? status,
  }) {
    return repository.getGiftVouchers(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
    );
  }
}
