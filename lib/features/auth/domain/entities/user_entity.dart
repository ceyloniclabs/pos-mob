import 'package:pos/features/auth/domain/validators/auth_validator.dart';

class UserEntity {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
  }) {
    final emailError = AuthValidator.validateEmail(email);
    if (emailError != null) throw ArgumentError(emailError);

    final nameError = AuthValidator.validateName(name);
    if (nameError != null) throw ArgumentError(nameError);
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  // Legacy compatibility getter
  String get uid => id;
}
