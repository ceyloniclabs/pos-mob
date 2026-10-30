import 'package:get/get.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/features/auth/data/datasources/auth_data_source.dart';
import 'auth_firebase_data_source_impl.dart';
import 'auth_laravel_data_source_impl.dart';

class AuthDataSourceFactory {
  static AuthDataSource create(BackendProviderType type,
      {ApiService? apiService}) {
    switch (type) {
      case BackendProviderType.firebase:
        return AuthFirebaseDataSourceImpl();
      case BackendProviderType.laravel:
        return AuthLaravelDataSourceImpl(apiService ?? Get.find<ApiService>());
    }
  }
}
