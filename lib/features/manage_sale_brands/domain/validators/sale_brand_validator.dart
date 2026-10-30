class SaleBrandValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Brand name is required';
    }
    return null;
  }

  static String? validateCategory(dynamic category) {
    if (category == null) {
      return 'Please select a sale category';
    }
    return null;
  }
}
