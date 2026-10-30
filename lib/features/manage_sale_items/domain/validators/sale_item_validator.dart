import '../../../../core/utils/input_validators.dart';

class SaleItemValidator {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return AppInputValidator.validateText(value, 'Name');
  }

  static String? validateBuyingPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Buying price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null || price < 0) {
      return 'Invalid buying price';
    }
    return null;
  }

  static String? validateSellingPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selling price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null || price < 0) {
      return 'Invalid selling price';
    }
    return null;
  }

  static String? validateStockQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stock quantity is required';
    }
    final qty = int.tryParse(value.trim());
    if (qty == null || qty < 0) {
      return 'Invalid stock quantity';
    }
    return null;
  }

  static String? validateCategoryId(int? categoryId) {
    if (categoryId == null || categoryId <= 0) {
      return 'Category is required';
    }
    return null;
  }

  static String? validateBrandId(int? brandId) {
    if (brandId == null || brandId <= 0) {
      return 'Brand is required';
    }
    return null;
  }
}
