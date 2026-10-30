enum ShopRole {
  admin,
  staff,
  unknown;

  static ShopRole fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'admin':
        return ShopRole.admin;
      case 'staff':
        return ShopRole.staff;
      default:
        return ShopRole.unknown;
    }
  }
}

enum AppPermission {
  operateSales,
  manageSalesCatalog,
  manageCustomers,
  registerAndLookupCustomers,
  manageInventory,
  managePromotions,
  validatePromotions,
  viewReports,
  viewAuditLogs,
  manageStaff,
  manageShopSettings,
  viewHelp,
  viewSubscription,
}

class AccessPolicy {
  AccessPolicy._();

  static bool allows(String? role, AppPermission permission) {
    switch (ShopRole.fromValue(role)) {
      case ShopRole.admin:
        return true;
      case ShopRole.staff:
        return const {
          AppPermission.operateSales,
          AppPermission.registerAndLookupCustomers,
          AppPermission.validatePromotions,
          AppPermission.viewHelp,
        }.contains(permission);
      case ShopRole.unknown:
        return false;
    }
  }
}
