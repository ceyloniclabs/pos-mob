import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import '../qr_navigation_handler.dart';
import '../qr_payload.dart';

/// Handles navigation for customers (table: 'customers').
class CustomerQrHandler implements QrNavigationHandler {
  @override
  String get tableName => 'customers';

  @override
  String get displayName => 'Customer';

  @override
  Future<void> handle(QrPayload payload) async {
    await Get.offNamed(Routes.CUSTOMER_DETAIL, arguments: payload.id);
  }
}
