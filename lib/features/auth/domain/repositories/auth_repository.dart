import 'package:pos/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signIn(String email, String password);
  Future<UserEntity?> signUp(String name, String email, String password);
  Future<bool> signOut();
  Future<UserEntity?> getCurrentUser();
}
