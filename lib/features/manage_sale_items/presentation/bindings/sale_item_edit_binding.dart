import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/manage_sale_brands/data/datasources/sale_brand_data_source.dart';
import 'package:pos/features/manage_sale_brands/data/datasources/sale_brand_data_source_factory.dart';
import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_data_source.dart';
import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_factory.dart';
import 'package:pos/features/manage_sale_sub_categories/data/datasources/sale_sub_category_data_source.dart';
import 'package:pos/features/manage_sale_sub_categories/data/datasources/sale_sub_category_data_source_factory.dart';

import '../../data/datasources/sale_item_data_source.dart';
import '../../data/datasources/sale_item_data_source_factory.dart';
import '../../data/repositories/sale_item_repository_impl.dart';
import '../../domain/repositories/sale_item_repository.dart';
import '../../domain/usecases/update_sale_item_use_case.dart';
import '../controllers/sale_item_edit_controller.dart';

class SaleItemEditBinding extends Bindings {
  @override
  void dependencies() {
    final backendType = Get.find<AppConfigController>().currentBackend.value;

    Get.lazyPut<SaleItemDataSource>(
      () => SaleItemDataSourceFactory.create(backendType),
    );

    Get.lazyPut<SaleItemRepository>(
      () => SaleItemRepositoryImpl(Get.find<SaleItemDataSource>()),
    );

    Get.lazyPut<UpdateSaleItemUseCase>(
      () => UpdateSaleItemUseCase(Get.find<SaleItemRepository>()),
    );

    Get.lazyPut<SaleBrandDataSource>(
      () => SaleBrandDataSourceFactory.create(backendType),
    );

    Get.lazyPut<SaleCategoryDataSource>(
      () => SaleCategoryFactory.create(backendType),
    );

    Get.lazyPut<SaleSubCategoryDataSource>(
      () => SaleSubCategoryDataSourceFactory.create(backendType),
    );

    Get.lazyPut<SaleItemEditController>(
      () => SaleItemEditController(
        Get.find<UpdateSaleItemUseCase>(),
        Get.find<SaleBrandDataSource>(),
        Get.find<SaleCategoryDataSource>(),
        Get.find<SaleSubCategoryDataSource>(),
      ),
    );
  }
}
