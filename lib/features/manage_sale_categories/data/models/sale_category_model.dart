import '../../domain/entities/sale_category.dart';

class SaleCategoryModel extends SaleCategory {
  SaleCategoryModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory SaleCategoryModel.fromJson(Map<String, dynamic> json) {
    return SaleCategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
      };

  SaleCategory toEntity() {
    return SaleCategory(
      id: id,
      name: name,
      description: description,
    );
  }

  factory SaleCategoryModel.fromEntity(SaleCategory entity) {
    return SaleCategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
    );
  }

  @override
  SaleCategoryModel copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return SaleCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SaleCategoryModel &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;
}
