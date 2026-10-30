import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/features/auth/data/datasources/auth_data_source.dart';
import 'package:pos/features/auth/data/datasources/auth_data_source_factory.dart';
import 'package:pos/features/auth/domain/entities/user_entity.dart';
import 'package:pos/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource? _injectedDataSource;

  AuthRepositoryImpl([this._injectedDataSource]);

  AuthDataSource get _dataSource {
    if (_injectedDataSource != null) return _injectedDataSource;
    if (Get.isRegistered<AppConfigController>()) {
      return AuthDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      );
    }
    return AuthDataSourceFactory.create(BackendProviderType.laravel);
  }

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    final user = await _dataSource.signIn(email, password);
    if (user != null) {
      await _persistSession(user.toJson());
    }
    return user;
  }

  @override
  Future<UserEntity?> signUp(String name, String email, String password) async {
    final user = await _dataSource.signUp(name, email, password);
    if (user != null) {
      await _persistSession(user.toJson());
    }
    return user;
  }

  @override
  Future<bool> signOut() async {
    try {
      await _dataSource.signOut();
    } catch (_) {
      // Continue with local session cleanup even if remote call fails
    }
    await _clearSession();
    return true;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userJson = GetStorage().read('user');
    if (userJson != null) {
      final userId = userJson['id']?.toString();
      if (userId != null && userId.isNotEmpty) {
        return await _dataSource.getCurrentUser(userId);
      }
    }
    return null;
  }

  Future<void> _persistSession(Map<String, dynamic> userData) async {
    await GetStorage().write('user', userData);
  }

  Future<void> _clearSession() async {
    await GetStorage().remove('token');
    await GetStorage().remove('user');
  }
}
