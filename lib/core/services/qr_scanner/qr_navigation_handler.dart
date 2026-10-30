import 'qr_payload.dart';

/// Strategy contract for handling QR actions for specific table entities.
///
/// Any new table added in the future should implement this contract and register
/// with [GlobalQrRouter.register].
abstract class QrNavigationHandler {
  /// The table identifier matching the 'table' field in QR payload (e.g. 'rent_surf_boards').
  String get tableName;

  /// User-friendly label for logs and UI snackbars/toasts (e.g. 'Surfboard').
  String get displayName;

  /// Executes navigation or state change for the given parsed payload.
  Future<void> handle(QrPayload payload);
}
