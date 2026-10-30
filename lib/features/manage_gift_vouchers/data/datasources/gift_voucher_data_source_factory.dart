import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';
import 'gift_voucher_data_source.dart';
import 'gift_voucher_laravel_data_source_impl.dart';

class GiftVoucherDataSourceFactory {
  static GiftVoucherDataSource create(BackendProviderType type) {
    switch (type) {
      case BackendProviderType.laravel:
        return GiftVoucherLaravelDataSourceImpl(Get.find<ApiService>());
      case BackendProviderType.firebase:
        throw UnimplementedError('Firebase provider not yet implemented for gift vouchers');
    }
  }
}
