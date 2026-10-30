class PromoCodeValidator {
  static String? validateCode(String? code) {
    if (code == null || code.trim().isEmpty) {
      return 'Promo code is required';
    }
    if (code.trim().length < 2) {
      return 'Promo code must be at least 2 characters';
    }
    return null;
  }

  static String? validateReferral(String? referral) {
    if (referral == null || referral.trim().isEmpty) {
      return 'Referral / partner name is required';
    }
    if (referral.trim().length < 2) {
      return 'Referral name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePercentage(String? value, {String fieldName = 'Percentage'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < 0 || parsed > 100) {
      return '$fieldName must be between 0 and 100';
    }
    return null;
  }

  static String? validateExpireDate(DateTime? date) {
    if (date == null) {
      return 'Expire date is required';
    }
    return null;
  }
}
