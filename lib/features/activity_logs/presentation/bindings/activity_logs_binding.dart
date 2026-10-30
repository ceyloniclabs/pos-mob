import 'package:get/get.dart';

import '../../data/datasources/activity_log_data_source.dart';
import '../../data/datasources/activity_log_remote_data_source_impl.dart';
import '../../data/repositories/activity_log_repository_impl.dart';
import '../../domain/repositories/activity_log_repository.dart';
import '../../domain/usecases/get_activity_logs_use_case.dart';
import '../controllers/activity_logs_controller.dart';

class ActivityLogsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivityLogDataSource>(
      () => ActivityLogRemoteDataSourceImpl(),
    );
    Get.lazyPut<ActivityLogRepository>(
      () => ActivityLogRepositoryImpl(Get.find<ActivityLogDataSource>()),
    );
    Get.lazyPut<GetActivityLogsUseCase>(
      () => GetActivityLogsUseCase(Get.find<ActivityLogRepository>()),
    );
    Get.lazyPut<ActivityLogsController>(
      () => ActivityLogsController(
        getActivityLogsUseCase: Get.find<GetActivityLogsUseCase>(),
      ),
    );
  }
}
