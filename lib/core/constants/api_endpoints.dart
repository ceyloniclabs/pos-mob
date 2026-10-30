import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndPoints {
  static String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'https://surfdesk-api.ceyloniclabs.com/api/';

  // Dashboards & Analytics
  static const String adminDashboard = 'dashboard/admin-stats';
  static const String staffDashboard = 'dashboard/staff-stats';
  static const String operationalMetrics = 'dashboard/operational-metrics';

  // Auth & Users
  static const String signIn = 'login';
  static const String signUp = 'register';
  static const String logout = 'logout';
  static const String user = 'users';
  static const String uploadPhoto = 'upload/profile-photo';

  // Sales & Catalog
  static const String sales = 'sales';
  static const String saleItems = 'sale-items';
  static const String saleCategories = 'salecategories';
  static const String saleSubCategories = 'salesubcategories';
  static const String brands = 'brands';
  static const String size = 'sizes';
  static const String color = 'colors';

  // Customers & Promotions
  static const String customer = 'customers';
  static const String giftVouchers = 'gift-vouchers';
  static const String promoCodes = 'promo-codes';

  // Settings & System
  static const String shopSettings = 'shop-settings';
  static const String activityLogs = 'activity-logs';
  static const String currentSubscription = 'subscriptions/current';
  static const String subscriptionHistory = 'subscriptions/history';

  // Reports
  static const String customerListReport = 'reports/customer-list';
  static const String salesReport = 'reports/sales';
  static const String salesInventoryReport = 'reports/sales-inventory';
}
