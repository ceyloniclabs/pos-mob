class PhotoModel {
  final int id;
  final String photoUrl;
  final int isPrimary;

  PhotoModel({
    required this.id,
    required this.photoUrl,
    required this.isPrimary,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
        id: json['id'],
        photoUrl: json['photo_url'] ?? '',
        isPrimary: json['is_primary'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'photo_url': photoUrl,
        'is_primary': isPrimary,
      };
}
