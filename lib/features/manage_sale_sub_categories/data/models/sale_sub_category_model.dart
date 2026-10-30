import '../../domain/entities/sale_sub_category.dart';
import 'package:pos/features/manage_sale_categories/data/models/sale_category_model.dart';
import 'package:pos/features/manage_sale_categories/domain/entities/sale_category.dart';

class SaleSubCategoryModel extends SaleSubCategory {
  SaleSubCategoryModel({
    required super.id,
    required super.saleCategoryId,
    required super.name,
    super.description = '',
    super.saleCategory,
  });

  factory SaleSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SaleSubCategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      saleCategoryId: json['sale_category_id'] is int
          ? json['sale_category_id']
          : int.tryParse(json['sale_category_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      saleCategory: json['sale_category'] != null
          ? SaleCategoryModel.fromJson(json['sale_category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'sale_category_id': saleCategoryId,
        'name': name,
        'description': description,
        if (saleCategory != null && saleCategory is SaleCategoryModel)
          'sale_category': (saleCategory as SaleCategoryModel).toJson(),
      };

  SaleSubCategory toEntity() {
    return SaleSubCategory(
      id: id,
      saleCategoryId: saleCategoryId,
      name: name,
      description: description,
      saleCategory: saleCategory,
    );
  }

  factory SaleSubCategoryModel.fromEntity(SaleSubCategory entity) {
    return SaleSubCategoryModel(
      id: entity.id,
      saleCategoryId: entity.saleCategoryId,
      name: entity.name,
      description: entity.description,
      saleCategory: entity.saleCategory != null
          ? (entity.saleCategory is SaleCategoryModel
              ? entity.saleCategory as SaleCategoryModel
              : SaleCategoryModel.fromEntity(entity.saleCategory!))
          : null,
    );
  }

  @override
  SaleSubCategoryModel copyWith({
    int? id,
    int? saleCategoryId,
    String? name,
    String? description,
    SaleCategory? saleCategory,
  }) {
    return SaleSubCategoryModel(
      id: id ?? this.id,
      saleCategoryId: saleCategoryId ?? this.saleCategoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      saleCategory: saleCategory != null
          ? (saleCategory is SaleCategoryModel
              ? saleCategory
              : SaleCategoryModel.fromEntity(saleCategory))
          : (this.saleCategory != null ? this.saleCategory as SaleCategoryModel : null),
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleSubCategoryModel &&
        other.id == id &&
        other.saleCategoryId == saleCategoryId &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      saleCategoryId.hashCode ^
      name.hashCode ^
      description.hashCode;
}
