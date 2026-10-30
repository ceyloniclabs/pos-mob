import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import '../qr_navigation_handler.dart';
import '../qr_payload.dart';

/// Handles navigation for retail sale items (table: 'sale_items').
class SaleItemQrHandler implements QrNavigationHandler {
  @override
  String get tableName => 'sale_items';

  @override
  String get displayName => 'Sale Item';

  @override
  Future<void> handle(QrPayload payload) async {
    await Get.offNamed(Routes.SALE_ITEM_DETAIL, arguments: payload.id);
  }
}
