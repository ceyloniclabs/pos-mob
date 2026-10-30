import 'package:get/get.dart';
import 'package:pos/core/routes/app_pages.dart';
import '../qr_navigation_handler.dart';
import '../qr_payload.dart';

/// Handles navigation for system users / staff members / admins (table: 'users').
class UserQrHandler implements QrNavigationHandler {
  @override
  String get tableName => 'users';

  @override
  String get displayName => 'Staff Member';

  @override
  Future<void> handle(QrPayload payload) async {
    await Get.offNamed(Routes.STAFF_DETAILS, arguments: payload.id);
  }
}

/// Fallback alias handler for table: 'staff'.
class StaffQrHandler implements QrNavigationHandler {
  @override
  String get tableName => 'staff';

  @override
  String get displayName => 'Staff Member';

  @override
  Future<void> handle(QrPayload payload) async {
    await Get.offNamed(Routes.STAFF_DETAILS, arguments: payload.id);
  }
}
