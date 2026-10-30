import '../validators/staff_validator.dart';

class Staff {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String? phoneNumber;
  final String? joinDate;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.phoneNumber,
    this.joinDate,
  }) {
    StaffValidator.validateNameOrThrow(name);
    StaffValidator.validateEmailOrThrow(email);
  }

  /// Compatibility getter for legacy references
  dynamic get uid => id;

  Staff copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
    String? phoneNumber,
    String? joinDate,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  @override
  String toString() {
    return 'Staff(id: $id, name: $name, email: $email, role: $role, isActive: $isActive, phoneNumber: $phoneNumber, joinDate: $joinDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Staff &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.isActive == isActive &&
        other.phoneNumber == phoneNumber &&
        other.joinDate == joinDate;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      role.hashCode ^
      isActive.hashCode ^
      phoneNumber.hashCode ^
      joinDate.hashCode;
}
