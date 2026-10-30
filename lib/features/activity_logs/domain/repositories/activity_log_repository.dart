import '../entities/activity_filter_params.dart';
import '../entities/activity_log_entity.dart';
import '../entities/activity_logs_result.dart';

abstract class ActivityLogRepository {
  Future<ActivityLogsResult> getActivityLogs(ActivityFilterParams params);
  Future<List<ActivityLogEntity>> getRecentActivities({int limit = 5});
}
