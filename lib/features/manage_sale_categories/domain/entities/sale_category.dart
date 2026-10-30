import '../validators/sale_category_validator.dart';

class SaleCategory {
  final int id;
  final String name;
  final String description;

  SaleCategory({
    required this.id,
    required this.name,
    required this.description,
  }) {
    final nameError = SaleCategoryValidator.validateName(name);
    if (nameError != null) throw ArgumentError(nameError);

    final descError = SaleCategoryValidator.validateDescription(description);
    if (descError != null) throw ArgumentError(descError);
  }

  SaleCategory copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return SaleCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
