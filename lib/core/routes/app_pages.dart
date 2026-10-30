import 'package:get/get.dart';
import 'package:pos/core/access/access_policy.dart';
import 'package:pos/core/access/permission_gate.dart';
import 'package:pos/core/widgets/pdf_viewer/app_pdf_viewer_screen.dart';

import 'package:pos/features/auth/presentation/bindings/sign_in_binding.dart';
import 'package:pos/features/auth/presentation/bindings/sign_up_binding.dart';
import 'package:pos/features/auth/presentation/pages/sign_in_view.dart';
import 'package:pos/features/auth/presentation/pages/sign_up_view.dart';
import 'package:pos/features/qr_scanner/presentation/bindings/global_qr_scanner_binding.dart';
import 'package:pos/features/qr_scanner/presentation/pages/global_qr_scanner_view.dart';
import 'package:pos/features/manage_sale_brands/presentation/bindings/sale_brand_list_binding.dart';
import 'package:pos/features/manage_sale_brands/presentation/pages/sale_brand_list_view.dart';
import 'package:pos/features/manage_customers/presentation/bindings/customer_add_binding.dart';
import 'package:pos/features/manage_customers/presentation/bindings/customer_detail_binding.dart';
import 'package:pos/features/manage_customers/presentation/bindings/customer_edit_binding.dart';
import 'package:pos/features/manage_customers/presentation/bindings/customer_list_binding.dart';
import 'package:pos/features/manage_customers/presentation/pages/customer_add_view.dart';
import 'package:pos/features/manage_customers/presentation/pages/customer_detail_view.dart';
import 'package:pos/features/manage_customers/presentation/pages/customer_edit_view.dart';
import 'package:pos/features/manage_customers/presentation/pages/customer_list_view.dart';
import 'package:pos/features/home/presentation/bindings/home_binding.dart';
import 'package:pos/features/home/presentation/pages/home_view.dart';
import 'package:pos/features/main/presentation/bindings/main_binding.dart';
import 'package:pos/features/main/presentation/pages/main_view.dart';
import 'package:pos/features/report/presentation/bindings/report_binding.dart';
import 'package:pos/features/report/presentation/pages/report_view.dart';
import 'package:pos/features/manage_sales/presentation/bindings/sale_binding.dart';
import 'package:pos/features/manage_sales/presentation/pages/sale_view.dart';
import 'package:pos/features/manage_sales/presentation/bindings/sale_create_binding.dart';
import 'package:pos/features/manage_sales/presentation/pages/sale_create_view.dart';
import 'package:pos/features/manage_sales/presentation/bindings/sale_details_binding.dart';
import 'package:pos/features/manage_sales/presentation/pages/sale_details_view.dart';
import 'package:pos/features/manage_sales/presentation/pages/sale_checkout_view.dart';
import 'package:pos/features/manage_sales/presentation/bindings/sale_pos_scanner_binding.dart';
import 'package:pos/features/manage_sales/presentation/pages/sale_pos_scanner_view.dart';

