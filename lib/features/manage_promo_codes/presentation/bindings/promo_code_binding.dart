import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/core/enums.dart';

import '../../data/datasources/promo_code_data_source.dart';
import '../../data/datasources/promo_code_data_source_factory.dart';
import '../../data/repositories/promo_code_repository_impl.dart';
import '../../domain/repositories/promo_code_repository.dart';
import '../../domain/usecases/create_promo_code_use_case.dart';
import '../../domain/usecases/delete_promo_code_use_case.dart';
import '../../domain/usecases/get_promo_code_by_id_use_case.dart';
import '../../domain/usecases/get_promo_codes_use_case.dart';
import '../../domain/usecases/update_promo_code_use_case.dart';
import '../controllers/promo_code_controller.dart';

class PromoCodeBinding extends Bindings {
  @override
  void dependencies() {
    BackendProviderType backend = BackendProviderType.laravel;
    if (Get.isRegistered<AppConfigController>()) {
      backend = Get.find<AppConfigController>().currentBackend.value;
    }

    // Layer 1: Data Source
    Get.lazyPut<PromoCodeDataSource>(
      () => PromoCodeDataSourceFactory.create(backend),
    );

    // Layer 2: Repository
    Get.lazyPut<PromoCodeRepository>(
      () => PromoCodeRepositoryImpl(Get.find<PromoCodeDataSource>()),
    );

    // Layer 3: Use Cases
    Get.lazyPut<GetPromoCodesUseCase>(
      () => GetPromoCodesUseCase(Get.find<PromoCodeRepository>()),
    );
    Get.lazyPut<GetPromoCodeByIdUseCase>(
      () => GetPromoCodeByIdUseCase(Get.find<PromoCodeRepository>()),
    );
    Get.lazyPut<CreatePromoCodeUseCase>(
      () => CreatePromoCodeUseCase(Get.find<PromoCodeRepository>()),
    );
    Get.lazyPut<UpdatePromoCodeUseCase>(
      () => UpdatePromoCodeUseCase(Get.find<PromoCodeRepository>()),
    );
    Get.lazyPut<DeletePromoCodeUseCase>(
      () => DeletePromoCodeUseCase(Get.find<PromoCodeRepository>()),
    );

    // Layer 4: Controller
    Get.lazyPut<PromoCodeController>(
      () => PromoCodeController(
        getPromoCodesUseCase: Get.find<GetPromoCodesUseCase>(),
        getPromoCodeByIdUseCase: Get.find<GetPromoCodeByIdUseCase>(),
        createPromoCodeUseCase: Get.find<CreatePromoCodeUseCase>(),
        updatePromoCodeUseCase: Get.find<UpdatePromoCodeUseCase>(),
        deletePromoCodeUseCase: Get.find<DeletePromoCodeUseCase>(),
      ),
    );
  }
}
