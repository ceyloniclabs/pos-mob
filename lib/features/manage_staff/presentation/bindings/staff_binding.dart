import 'package:get/get.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/features/activity_logs/data/datasources/activity_log_data_source.dart';
import 'package:pos/features/activity_logs/data/datasources/activity_log_remote_data_source_impl.dart';
import 'package:pos/features/activity_logs/data/repositories/activity_log_repository_impl.dart';
import 'package:pos/features/activity_logs/domain/repositories/activity_log_repository.dart';
import 'package:pos/features/activity_logs/domain/usecases/get_activity_logs_use_case.dart';

import '../../data/datasources/operational_metrics_data_source.dart';
import '../../data/datasources/staff_data_source.dart';
import '../../data/datasources/staff_data_source_factory.dart';
import '../../data/repositories/operational_metrics_repository_impl.dart';
import '../../data/repositories/staff_repository_impl.dart';
import '../../domain/repositories/operational_metrics_repository.dart';
import '../../domain/repositories/staff_repository.dart';
import '../../domain/usecases/create_staff_use_case.dart';
import '../../domain/usecases/delete_staff_use_case.dart';
import '../../domain/usecases/get_operational_metrics_use_case.dart';
import '../../domain/usecases/get_staff_by_id_use_case.dart';
import '../../domain/usecases/get_staff_use_case.dart';
import '../../domain/usecases/update_staff_status_use_case.dart';
import '../../domain/usecases/update_staff_use_case.dart';
import '../controllers/staff_controller.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    // Layer 1: Data Sources
    Get.lazyPut<StaffDataSource>(
      () => StaffDataSourceFactory.create(
        Get.find<AppConfigController>().currentBackend.value,
      ),
    );

    Get.lazyPut<OperationalMetricsDataSource>(
      () => OperationalMetricsRemoteDataSourceImpl(),
    );

    if (!Get.isRegistered<ActivityLogDataSource>()) {
      Get.lazyPut<ActivityLogDataSource>(
        () => ActivityLogRemoteDataSourceImpl(),
      );
    }

    // Layer 2: Repositories
    Get.lazyPut<StaffRepository>(
      () => StaffRepositoryImpl(Get.find<StaffDataSource>()),
    );

    Get.lazyPut<OperationalMetricsRepository>(
      () => OperationalMetricsRepositoryImpl(Get.find<OperationalMetricsDataSource>()),
    );

    if (!Get.isRegistered<ActivityLogRepository>()) {
      Get.lazyPut<ActivityLogRepository>(
        () => ActivityLogRepositoryImpl(Get.find<ActivityLogDataSource>()),
      );
    }

    // Layer 3: Use Cases
    Get.lazyPut<GetStaffUseCase>(
      () => GetStaffUseCase(Get.find<StaffRepository>()),
    );
    Get.lazyPut<GetStaffByIdUseCase>(
      () => GetStaffByIdUseCase(Get.find<StaffRepository>()),
    );
    Get.lazyPut<CreateStaffUseCase>(
      () => CreateStaffUseCase(Get.find<StaffRepository>()),
    );
    Get.lazyPut<UpdateStaffUseCase>(
      () => UpdateStaffUseCase(Get.find<StaffRepository>()),
    );
    Get.lazyPut<DeleteStaffUseCase>(
      () => DeleteStaffUseCase(Get.find<StaffRepository>()),
    );
    Get.lazyPut<UpdateStaffStatusUseCase>(
      () => UpdateStaffStatusUseCase(Get.find<StaffRepository>()),
    );
    Get.lazyPut<GetOperationalMetricsUseCase>(
      () => GetOperationalMetricsUseCase(Get.find<OperationalMetricsRepository>()),
    );

    if (!Get.isRegistered<GetActivityLogsUseCase>()) {
      Get.lazyPut<GetActivityLogsUseCase>(
        () => GetActivityLogsUseCase(Get.find<ActivityLogRepository>()),
      );
    }

    // Layer 4: Controller
    Get.lazyPut<StaffController>(
      () => StaffController(
        getStaffUseCase: Get.find<GetStaffUseCase>(),
        getStaffByIdUseCase: Get.find<GetStaffByIdUseCase>(),
        createStaffUseCase: Get.find<CreateStaffUseCase>(),
        updateStaffUseCase: Get.find<UpdateStaffUseCase>(),
        deleteStaffUseCase: Get.find<DeleteStaffUseCase>(),
        updateStaffStatusUseCase: Get.find<UpdateStaffStatusUseCase>(),
        getOperationalMetricsUseCase: Get.find<GetOperationalMetricsUseCase>(),
        getActivityLogsUseCase: Get.find<GetActivityLogsUseCase>(),
      ),
    );
  }
}
