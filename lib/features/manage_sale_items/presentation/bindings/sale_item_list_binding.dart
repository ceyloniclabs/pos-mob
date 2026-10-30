import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/manage_sale_brands/data/datasources/sale_brand_data_source.dart';
import 'package:pos/features/manage_sale_brands/data/datasources/sale_brand_data_source_factory.dart';
import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_data_source.dart';
import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_factory.dart';

import '../../data/datasources/sale_item_data_source.dart';
import '../../data/datasources/sale_item_data_source_factory.dart';
import '../../data/repositories/sale_item_repository_impl.dart';
import '../../domain/repositories/sale_item_repository.dart';
import '../../domain/usecases/delete_sale_item_use_case.dart';
import '../../domain/usecases/get_sale_items_use_case.dart';
import '../controllers/sale_item_list_controller.dart';

class SaleItemListBinding extends Bindings {
  @override
  void dependencies() {
    final backendType = Get.find<AppConfigController>().currentBackend.value;

    Get.lazyPut<SaleItemDataSource>(
      () => SaleItemDataSourceFactory.create(backendType),
    );

    Get.lazyPut<SaleItemRepository>(
      () => SaleItemRepositoryImpl(Get.find<SaleItemDataSource>()),
    );

    Get.lazyPut<GetSaleItemsUseCase>(
      () => GetSaleItemsUseCase(Get.find<SaleItemRepository>()),
    );

    Get.lazyPut<DeleteSaleItemUseCase>(
      () => DeleteSaleItemUseCase(Get.find<SaleItemRepository>()),
    );

    Get.lazyPut<SaleCategoryDataSource>(
      () => SaleCategoryFactory.create(backendType),
    );

    Get.lazyPut<SaleBrandDataSource>(
      () => SaleBrandDataSourceFactory.create(backendType),
    );

    Get.lazyPut<SaleItemListController>(
      () => SaleItemListController(
        Get.find<GetSaleItemsUseCase>(),
        Get.find<DeleteSaleItemUseCase>(),
        Get.find<SaleCategoryDataSource>(),
        Get.find<SaleBrandDataSource>(),
      ),
    );
  }
}
