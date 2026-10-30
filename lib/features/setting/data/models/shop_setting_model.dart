import '../../domain/entities/shop_setting.dart';

class ShopSettingModel extends ShopSetting {
  const ShopSettingModel({
    required super.shopName,
    required super.shopEmail,
    required super.shopContact,
    required super.shopLocation,
    required super.privacyPolicy,
    required super.termsConditions,
    required super.currency,
    required super.timezone,
    required super.dateFormat,
    required super.maxGraceHourly,
    required super.maxGraceDaily,
    required super.maxGraceWeekly,
    required super.maxGraceMonthly,
    super.defaultLateFeeRate = 100.0,
    super.allowLateReturns = true,
    super.taxRate = 0.0,
  });

  factory ShopSettingModel.fromJson(Map<String, dynamic> json) {
    return ShopSettingModel(
      shopName: json['shop_name']?.toString() ?? '',
      shopEmail: json['shop_email']?.toString() ?? '',
      shopContact: json['shop_contact']?.toString() ?? '',
      shopLocation: json['shop_location']?.toString() ?? '',
      privacyPolicy: json['privacy_policy']?.toString() ?? '',
      termsConditions: json['terms_conditions']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'LKR',
      timezone: json['timezone']?.toString() ?? 'Asia/Colombo',
      dateFormat: json['date_format']?.toString() ?? '',
      maxGraceHourly: json['max_grace_period_hourly']?.toString() ?? '30',
      maxGraceDaily: json['max_grace_period_daily']?.toString() ?? '0',
      maxGraceWeekly: json['max_grace_period_weekly']?.toString() ?? '0',
      maxGraceMonthly: json['max_grace_period_monthly']?.toString() ?? '0',
      defaultLateFeeRate:
          double.tryParse(json['default_late_fee_rate']?.toString() ?? '') ??
              100.0,
      allowLateReturns: json['allow_late_returns'] == true ||
          json['allow_late_returns'] == 1 ||
          json['allow_late_returns'] == 'true',
      taxRate: double.tryParse(json['tax_rate']?.toString() ?? '') ?? 0.0,
    );
  }

  factory ShopSettingModel.fromEntity(ShopSetting entity) {
    return ShopSettingModel(
      shopName: entity.shopName,
      shopEmail: entity.shopEmail,
      shopContact: entity.shopContact,
      shopLocation: entity.shopLocation,
      privacyPolicy: entity.privacyPolicy,
      termsConditions: entity.termsConditions,
      currency: entity.currency,
      timezone: entity.timezone,
      dateFormat: entity.dateFormat,
      maxGraceHourly: entity.maxGraceHourly,
      maxGraceDaily: entity.maxGraceDaily,
      maxGraceWeekly: entity.maxGraceWeekly,
      maxGraceMonthly: entity.maxGraceMonthly,
      defaultLateFeeRate: entity.defaultLateFeeRate,
      allowLateReturns: entity.allowLateReturns,
      taxRate: entity.taxRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_name': shopName,
      'shop_email': shopEmail,
      'shop_location': shopLocation,
      'shop_contact': shopContact,
      'privacy_policy': privacyPolicy,
      'terms_conditions': termsConditions,
      'currency': currency,
      'timezone': timezone,
      'date_format': dateFormat,
      'max_grace_period_hourly': maxGraceHourly,
      'max_grace_period_daily': maxGraceDaily,
      'max_grace_period_weekly': maxGraceWeekly,
      'max_grace_period_monthly': maxGraceMonthly,
      'default_late_fee_rate': defaultLateFeeRate,
      'allow_late_returns': allowLateReturns,
      'tax_rate': taxRate,
    };
  }

  ShopSetting toEntity() => this;
}
