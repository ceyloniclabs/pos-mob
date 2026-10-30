import 'package:get/get.dart';

import 'package:pos/features/activity_logs/data/datasources/activity_log_data_source.dart';
import 'package:pos/features/activity_logs/data/datasources/activity_log_remote_data_source_impl.dart';
import 'package:pos/features/activity_logs/data/repositories/activity_log_repository_impl.dart';
import 'package:pos/features/activity_logs/domain/repositories/activity_log_repository.dart';
import 'package:pos/features/activity_logs/domain/usecases/get_recent_activities_use_case.dart';
import 'package:pos/features/home/data/datasources/dashboard_data_source.dart';
import 'package:pos/features/home/data/datasources/dashboard_remote_data_source_impl.dart';
import 'package:pos/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:pos/features/home/domain/repositories/dashboard_repository.dart';
import 'package:pos/features/home/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:pos/features/home/presentation/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardDataSource>(() => DashboardRemoteDataSourceImpl());
    Get.lazyPut<DashboardRepository>(() => DashboardRepositoryImpl(Get.find()));
    Get.lazyPut<GetDashboardStatsUseCase>(() => GetDashboardStatsUseCase(Get.find()));

    Get.lazyPut<ActivityLogDataSource>(() => ActivityLogRemoteDataSourceImpl());
    Get.lazyPut<ActivityLogRepository>(() => ActivityLogRepositoryImpl(Get.find<ActivityLogDataSource>()));
    Get.lazyPut<GetRecentActivitiesUseCase>(() => GetRecentActivitiesUseCase(Get.find<ActivityLogRepository>()));

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<GetDashboardStatsUseCase>(),
        getRecentActivitiesUseCase: Get.find<GetRecentActivitiesUseCase>(),
      ),
    );
  }
}
