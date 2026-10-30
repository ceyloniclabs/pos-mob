import '../validators/sale_sub_category_validator.dart';
import 'package:pos/features/manage_sale_categories/domain/entities/sale_category.dart';

class SaleSubCategory {
  final int id;
  final int saleCategoryId;
  final String name;
  final String description;
  final SaleCategory? saleCategory;

  SaleSubCategory({
    required this.id,
    required this.saleCategoryId,
    required this.name,
    required this.description,
    this.saleCategory,
  }) {
    final nameError = SaleSubCategoryValidator.validateName(name);
    if (nameError != null) throw ArgumentError(nameError);

    final catError = SaleSubCategoryValidator.validateSaleCategoryId(saleCategoryId);
    if (catError != null) throw ArgumentError(catError);

    final descError = SaleSubCategoryValidator.validateDescription(description);
    if (descError != null) throw ArgumentError(descError);
  }

  SaleSubCategory copyWith({
    int? id,
    int? saleCategoryId,
    String? name,
    String? description,
    SaleCategory? saleCategory,
  }) {
    return SaleSubCategory(
      id: id ?? this.id,
      saleCategoryId: saleCategoryId ?? this.saleCategoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      saleCategory: saleCategory ?? this.saleCategory,
    );
  }
}
