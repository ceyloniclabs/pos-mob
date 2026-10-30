import '../../domain/entities/sale_brand.dart';

class SaleBrandModel extends SaleBrand {
  SaleBrandModel({
    required super.id,
    required super.saleCategoryId,
    required super.name,
    super.saleCategoryName,
  });

  factory SaleBrandModel.fromJson(Map<String, dynamic> json) {
    return SaleBrandModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      saleCategoryId: json['sale_category_id'] is int
          ? json['sale_category_id']
          : int.tryParse(json['sale_category_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      saleCategoryName: json['sale_category_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'sale_category_id': saleCategoryId,
        'name': name,
        'sale_category_name': saleCategoryName,
      };

  SaleBrand toEntity() {
    return SaleBrand(
      id: id,
      saleCategoryId: saleCategoryId,
      name: name,
      saleCategoryName: saleCategoryName,
    );
  }

  factory SaleBrandModel.fromEntity(SaleBrand entity) {
    return SaleBrandModel(
      id: entity.id,
      saleCategoryId: entity.saleCategoryId,
      name: entity.name,
      saleCategoryName: entity.saleCategoryName,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleBrandModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
