import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source_factory.dart';
import 'package:pos/features/manage_sales/data/repositories/sale_repository_impl.dart';
import 'package:pos/features/manage_sales/domain/repositories/sale_repository.dart';
import 'package:pos/features/manage_sales/domain/usecases/delete_sale_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sale_invoice_url_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sales_use_case.dart';
import 'package:pos/features/manage_sales/domain/usecases/update_card_reference_use_case.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_controller.dart';

class SaleBinding extends Bindings {
  @override
  void dependencies() {
    // Layer 1: Data Source
    Get.lazyPut<SaleDataSource>(
      () => SaleDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
      fenix: true,
    );

    // Layer 2: Repository
    Get.lazyPut<SaleRepository>(
      () => SaleRepositoryImpl(Get.find<SaleDataSource>()),
      fenix: true,
    );

    // Layer 3: Use Case
    Get.lazyPut<GetSalesUseCase>(
      () => GetSalesUseCase(Get.find<SaleRepository>()),
      fenix: true,
    );
    Get.lazyPut<DeleteSaleUseCase>(
      () => DeleteSaleUseCase(Get.find<SaleRepository>()),
      fenix: true,
    );
    Get.lazyPut<UpdateCardReferenceUseCase>(
      () => UpdateCardReferenceUseCase(Get.find<SaleRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetSaleInvoiceUrlUseCase>(
      () => GetSaleInvoiceUrlUseCase(Get.find<SaleRepository>()),
      fenix: true,
    );

    // Layer 4: Controller
    Get.lazyPut<SaleController>(
      () => SaleController(
        getSalesUseCase: Get.find<GetSalesUseCase>(),
        deleteSaleUseCase: Get.find<DeleteSaleUseCase>(),
        updateCardReferenceUseCase: Get.find<UpdateCardReferenceUseCase>(),
        getSaleInvoiceUrlUseCase: Get.find<GetSaleInvoiceUrlUseCase>(),
      ),
      fenix: true,
    );
  }
}