import 'package:pos/features/manage_sale_categories/presentation/bindings/sale_category_list_binding.dart';
import 'package:pos/features/manage_sale_categories/presentation/pages/sale_category_list_view.dart';
import 'package:pos/features/manage_sale_sub_categories/presentation/bindings/sale_sub_category_list_binding.dart';
import 'package:pos/features/manage_sale_sub_categories/presentation/pages/sale_sub_category_list_view.dart';
import 'package:pos/features/manage_sale_items/presentation/bindings/sale_item_add_binding.dart';
import 'package:pos/features/manage_sale_items/presentation/pages/sale_item_add_view.dart';
import 'package:pos/features/manage_sale_items/presentation/bindings/sale_item_list_binding.dart';
import 'package:pos/features/manage_sale_items/presentation/pages/sale_item_list_view.dart';
import 'package:pos/features/manage_sale_items/presentation/bindings/sale_item_edit_binding.dart';
import 'package:pos/features/manage_sale_items/presentation/pages/sale_item_edit_view.dart';
import 'package:pos/features/manage_sale_items/presentation/bindings/sale_item_detail_binding.dart';
import 'package:pos/features/manage_sale_items/presentation/pages/sale_item_detail_view.dart';
import 'package:pos/features/payment_invoice/presentation/bindings/payment_invoice_binding.dart';
import 'package:pos/features/payment_invoice/presentation/pages/payment_invoice_view.dart';
import 'package:pos/features/manage_gift_vouchers/presentation/bindings/gift_voucher_binding.dart';
import 'package:pos/features/manage_gift_vouchers/presentation/pages/gift_voucher_list_view.dart';
import 'package:pos/features/manage_gift_vouchers/presentation/pages/gift_voucher_add_view.dart';
import 'package:pos/features/manage_gift_vouchers/presentation/pages/gift_voucher_edit_view.dart';
import 'package:pos/features/manage_gift_vouchers/presentation/pages/gift_voucher_details_view.dart';
import 'package:pos/features/manage_promo_codes/presentation/bindings/promo_code_binding.dart';
import 'package:pos/features/manage_promo_codes/presentation/pages/promo_code_list_view.dart';
import 'package:pos/features/manage_promo_codes/presentation/pages/promo_code_add_view.dart';
import 'package:pos/features/manage_promo_codes/presentation/pages/promo_code_edit_view.dart';
import 'package:pos/features/manage_promo_codes/presentation/pages/promo_code_details_view.dart';
import 'package:pos/features/setting/presentation/bindings/setting_binding.dart';
import 'package:pos/features/setting/presentation/pages/setting_view.dart';
import 'package:pos/features/shortcut/presentation/bindings/shortcut_binding.dart';
import 'package:pos/features/shortcut/presentation/pages/shortcut_view.dart';
import 'package:pos/features/splash/presentation/bindings/splash_binding.dart';
import 'package:pos/features/splash/presentation/pages/splash_view.dart';
import 'package:pos/features/shop_connection/presentation/pages/connect_shop_view.dart';
import 'package:pos/features/shop_connection/presentation/bindings/connect_shop_binding.dart';
import 'package:pos/features/shop_connection/presentation/pages/connection_mode_view.dart';
import 'package:pos/features/shop_connection/presentation/bindings/connection_mode_binding.dart';
import 'package:pos/features/shop_connection/presentation/pages/cloud_auth_placeholder_view.dart';
import 'package:pos/features/manage_staff/presentation/bindings/staff_binding.dart';
import 'package:pos/features/manage_staff/presentation/pages/staff_view.dart';
import 'package:pos/features/manage_staff/presentation/pages/staff_details_view.dart';
import 'package:pos/features/manage_staff/presentation/pages/staff_edit_view.dart';
import 'package:pos/features/manage_staff/presentation/pages/staff_add_view.dart';
import 'package:pos/features/activity_logs/presentation/bindings/activity_logs_binding.dart';
import 'package:pos/features/activity_logs/presentation/pages/activity_logs_view.dart';
import 'package:pos/features/subscription/presentation/bindings/subscription_binding.dart';
import 'package:pos/features/subscription/presentation/pages/subscription_view.dart';
import 'package:pos/features/subscription/presentation/pages/subscription_history_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.CONNECTION_MODE,
      page: () => const ConnectionModeView(),
      binding: ConnectionModeBinding(),
    ),
    GetPage(
      name: _Paths.CLOUD_AUTH_PREVIEW,
      page: () => const CloudAuthPlaceholderView(),
    ),
    GetPage(
      name: _Paths.SCAN_SHOP,
      page: () => const ConnectShopView(),
      binding: ConnectShopBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => const SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: _Paths.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SALE,
      page: () => const SaleView(),
      binding: SaleBinding(),
    ),
    GetPage(
      name: _Paths.SALES,
      page: () => const SaleView(),
      binding: SaleBinding(),
    ),
    GetPage(
      name: _Paths.SALE_ADD,
      page: () => const SaleCreateView(),
      binding: SaleCreateBinding(),
    ),
    GetPage(
      name: _Paths.SALE_CHECKOUT,
      page: () => const SaleCheckoutView(),
      binding: SaleCreateBinding(),
    ),
    GetPage(
      name: _Paths.SALE_DETAILS,
      page: () => const SaleDetailsView(),
      binding: SaleDetailsBinding(),
    ),
    GetPage(
      name: _Paths.SALE_QR_SCANNER,
      page: () => const SalePosScannerView(),
      binding: SalePosScannerBinding(),
    ),

    GetPage(
      name: _Paths.CUSTOMER_ADD,
      page: () => const PermissionGate(
        permission: AppPermission.registerAndLookupCustomers,
        child: CustomerAddView(),
      ),
      binding: CustomerAddBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER_LIST,
      page: () => const PermissionGate(
        permission: AppPermission.registerAndLookupCustomers,
        child: CustomerListView(),
      ),
      binding: CustomerListBinding(),
      children: [
        GetPage(
          name: _Paths.CUSTOMER_DETAIL,
          page: () => const PermissionGate(
            permission: AppPermission.registerAndLookupCustomers,
            child: CustomerDetailView(),
          ),
          binding: CustomerDetailBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.CUSTOMER_EDIT,
      page: () => const PermissionGate(
        permission: AppPermission.manageCustomers,
        child: CustomerEditView(),
      ),
      binding: CustomerEditBinding(),
    ),
    GetPage(
      name: _Paths.SETTING,
      page: () => const PermissionGate(
        permission: AppPermission.manageShopSettings,
        child: SettingView(),
      ),
      binding: SettingBinding(),
    ),
    GetPage(
      name: _Paths.SALE_CATEGORY,
      page: () => const PermissionGate(
        permission: AppPermission.manageSalesCatalog,
        child: SaleCategoryListView(),
      ),
      binding: SaleCategoryListBinding(),
    ),
    GetPage(
      name: _Paths.SALE_SUB_CATEGORY,
      page: () => const PermissionGate(
        permission: AppPermission.manageSalesCatalog,
        child: SaleSubCategoryListView(),
      ),
      binding: SaleSubCategoryListBinding(),
    ),
    GetPage(
      name: _Paths.SALE_BRANDS,
      page: () => const PermissionGate(
        permission: AppPermission.manageSalesCatalog,
        child: SaleBrandListView(),
      ),
      binding: SaleBrandListBinding(),
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => const PermissionGate(
        permission: AppPermission.viewReports,
        child: ReportView(),
      ),
      binding: ReportBinding(),
    ),
    GetPage(
      name: _Paths.SHORTCUT,
      page: () => const ShortcutView(),
      binding: ShortcutBinding(),
    ),
    GetPage(
      name: _Paths.STAFF,
      page: () => const PermissionGate(
        permission: AppPermission.manageStaff,
        child: StaffView(),
      ),
      binding: StaffBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_DETAILS,
      page: () => const PermissionGate(
        permission: AppPermission.manageStaff,
        child: StaffDetailsView(),
      ),
      binding: StaffBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_EDIT,
      page: () => const PermissionGate(
        permission: AppPermission.manageStaff,
        child: StaffEditView(),
      ),
      binding: StaffBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_ADD,
      page: () => const PermissionGate(
        permission: AppPermission.manageStaff,
        child: StaffAddView(),
      ),
      binding: StaffBinding(),
    ),
    GetPage(
      name: _Paths.SALE_ITEM_LIST,
      page: () => const PermissionGate(
        permission: AppPermission.manageSalesCatalog,
        child: SaleItemListView(),
      ),
      binding: SaleItemListBinding(),
    ),
    GetPage(
      name: _Paths.SALE_ITEM_ADD,
      page: () => const PermissionGate(
        permission: AppPermission.manageSalesCatalog,
        child: SaleItemAddView(),
      ),
      binding: SaleItemAddBinding(),
    ),
    GetPage(
      name: _Paths.SALE_ITEM_EDIT,
      page: () => const PermissionGate(
        permission: AppPermission.manageSalesCatalog,
        child: SaleItemEditView(),
      ),
      binding: SaleItemEditBinding(),
    ),
    GetPage(
      name: _Paths.SALE_ITEM_DETAIL,
      page: () => const PermissionGate(
        permission: AppPermission.manageSalesCatalog,
        child: SaleItemDetailView(),
      ),
      binding: SaleItemDetailBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_INVOICE,
      page: () => const PaymentInvoiceView(),
      binding: PaymentInvoiceBinding(),
    ),
    GetPage(
      name: _Paths.GIFT_VOUCHER_LIST,
      page: () => const PermissionGate(
        permission: AppPermission.managePromotions,
        child: GiftVoucherListView(),
      ),
      binding: GiftVoucherBinding(),
    ),
    GetPage(
      name: _Paths.GIFT_VOUCHER_ADD,
      page: () => const PermissionGate(
        permission: AppPermission.managePromotions,
        child: GiftVoucherAddView(),
      ),
      binding: GiftVoucherBinding(),
    ),
    GetPage(
      name: _Paths.GIFT_VOUCHER_EDIT,
      page: () => const PermissionGate(
        permission: AppPermission.managePromotions,
        child: GiftVoucherEditView(),
      ),
      binding: GiftVoucherBinding(),
    ),
    GetPage(
      name: _Paths.GIFT_VOUCHER_DETAILS,
      page: () => const PermissionGate(
        permission: AppPermission.managePromotions,
        child: GiftVoucherDetailsView(),
      ),
      binding: GiftVoucherBinding(),
    ),
    GetPage(
      name: _Paths.PROMO_CODE_LIST,
      page: () => const PermissionGate(
        permission: AppPermission.managePromotions,
        child: PromoCodeListView(),
      ),
      binding: PromoCodeBinding(),
    ),
    GetPage(
      name: _Paths.PROMO_CODE_ADD,
      page: () => const PermissionGate(
        permission: AppPermission.managePromotions,
        child: PromoCodeAddView(),
      ),
      binding: PromoCodeBinding(),
    ),
    GetPage(
      name: _Paths.PROMO_CODE_EDIT,
      page: () => const PermissionGate(
        permission: AppPermission.managePromotions,
        child: PromoCodeEditView(),
      ),
      binding: PromoCodeBinding(),
    ),
    GetPage(
      name: _Paths.PROMO_CODE_DETAILS,
      page: () => const PermissionGate(
        permission: AppPermission.managePromotions,
        child: PromoCodeDetailsView(),
      ),
      binding: PromoCodeBinding(),
    ),
    GetPage(
      name: _Paths.GLOBAL_SCANNER,
      page: () => const GlobalQrScannerView(),
      binding: GlobalQrScannerBinding(),
    ),
    GetPage(
      name: _Paths.PDF_PREVIEW,
      page: () => const AppPdfViewerScreen(),
    ),
    GetPage(
      name: _Paths.ACTIVITY_LOGS,
      page: () => const PermissionGate(
        permission: AppPermission.viewAuditLogs,
        child: ActivityLogsView(),
      ),
      binding: ActivityLogsBinding(),
    ),
    GetPage(
      name: _Paths.SUBSCRIPTION,
      page: () => const PermissionGate(
        permission: AppPermission.viewSubscription,
        child: SubscriptionView(),
      ),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: _Paths.SUBSCRIPTION_HISTORY,
      page: () => const PermissionGate(
        permission: AppPermission.viewSubscription,
        child: SubscriptionHistoryView(),
      ),
      binding: SubscriptionBinding(),
    ),
  ];
}
