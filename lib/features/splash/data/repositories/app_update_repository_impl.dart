import '../../domain/entities/app_version_info.dart';
import '../../domain/repositories/app_update_repository.dart';
import '../datasources/app_update_datasource.dart';

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  final AppUpdateDataSource _dataSource;

  AppUpdateRepositoryImpl(this._dataSource);

  @override
  Future<AppVersionInfo?> getLatestVersion() async {
    return await _dataSource.fetchAppVersion();
  }
}
