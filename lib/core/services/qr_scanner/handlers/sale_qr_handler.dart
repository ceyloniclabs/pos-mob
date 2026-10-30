import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import '../qr_navigation_handler.dart';
import '../qr_payload.dart';

/// Handles navigation for sales transactions (table: 'sales').
class SaleQrHandler implements QrNavigationHandler {
  @override
  String get tableName => 'sales';

  @override
  String get displayName => 'Sale';

  @override
  Future<void> handle(QrPayload payload) async {
    await Get.offNamed(Routes.SALE_DETAILS, arguments: payload.id);
  }
}
