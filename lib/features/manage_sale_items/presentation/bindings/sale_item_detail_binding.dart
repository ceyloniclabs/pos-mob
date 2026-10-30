import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';

import '../../data/datasources/sale_item_data_source.dart';
import '../../data/datasources/sale_item_data_source_factory.dart';
import '../../data/repositories/sale_item_repository_impl.dart';
import '../../domain/repositories/sale_item_repository.dart';
import '../../domain/usecases/delete_sale_item_use_case.dart';
import '../../domain/usecases/get_sale_item_by_id_use_case.dart';
import '../controllers/sale_item_detail_controller.dart';

class SaleItemDetailBinding extends Bindings {
  @override
  void dependencies() {
    final backendType = Get.find<AppConfigController>().currentBackend.value;

    Get.lazyPut<SaleItemDataSource>(
      () => SaleItemDataSourceFactory.create(backendType),
    );

    Get.lazyPut<SaleItemRepository>(
      () => SaleItemRepositoryImpl(Get.find<SaleItemDataSource>()),
    );

    Get.lazyPut<DeleteSaleItemUseCase>(
      () => DeleteSaleItemUseCase(Get.find<SaleItemRepository>()),
    );

    Get.lazyPut<GetSaleItemByIdUseCase>(
      () => GetSaleItemByIdUseCase(Get.find<SaleItemRepository>()),
    );

    Get.lazyPut<SaleItemDetailController>(
      () => SaleItemDetailController(
        Get.find<DeleteSaleItemUseCase>(),
        Get.find<GetSaleItemByIdUseCase>(),
      ),
    );
  }
}
