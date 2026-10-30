import 'package:get/get.dart';

import '../../../../core/utils/scaffold_message_utils.dart';
import '../../../activity_logs/data/datasources/activity_log_remote_data_source_impl.dart';
import '../../../activity_logs/data/repositories/activity_log_repository_impl.dart';
import '../../../activity_logs/domain/entities/activity_log_entity.dart';
import '../../../activity_logs/domain/usecases/get_recent_activities_use_case.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';

class HomeController extends GetxController {
  final GetDashboardStatsUseCase _getDashboardStatsUseCase;
  final GetRecentActivitiesUseCase? _getRecentActivitiesUseCase;

  HomeController(
    this._getDashboardStatsUseCase, {
    this._getRecentActivitiesUseCase,
  });

  final RxBool isLoading = true.obs;
  final Rxn<DashboardEntity> dashboardData = Rxn<DashboardEntity>();
  final RxnString errorMessage = RxnString();

  final RxList<ActivityLogEntity> recentLogs = <ActivityLogEntity>[].obs;
  final RxBool isLoadingRecentLogs = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await _getDashboardStatsUseCase.execute();
      dashboardData.value = result;

      // For admin user, fetch the top 5 activity logs
      final role = AuthController.to.user.value?.role;
      if (role == 'admin') {
        fetchRecentActivityLogs();
      }
    } catch (e) {
      errorMessage.value =
          'Unable to load dashboard data. Please check your network connection and try again.';
      if (dashboardData.value != null) {
        ScaffoldMessageUtils.showError('Unable to refresh dashboard');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecentActivityLogs() async {
    try {
      isLoadingRecentLogs.value = true;
      final useCase = _getRecentActivitiesUseCase ??
          GetRecentActivitiesUseCase(
            ActivityLogRepositoryImpl(
              ActivityLogRemoteDataSourceImpl(),
            ),
          );
      final logs = await useCase.execute(limit: 5);
      recentLogs.assignAll(logs);
    } catch (_) {
      // Soft fail, recent logs are supplementary
    } finally {
      isLoadingRecentLogs.value = false;
    }
  }
}
