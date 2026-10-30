import 'package:pos/features/auth/domain/entities/user_entity.dart';
import 'package:pos/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this.repository);

  final AuthRepository repository;

  Future<UserEntity?> execute(String name, String email, String password) {
    return repository.signUp(name, email, password);
  }
}
