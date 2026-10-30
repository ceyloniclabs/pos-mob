import 'package:pos/core/utils/app_date_time_utils.dart';
import '../../domain/entities/staff.dart';

class StaffModel extends Staff {
  StaffModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.isActive = true,
    super.phoneNumber,
    super.joinDate,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['uid'];
    final id =
        rawId is int ? rawId : (int.tryParse(rawId?.toString() ?? '0') ?? 0);

    final isActiveRaw = json['is_active'] ?? json['isActive'];
    final isActive = isActiveRaw is bool
        ? isActiveRaw
        : (isActiveRaw != null
            ? (isActiveRaw.toString().toLowerCase() == 'true' ||
                isActiveRaw == 1 ||
                isActiveRaw == '1')
            : true);

    return StaffModel(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isActive: isActive,
      phoneNumber: json['phone_number']?.toString(),
      joinDate: () {
        final explicit = (json['join_date'] ?? json['joinDate'])?.toString();
        if (explicit != null && explicit.isNotEmpty) return explicit;
        final fallback = json['created_at'] ?? json['createdAt'];
        if (fallback == null) return null;
        final formatted = AppDateTimeUtils.formatLocal(
          fallback,
          pattern: 'yyyy-MM-dd',
          fallback: '',
        );
        return formatted.isEmpty ? null : formatted;
      }(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'is_active': isActive,
        'phone_number': phoneNumber,
        'join_date': joinDate,
      };

  Staff toEntity() {
    return Staff(
      id: id,
      name: name,
      email: email,
      role: role,
      isActive: isActive,
      phoneNumber: phoneNumber,
      joinDate: joinDate,
    );
  }

  factory StaffModel.fromEntity(Staff entity) {
    return StaffModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      isActive: entity.isActive,
      phoneNumber: entity.phoneNumber,
      joinDate: entity.joinDate,
    );
  }

  @override
  StaffModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
    String? phoneNumber,
    String? joinDate,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}
