import '../entities/app_version_info.dart';
import '../repositories/app_update_repository.dart';

class CheckAppUpdateUseCase {
  final AppUpdateRepository _repository;

  CheckAppUpdateUseCase(this._repository);

  Future<AppVersionInfo?> execute() async {
    return await _repository.getLatestVersion();
  }
}
