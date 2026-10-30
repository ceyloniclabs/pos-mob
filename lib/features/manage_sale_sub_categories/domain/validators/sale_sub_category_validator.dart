class SaleSubCategoryValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Sale sub category name is required';
    }
    return null;
  }

  static String? validateSaleCategoryId(int? categoryId) {
    if (categoryId == null || categoryId <= 0) {
      return 'Please select a sale category';
    }
    return null;
  }

  static String? validateCategory(dynamic category) {
    if (category == null) {
      return 'Please select a parent sale category';
    }
    return null;
  }

  static String? validateDescription(String? description) {
    return null;
  }
}
