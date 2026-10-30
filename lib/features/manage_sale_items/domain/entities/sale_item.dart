import '../validators/sale_item_validator.dart';

class SaleItem {
  final int id;
  final int brandId;
  final int categoryId;
  final int? subcategoryId;
  final String name;
  final String? description;
  final double buyingPrice;
  final double sellingPrice;
  final int stockQuantity;
  final bool isActive;
  final String? brandName;
  final String? categoryName;
  final String? subcategoryName;
  final List<String> photos;

  SaleItem({
    required this.id,
    required this.brandId,
    required this.categoryId,
    this.subcategoryId,
    required this.name,
    this.description,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.isActive,
    this.brandName,
    this.categoryName,
    this.subcategoryName,
    required this.photos,
  }) {
    final nameError = SaleItemValidator.validateName(name);
    if (nameError != null) throw ArgumentError(nameError);

    final categoryError = SaleItemValidator.validateCategoryId(categoryId);
    if (categoryError != null) throw ArgumentError(categoryError);

    final brandError = SaleItemValidator.validateBrandId(brandId);
    if (brandError != null) throw ArgumentError(brandError);
  }

  SaleItem copyWith({
    int? id,
    int? brandId,
    int? categoryId,
    int? subcategoryId,
    String? name,
    String? description,
    double? buyingPrice,
    double? sellingPrice,
    int? stockQuantity,
    bool? isActive,
    String? brandName,
    String? categoryName,
    String? subcategoryName,
    List<String>? photos,
  }) {
    return SaleItem(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
      brandName: brandName ?? this.brandName,
      categoryName: categoryName ?? this.categoryName,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      photos: photos ?? this.photos,
    );
  }
}
