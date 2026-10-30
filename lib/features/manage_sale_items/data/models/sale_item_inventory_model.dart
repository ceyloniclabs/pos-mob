import '../../domain/entities/sale_item.dart';

class SaleItemInventoryModel extends SaleItem {
  SaleItemInventoryModel({
    required super.id,
    required super.brandId,
    required super.categoryId,
    super.subcategoryId,
    required super.name,
    super.description,
    required super.buyingPrice,
    required super.sellingPrice,
    required super.stockQuantity,
    required super.isActive,
    super.brandName,
    super.categoryName,
    super.subcategoryName,
    required super.photos,
  });

  factory SaleItemInventoryModel.fromJson(Map<String, dynamic> json) {
    return SaleItemInventoryModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      brandId: int.tryParse(json['brand_id']?.toString() ?? '0') ?? 0,
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      subcategoryId: json['subcategory_id'] != null
          ? int.tryParse(json['subcategory_id'].toString())
          : null,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      buyingPrice: double.tryParse(json['buying_price']?.toString() ?? '0') ?? 0.0,
      sellingPrice: double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0.0,
      stockQuantity: int.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true ||
          json['is_active'] == '1' ||
          json['is_active'] == 1,
      brandName: json['brand_name']?.toString(),
      categoryName: json['category_name']?.toString(),
      subcategoryName: json['subcategory_name']?.toString(),
      photos: json['photos'] != null && json['photos'] is List
          ? (json['photos'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'brand_id': brandId,
        'category_id': categoryId,
        'subcategory_id': subcategoryId ?? '',
        'name': name,
        'description': description ?? '',
        'buying_price': buyingPrice,
        'selling_price': sellingPrice,
        'stock_quantity': stockQuantity,
        'is_active': isActive ? 1 : 0,
        'brand_name': brandName,
        'category_name': categoryName,
        'subcategory_name': subcategoryName,
        'photos': photos,
      };

  SaleItem toEntity() {
    return SaleItem(
      id: id,
      brandId: brandId,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      name: name,
      description: description,
      buyingPrice: buyingPrice,
      sellingPrice: sellingPrice,
      stockQuantity: stockQuantity,
      isActive: isActive,
      brandName: brandName,
      categoryName: categoryName,
      subcategoryName: subcategoryName,
      photos: photos,
    );
  }

  factory SaleItemInventoryModel.fromEntity(SaleItem entity) {
    return SaleItemInventoryModel(
      id: entity.id,
      brandId: entity.brandId,
      categoryId: entity.categoryId,
      subcategoryId: entity.subcategoryId,
      name: entity.name,
      description: entity.description,
      buyingPrice: entity.buyingPrice,
      sellingPrice: entity.sellingPrice,
      stockQuantity: entity.stockQuantity,
      isActive: entity.isActive,
      brandName: entity.brandName,
      categoryName: entity.categoryName,
      subcategoryName: entity.subcategoryName,
      photos: entity.photos,
    );
  }
}
