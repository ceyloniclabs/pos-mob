// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AppUser {
  final dynamic uid;
  final String email;
  final String name;
  final String role;
  final bool isActive;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] == true,
    );
  }
}
