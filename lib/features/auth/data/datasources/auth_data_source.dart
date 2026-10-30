import 'package:pos/features/auth/data/models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(String name, String email, String password);
  Future<bool> signOut();
  Future<UserModel?> getCurrentUser(String userId);
}
