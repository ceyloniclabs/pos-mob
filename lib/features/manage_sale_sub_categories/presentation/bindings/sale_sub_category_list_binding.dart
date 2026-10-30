import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';

import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_data_source.dart';
import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_data_source_factory.dart';
import 'package:pos/features/manage_sale_categories/data/repositories/sale_category_repository_impl.dart';
import 'package:pos/features/manage_sale_categories/domain/repositories/sale_category_repository.dart';
import 'package:pos/features/manage_sale_categories/domain/usecases/get_sale_categories_use_case.dart';

import '../../data/datasources/sale_sub_category_data_source.dart';
import '../../data/datasources/sale_sub_category_data_source_factory.dart';
import '../../data/repositories/sale_sub_category_repository_impl.dart';
import '../../domain/repositories/sale_sub_category_repository.dart';
import '../../domain/usecases/create_sale_sub_category_use_case.dart';
import '../../domain/usecases/delete_sale_sub_category_use_case.dart';
import '../../domain/usecases/get_sale_sub_categories_use_case.dart';
import '../../domain/usecases/update_sale_sub_category_use_case.dart';
import '../controllers/sale_sub_category_list_controller.dart';

class SaleSubCategoryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleSubCategoryDataSource>(
      () => SaleSubCategoryDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );

    Get.lazyPut<SaleCategoryDataSource>(
      () => SaleCategoryDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );

    Get.lazyPut<SaleSubCategoryRepository>(
      () => SaleSubCategoryRepositoryImpl(Get.find<SaleSubCategoryDataSource>()),
    );

    Get.lazyPut<SaleCategoryRepository>(
      () => SaleCategoryRepositoryImpl(Get.find<SaleCategoryDataSource>()),
    );

    Get.lazyPut<GetSaleCategoriesUseCase>(
      () => GetSaleCategoriesUseCase(Get.find<SaleCategoryRepository>()),
    );

    Get.lazyPut<GetSaleSubCategoriesUseCase>(
      () => GetSaleSubCategoriesUseCase(Get.find<SaleSubCategoryRepository>()),
    );

    Get.lazyPut<CreateSaleSubCategoryUseCase>(
      () => CreateSaleSubCategoryUseCase(Get.find<SaleSubCategoryRepository>()),
    );

    Get.lazyPut<UpdateSaleSubCategoryUseCase>(
      () => UpdateSaleSubCategoryUseCase(Get.find<SaleSubCategoryRepository>()),
    );

    Get.lazyPut<DeleteSaleSubCategoryUseCase>(
      () => DeleteSaleSubCategoryUseCase(Get.find<SaleSubCategoryRepository>()),
    );

    Get.lazyPut<SaleSubCategoryListController>(
      () => SaleSubCategoryListController(
        getSaleSubCategoriesUseCase: Get.find<GetSaleSubCategoriesUseCase>(),
        createSaleSubCategoryUseCase: Get.find<CreateSaleSubCategoryUseCase>(),
        updateSaleSubCategoryUseCase: Get.find<UpdateSaleSubCategoryUseCase>(),
        deleteSaleSubCategoryUseCase: Get.find<DeleteSaleSubCategoryUseCase>(),
        getSaleCategoriesUseCase: Get.find<GetSaleCategoriesUseCase>(),
      ),
    );
  }
}
