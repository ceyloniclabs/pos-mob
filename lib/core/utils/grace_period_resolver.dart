import 'package:pos/features/setting/domain/entities/shop_setting.dart';

/// Resolves grace period in minutes based on rental entry, shop settings, or defaults.
class GracePeriodResolver {
  static int resolveMinutes({
    int? entryGracePeriod,
    String? durationType,
    ShopSetting? shopSetting,
  }) {
    return resolve(
      capturedGracePeriod: entryGracePeriod,
      settings: shopSetting,
      durationType: durationType ?? 'hourly',
    );
  }

  static int resolve({
    required int? capturedGracePeriod,
    required ShopSetting? settings,
    required String durationType,
  }) {
    // 1. If entry has captured grace period, use it directly (in minutes)
    if (capturedGracePeriod != null) {
      return capturedGracePeriod;
    }

    final normalized = durationType.toLowerCase().trim();

    // 2. Fall back to Shop Settings
    if (settings != null) {
      switch (normalized) {
        case 'hourly':
        case 'hour':
        case 'hr':
          return int.tryParse(settings.maxGraceHourly) ?? 30;
        case 'daily':
        case 'day':
          return int.tryParse(settings.maxGraceDaily) ?? 0;
        case 'weekly':
        case 'week':
        case 'wk':
          return int.tryParse(settings.maxGraceWeekly) ?? 0;
        case 'monthly':
        case 'month':
        case 'mo':
          return int.tryParse(settings.maxGraceMonthly) ?? 0;
        default:
          return int.tryParse(settings.maxGraceHourly) ?? 30;
      }
    }

    // 3. Fallback defaults
    switch (normalized) {
      case 'hourly':
      case 'hour':
      case 'hr':
        return 30;
      default:
        return 0;
    }
  }
}
