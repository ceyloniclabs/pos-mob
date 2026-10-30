import 'dart:developer';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'qr_payload.dart';
import 'qr_navigation_handler.dart';
import 'handlers/sale_qr_handler.dart';
import 'handlers/sale_item_qr_handler.dart';
import 'handlers/user_qr_handler.dart';
import 'handlers/customer_qr_handler.dart';

/// Central registry and router for QR code deep-linking in POS.
class GlobalQrRouter {
  static final Map<String, QrNavigationHandler> _handlers = {};
  static bool _isInitialized = false;

  /// Initializes default table handlers (sales, sale_items, users, customers).
  static void initializeDefaults() {
    if (_isInitialized) return;
    register(SaleQrHandler());
    register(SaleItemQrHandler());
    register(UserQrHandler());
    register(StaffQrHandler());
    register(CustomerQrHandler());
    _isInitialized = true;
  }

  /// Registers a table handler. Enables open-ended extensibility without modifying existing code.
  static void register(QrNavigationHandler handler) {
    _handlers[handler.tableName.toLowerCase()] = handler;
  }

  /// Clears registered handlers (useful for testing).
  static void clear() {
    _handlers.clear();
    _isInitialized = false;
  }

  /// Checks if a handler exists for a table.
  static bool hasHandler(String tableName) {
    initializeDefaults();
    return _handlers.containsKey(tableName.toLowerCase());
  }

  /// Processes raw QR content, parses JSON, and routes to the appropriate handler.
  ///
  /// Returns `true` if handled and routed successfully, or `false` on failure/unsupported table.
  static Future<bool> routeRaw(String rawValue) async {
    initializeDefaults();

    try {
      final payload = QrPayload.fromString(rawValue);
      final handler = _handlers[payload.table];

      if (handler == null) {
        log("Unhandled QR code table: ${payload.table}");
        ScaffoldMessageUtils.showError("Unsupported QR code for: ${payload.table}");
        return false;
      }

      await handler.handle(payload);
      return true;
    } catch (e) {
      log("Error routing raw QR: $e");
      ScaffoldMessageUtils.showError("Invalid or unrecognizable QR code");
      return false;
    }
  }
}
