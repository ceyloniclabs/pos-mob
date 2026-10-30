import '../../domain/entities/activity_filter_params.dart';
import '../models/activity_logs_response_model.dart';

abstract class ActivityLogDataSource {
  Future<ActivityLogsResponseModel> getActivityLogs(ActivityFilterParams params);
}
