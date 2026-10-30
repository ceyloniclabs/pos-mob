import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';

import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_data_source.dart';
import 'package:pos/features/manage_sale_categories/data/datasources/sale_category_data_source_factory.dart';
import 'package:pos/features/manage_sale_categories/data/repositories/sale_category_repository_impl.dart';
import 'package:pos/features/manage_sale_categories/domain/repositories/sale_category_repository.dart';
import 'package:pos/features/manage_sale_categories/domain/usecases/get_sale_categories_use_case.dart';

import '../../data/datasources/sale_brand_data_source.dart';
import '../../data/datasources/sale_brand_data_source_factory.dart';
import '../../data/repositories/sale_brand_repository_impl.dart';
import '../../domain/repositories/sale_brand_repository.dart';
import '../../domain/usecases/create_sale_brand_use_case.dart';
import '../../domain/usecases/delete_sale_brand_use_case.dart';
import '../../domain/usecases/get_sale_brands_use_case.dart';
import '../../domain/usecases/update_sale_brand_use_case.dart';
import '../controllers/sale_brand_list_controller.dart';

class SaleBrandListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleBrandDataSource>(
      () => SaleBrandDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );

    Get.lazyPut<SaleCategoryDataSource>(
      () => SaleCategoryDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );

    Get.lazyPut<SaleBrandRepository>(
      () => SaleBrandRepositoryImpl(Get.find<SaleBrandDataSource>()),
    );

    Get.lazyPut<SaleCategoryRepository>(
      () => SaleCategoryRepositoryImpl(Get.find<SaleCategoryDataSource>()),
    );

    Get.lazyPut<GetSaleCategoriesUseCase>(
      () => GetSaleCategoriesUseCase(Get.find<SaleCategoryRepository>()),
    );

    Get.lazyPut<GetSaleBrandsUseCase>(
      () => GetSaleBrandsUseCase(Get.find<SaleBrandRepository>()),
    );

    Get.lazyPut<CreateSaleBrandUseCase>(
      () => CreateSaleBrandUseCase(Get.find<SaleBrandRepository>()),
    );

    Get.lazyPut<UpdateSaleBrandUseCase>(
      () => UpdateSaleBrandUseCase(Get.find<SaleBrandRepository>()),
    );

    Get.lazyPut<DeleteSaleBrandUseCase>(
      () => DeleteSaleBrandUseCase(Get.find<SaleBrandRepository>()),
    );

    Get.lazyPut<SaleBrandListController>(
      () => SaleBrandListController(
        getSaleBrandsUseCase: Get.find<GetSaleBrandsUseCase>(),
        createSaleBrandUseCase: Get.find<CreateSaleBrandUseCase>(),
        updateSaleBrandUseCase: Get.find<UpdateSaleBrandUseCase>(),
        deleteSaleBrandUseCase: Get.find<DeleteSaleBrandUseCase>(),
        getSaleCategoriesUseCase: Get.find<GetSaleCategoriesUseCase>(),
      ),
    );
  }
}
