import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';

import '../../data/datasources/payment_invoice_data_source.dart';
import '../../data/datasources/payment_invoice_data_source_factory.dart';
import '../../data/repositories/payment_invoice_repository_impl.dart';
import '../../domain/repositories/payment_invoice_repository.dart';
import '../../domain/usecases/get_bill_url_use_case.dart';
import '../../domain/usecases/get_payment_invoice_use_case.dart';
import '../../domain/usecases/record_payment_invoice_use_case.dart';
import '../controllers/payment_invoice_controller.dart';

class PaymentInvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentInvoiceDataSource>(
      () => PaymentInvoiceDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );

    Get.lazyPut<PaymentInvoiceRepository>(
      () => PaymentInvoiceRepositoryImpl(Get.find<PaymentInvoiceDataSource>()),
    );

    Get.lazyPut<GetPaymentInvoiceUseCase>(
      () => GetPaymentInvoiceUseCase(Get.find<PaymentInvoiceRepository>()),
    );

    Get.lazyPut<RecordPaymentInvoiceUseCase>(
      () => RecordPaymentInvoiceUseCase(Get.find<PaymentInvoiceRepository>()),
    );

    Get.lazyPut<GetBillUrlUseCase>(
      () => GetBillUrlUseCase(Get.find<PaymentInvoiceRepository>()),
    );

    Get.lazyPut<PaymentInvoiceController>(
      () => PaymentInvoiceController(
        getPaymentInvoiceUseCase: Get.find<GetPaymentInvoiceUseCase>(),
        recordPaymentInvoiceUseCase: Get.find<RecordPaymentInvoiceUseCase>(),
        getBillUrlUseCase: Get.find<GetBillUrlUseCase>(),
      ),
    );
  }
}
