// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const CONNECTION_MODE = _Paths.CONNECTION_MODE;
  static const CLOUD_AUTH_PREVIEW = _Paths.CLOUD_AUTH_PREVIEW;
  static const SCAN_SHOP = _Paths.SCAN_SHOP;
  static const SIGN_IN = _Paths.SIGN_IN;
  static const SIGN_UP = _Paths.SIGN_UP;
  static const MAIN = _Paths.MAIN;
  static const HOME = _Paths.HOME;
  static const SALES = _Paths.SALES;
  static const SALE = _Paths.SALE;
  static const SALE_ADD = _Paths.SALE_ADD;
  static const SALE_CHECKOUT = _Paths.SALE_CHECKOUT;
  static const SALE_DETAILS = _Paths.SALE_DETAILS;
  static const SALE_QR_SCANNER = _Paths.SALE_QR_SCANNER;

  static const CUSTOMER_ADD = _Paths.CUSTOMER_ADD;
  static const CUSTOMER_LIST = _Paths.CUSTOMER_LIST;
  static const CUSTOMER_DETAIL = CUSTOMER_LIST + _Paths.CUSTOMER_DETAIL;
  static const CUSTOMER_EDIT = _Paths.CUSTOMER_EDIT;

  static const SETTING = _Paths.SETTING;
  static const SALE_CATEGORY = _Paths.SALE_CATEGORY;
  static const SALE_SUB_CATEGORY = _Paths.SALE_SUB_CATEGORY;
  static const SALE_BRANDS = _Paths.SALE_BRANDS;
  static const SIZE = _Paths.SIZE;
  static const COLOR = _Paths.COLOR;
  static const REPORT = _Paths.REPORT;

  static const SHORTCUT = _Paths.SHORTCUT;
  static const STAFF = _Paths.STAFF;
  static const STAFF_DETAILS = _Paths.STAFF_DETAILS;
  static const STAFF_EDIT = _Paths.STAFF_EDIT;
  static const STAFF_ADD = _Paths.STAFF_ADD;

  static const SALE_ITEM_LIST = _Paths.SALE_ITEM_LIST;
  static const SALE_ITEM_ADD = _Paths.SALE_ITEM_ADD;
  static const SALE_ITEM_EDIT = _Paths.SALE_ITEM_EDIT;
  static const SALE_ITEM_DETAIL = _Paths.SALE_ITEM_DETAIL;

  static const PAYMENT_INVOICE = _Paths.PAYMENT_INVOICE;
  static const GIFT_VOUCHER_LIST = _Paths.GIFT_VOUCHER_LIST;
  static const GIFT_VOUCHER_ADD = _Paths.GIFT_VOUCHER_ADD;
  static const GIFT_VOUCHER_EDIT = _Paths.GIFT_VOUCHER_EDIT;
  static const GIFT_VOUCHER_DETAILS = _Paths.GIFT_VOUCHER_DETAILS;

  static const PROMO_CODE_LIST = _Paths.PROMO_CODE_LIST;
  static const PROMO_CODE_ADD = _Paths.PROMO_CODE_ADD;
  static const PROMO_CODE_EDIT = _Paths.PROMO_CODE_EDIT;
  static const PROMO_CODE_DETAILS = _Paths.PROMO_CODE_DETAILS;

  static const GLOBAL_SCANNER = _Paths.GLOBAL_SCANNER;
  static const PDF_PREVIEW = _Paths.PDF_PREVIEW;
  static const ACTIVITY_LOGS = _Paths.ACTIVITY_LOGS;
  static const SUBSCRIPTION = _Paths.SUBSCRIPTION;
  static const SUBSCRIPTION_HISTORY = _Paths.SUBSCRIPTION_HISTORY;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const CONNECTION_MODE = '/connection-mode';
  static const CLOUD_AUTH_PREVIEW = '/cloud-auth-preview';
  static const SCAN_SHOP = '/scan-shop';
  static const SIGN_IN = '/login';
  static const SIGN_UP = '/signup';
  static const MAIN = '/main';
  static const HOME = '/home';
  static const SALES = '/sales';
  static const SALE = '/sale';
  static const SALE_ADD = '/sale-create';
  static const SALE_CHECKOUT = '/sale-checkout';
  static const SALE_DETAILS = '/sale-details';
  static const SALE_QR_SCANNER = '/sale-qr-scanner';

  static const CUSTOMER_ADD = '/customer-add';
  static const CUSTOMER_LIST = '/cus_list';
  static const CUSTOMER_DETAIL = '/cus_detail';
  static const CUSTOMER_EDIT = '/cus_edit';

  static const SETTING = '/setting';
  static const SALE_CATEGORY = '/sale-category';
  static const SALE_SUB_CATEGORY = '/sale-sub-category';
  static const SALE_BRANDS = '/sale-brands';
  static const SIZE = '/size';
  static const COLOR = '/color';
  static const REPORT = '/report';

  static const SHORTCUT = '/shortcut';
  static const STAFF = '/staff';
  static const STAFF_DETAILS = '/staff-details';
  static const STAFF_EDIT = '/staff-edit';
  static const STAFF_ADD = '/staff-add';

  static const SALE_ITEM_LIST = '/sale-item-list';
  static const SALE_ITEM_ADD = '/sale-item-add';
  static const SALE_ITEM_EDIT = '/sale-item-edit';
  static const SALE_ITEM_DETAIL = '/sale-item-detail';

  static const PAYMENT_INVOICE = '/payment-invoice';
  static const GIFT_VOUCHER_LIST = '/gift-voucher-list';
  static const GIFT_VOUCHER_ADD = '/gift-voucher-add';
  static const GIFT_VOUCHER_EDIT = '/gift-voucher-edit';
  static const GIFT_VOUCHER_DETAILS = '/gift-voucher-details';

  static const PROMO_CODE_LIST = '/promo-code-list';
  static const PROMO_CODE_ADD = '/promo-code-add';
  static const PROMO_CODE_EDIT = '/promo-code-edit';
  static const PROMO_CODE_DETAILS = '/promo-code-details';

  static const GLOBAL_SCANNER = '/global-scanner';
  static const PDF_PREVIEW = '/pdf-preview';
  static const ACTIVITY_LOGS = '/activity-logs';
  static const SUBSCRIPTION = '/subscription';
  static const SUBSCRIPTION_HISTORY = '/subscription-history';
}
