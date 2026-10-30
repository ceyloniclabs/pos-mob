import 'package:pos/features/auth/domain/entities/user_entity.dart';
import 'package:pos/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this.repository);

  final AuthRepository repository;

  Future<UserEntity?> execute() {
    return repository.getCurrentUser();
  }
}
