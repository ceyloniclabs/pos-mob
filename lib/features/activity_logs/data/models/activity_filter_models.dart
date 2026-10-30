import '../../domain/entities/activity_filter_options.dart';

class ActivityActionOptionModel extends ActivityActionOption {
  const ActivityActionOptionModel({
    required super.value,
    required super.label,
  });

  factory ActivityActionOptionModel.fromJson(Map<String, dynamic> json) {
    return ActivityActionOptionModel(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
      };
}

class ActivityStaffOptionModel extends ActivityStaffOption {
  const ActivityStaffOptionModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory ActivityStaffOptionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse(rawId?.toString() ?? '0') ?? 0);

    return ActivityStaffOptionModel(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };
}
