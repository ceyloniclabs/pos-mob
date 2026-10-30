import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/core/enums.dart';

import '../../data/datasources/gift_voucher_data_source.dart';
import '../../data/datasources/gift_voucher_data_source_factory.dart';
import '../../data/repositories/gift_voucher_repository_impl.dart';
import '../../domain/repositories/gift_voucher_repository.dart';
import '../../domain/usecases/create_gift_voucher_use_case.dart';
import '../../domain/usecases/delete_gift_voucher_use_case.dart';
import '../../domain/usecases/get_gift_voucher_by_id_use_case.dart';
import '../../domain/usecases/get_gift_vouchers_use_case.dart';
import '../../domain/usecases/update_gift_voucher_use_case.dart';
import '../controllers/gift_voucher_controller.dart';

class GiftVoucherBinding extends Bindings {
  @override
  void dependencies() {
    BackendProviderType backend = BackendProviderType.laravel;
    if (Get.isRegistered<AppConfigController>()) {
      backend = Get.find<AppConfigController>().currentBackend.value;
    }

    // Layer 1: Data Source
    Get.lazyPut<GiftVoucherDataSource>(
      () => GiftVoucherDataSourceFactory.create(backend),
    );

    // Layer 2: Repository
    Get.lazyPut<GiftVoucherRepository>(
      () => GiftVoucherRepositoryImpl(Get.find<GiftVoucherDataSource>()),
    );

    // Layer 3: Use Cases
    Get.lazyPut<GetGiftVouchersUseCase>(
      () => GetGiftVouchersUseCase(Get.find<GiftVoucherRepository>()),
    );
    Get.lazyPut<GetGiftVoucherByIdUseCase>(
      () => GetGiftVoucherByIdUseCase(Get.find<GiftVoucherRepository>()),
    );
    Get.lazyPut<CreateGiftVoucherUseCase>(
      () => CreateGiftVoucherUseCase(Get.find<GiftVoucherRepository>()),
    );
    Get.lazyPut<UpdateGiftVoucherUseCase>(
      () => UpdateGiftVoucherUseCase(Get.find<GiftVoucherRepository>()),
    );
    Get.lazyPut<DeleteGiftVoucherUseCase>(
      () => DeleteGiftVoucherUseCase(Get.find<GiftVoucherRepository>()),
    );

    // Layer 4: Controller
    Get.lazyPut<GiftVoucherController>(
      () => GiftVoucherController(
        getGiftVouchersUseCase: Get.find<GetGiftVouchersUseCase>(),
        getGiftVoucherByIdUseCase: Get.find<GetGiftVoucherByIdUseCase>(),
        createGiftVoucherUseCase: Get.find<CreateGiftVoucherUseCase>(),
        updateGiftVoucherUseCase: Get.find<UpdateGiftVoucherUseCase>(),
        deleteGiftVoucherUseCase: Get.find<DeleteGiftVoucherUseCase>(),
      ),
    );
  }
}
