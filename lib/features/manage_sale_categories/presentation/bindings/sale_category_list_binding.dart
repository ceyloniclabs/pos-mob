import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';

import '../../data/datasources/sale_category_data_source.dart';
import '../../data/datasources/sale_category_data_source_factory.dart';
import '../../data/repositories/sale_category_repository_impl.dart';
import '../../domain/repositories/sale_category_repository.dart';
import '../../domain/usecases/create_sale_category_use_case.dart';
import '../../domain/usecases/delete_sale_category_use_case.dart';
import '../../domain/usecases/get_sale_categories_use_case.dart';
import '../../domain/usecases/update_sale_category_use_case.dart';
import '../controllers/sale_category_list_controller.dart';

class SaleCategoryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleCategoryDataSource>(
      () => SaleCategoryDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );

    Get.lazyPut<SaleCategoryRepository>(
      () => SaleCategoryRepositoryImpl(Get.find<SaleCategoryDataSource>()),
    );

    Get.lazyPut<GetSaleCategoriesUseCase>(
      () => GetSaleCategoriesUseCase(Get.find<SaleCategoryRepository>()),
    );

    Get.lazyPut<CreateSaleCategoryUseCase>(
      () => CreateSaleCategoryUseCase(Get.find<SaleCategoryRepository>()),
    );

    Get.lazyPut<UpdateSaleCategoryUseCase>(
      () => UpdateSaleCategoryUseCase(Get.find<SaleCategoryRepository>()),
    );

    Get.lazyPut<DeleteSaleCategoryUseCase>(
      () => DeleteSaleCategoryUseCase(Get.find<SaleCategoryRepository>()),
    );

    Get.lazyPut<SaleCategoryListController>(
      () => SaleCategoryListController(
        getSaleCategoriesUseCase: Get.find<GetSaleCategoriesUseCase>(),
        createSaleCategoryUseCase: Get.find<CreateSaleCategoryUseCase>(),
        updateSaleCategoryUseCase: Get.find<UpdateSaleCategoryUseCase>(),
        deleteSaleCategoryUseCase: Get.find<DeleteSaleCategoryUseCase>(),
      ),
    );
  }
}
