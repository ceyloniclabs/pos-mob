import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source_factory.dart';
import 'package:pos/features/manage_sales/data/repositories/sale_repository_impl.dart';
import 'package:pos/features/manage_sales/domain/repositories/sale_repository.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_details_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_invoice_url_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/update_card_reference_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/update_sale_use_case.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_details_controller.dart';

class SaleDetailsBinding extends Bindings {
  @override
  void dependencies() {
    // Layer 1: Data Source
    if (!Get.isRegistered<SaleDataSource>()) {
      Get.lazyPut<SaleDataSource>(
        () => SaleDataSourceFactory.create(
          Get.find<AppConfigController>().currentBackend.value,
        ),
      );
    }

    // Layer 2: Repository
    if (!Get.isRegistered<SaleRepository>()) {
      Get.lazyPut<SaleRepository>(
        () => SaleRepositoryImpl(Get.find<SaleDataSource>()),
      );
    }

    // Layer 3: Use Cases
    Get.lazyPut<GetSaleDetailsUseCase>(
      () => GetSaleDetailsUseCase(Get.find<SaleRepository>()),
    );

    Get.lazyPut<UpdateSaleUseCase>(
      () => UpdateSaleUseCase(Get.find<SaleRepository>()),
    );

    Get.lazyPut<UpdateCardReferenceUseCase>(
      () => UpdateCardReferenceUseCase(Get.find<SaleRepository>()),
    );

    Get.lazyPut<GetSaleInvoiceUrlUseCase>(
      () => GetSaleInvoiceUrlUseCase(Get.find<SaleRepository>()),
    );

    // Layer 4: Controller
    Get.lazyPut<SaleDetailsController>(
      () => SaleDetailsController(
        getSaleDetailsUseCase: Get.find<GetSaleDetailsUseCase>(),
        updateSaleUseCase: Get.find<UpdateSaleUseCase>(),
        updateCardReferenceUseCase: Get.find<UpdateCardReferenceUseCase>(),
        getSaleInvoiceUrlUseCase: Get.find<GetSaleInvoiceUrlUseCase>(),
      ),
    );
  }
}
