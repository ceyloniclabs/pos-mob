/// Pure domain entity representing shop settings.
class ShopSetting {
  final String shopName;
  final String shopEmail;
  final String shopContact;
  final String shopLocation;
  final String privacyPolicy;
  final String termsConditions;
  final String currency;
  final String timezone;
  final String dateFormat;
  final String maxGraceHourly;
  final String maxGraceDaily;
  final String maxGraceWeekly;
  final String maxGraceMonthly;
  final double defaultLateFeeRate;
  final bool allowLateReturns;
  final double taxRate;

  const ShopSetting({
    required this.shopName,
    required this.shopEmail,
    required this.shopContact,
    required this.shopLocation,
    required this.privacyPolicy,
    required this.termsConditions,
    required this.currency,
    required this.timezone,
    required this.dateFormat,
    required this.maxGraceHourly,
    required this.maxGraceDaily,
    required this.maxGraceWeekly,
    required this.maxGraceMonthly,
    this.defaultLateFeeRate = 100.0,
    this.allowLateReturns = true,
    this.taxRate = 0.0,
  });

  ShopSetting copyWith({
    String? shopName,
    String? shopEmail,
    String? shopContact,
    String? shopLocation,
    String? privacyPolicy,
    String? termsConditions,
    String? currency,
    String? timezone,
    String? dateFormat,
    String? maxGraceHourly,
    String? maxGraceDaily,
    String? maxGraceWeekly,
    String? maxGraceMonthly,
    double? defaultLateFeeRate,
    bool? allowLateReturns,
    double? taxRate,
  }) {
    return ShopSetting(
      shopName: shopName ?? this.shopName,
      shopEmail: shopEmail ?? this.shopEmail,
      shopContact: shopContact ?? this.shopContact,
      shopLocation: shopLocation ?? this.shopLocation,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      termsConditions: termsConditions ?? this.termsConditions,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      dateFormat: dateFormat ?? this.dateFormat,
      maxGraceHourly: maxGraceHourly ?? this.maxGraceHourly,
      maxGraceDaily: maxGraceDaily ?? this.maxGraceDaily,
      maxGraceWeekly: maxGraceWeekly ?? this.maxGraceWeekly,
      maxGraceMonthly: maxGraceMonthly ?? this.maxGraceMonthly,
      defaultLateFeeRate: defaultLateFeeRate ?? this.defaultLateFeeRate,
      allowLateReturns: allowLateReturns ?? this.allowLateReturns,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}
