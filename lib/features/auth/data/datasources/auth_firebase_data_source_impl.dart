import 'package:pos/features/auth/data/models/user_model.dart';
import 'package:pos/features/auth/data/datasources/auth_data_source.dart';

class AuthFirebaseDataSourceImpl implements AuthDataSource {
  @override
  Future<UserModel?> signIn(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> signUp(String name, String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<bool> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> getCurrentUser(String userId) {
    throw UnimplementedError();
  }
}
