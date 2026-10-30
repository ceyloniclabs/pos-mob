import '../entities/activity_filter_params.dart';
import '../entities/activity_logs_result.dart';
import '../repositories/activity_log_repository.dart';

class GetActivityLogsUseCase {
  final ActivityLogRepository repository;

  GetActivityLogsUseCase(this.repository);

  Future<ActivityLogsResult> execute(ActivityFilterParams params) async {
    return await repository.getActivityLogs(params);
  }
}
