import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';

import 'payment_invoice_data_source.dart';
import 'payment_invoice_laravel_data_source_impl.dart';

class PaymentInvoiceDataSourceFactory {
  static PaymentInvoiceDataSource create(BackendProviderType providerType) {
    switch (providerType) {
      case BackendProviderType.laravel:
        return PaymentInvoiceLaravelDataSourceImpl(Get.find<ApiService>());
      default:
        throw Exception("Unsupported BackendProviderType");
    }
  }
}
