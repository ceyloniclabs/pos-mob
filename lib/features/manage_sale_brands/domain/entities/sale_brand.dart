class SaleBrand {
  final int id;
  final int saleCategoryId;
  final String name;
  final String? saleCategoryName;

  SaleBrand({
    required this.id,
    required this.saleCategoryId,
    required this.name,
    this.saleCategoryName,
  });

  SaleBrand copyWith({
    int? id,
    int? saleCategoryId,
    String? name,
    String? saleCategoryName,
  }) {
    return SaleBrand(
      id: id ?? this.id,
      saleCategoryId: saleCategoryId ?? this.saleCategoryId,
      name: name ?? this.name,
      saleCategoryName: saleCategoryName ?? this.saleCategoryName,
    );
  }
}
