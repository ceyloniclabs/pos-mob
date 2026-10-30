class SaleCategoryValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Sale category name is required';
    }
    return null;
  }

  static String? validateDescription(String? description) {
    return null;
  }
}
