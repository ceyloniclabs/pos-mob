class GiftVoucherValidator {
  static String? validateCode(String? code) {
    if (code == null || code.trim().isEmpty) {
      return 'Voucher code is required';
    }
    if (code.trim().length < 2) {
      return 'Voucher code must be at least 2 characters';
    }
    return null;
  }

  static String? validateOwner(String? owner) {
    if (owner == null || owner.trim().isEmpty) {
      return 'Owner / recipient name is required';
    }
    if (owner.trim().length < 2) {
      return 'Owner name must be at least 2 characters';
    }
    return null;
  }

  static String? validateInitialAmount(String? amount) {
    if (amount == null || amount.trim().isEmpty) {
      return 'Initial amount is required';
    }
    final parsed = double.tryParse(amount.trim());
    if (parsed == null) {
      return 'Enter a valid amount';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than zero';
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
