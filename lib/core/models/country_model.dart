class CountryModel {
  final int id;
  final String name;
  final String isoCode;

  CountryModel({
    required this.id,
    required this.name,
    required this.isoCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json['id'],
        name: json['name'],
        isoCode: json['iso_code'],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'iso_code': isoCode,
      };

  @override
  String toString() => name;
}
