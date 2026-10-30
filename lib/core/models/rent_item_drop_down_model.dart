class RentItemDropDownModel {
  final int id;
  final String name;

  RentItemDropDownModel({
    required this.id,
    required this.name,
  });

  factory RentItemDropDownModel.fromJson(Map<String, dynamic> json) =>
      RentItemDropDownModel(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RentItemDropDownModel &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
