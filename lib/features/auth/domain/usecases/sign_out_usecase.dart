import 'package:pos/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this.repository);

  final AuthRepository repository;

  Future<bool> execute() {
    return repository.signOut();
  }
}
