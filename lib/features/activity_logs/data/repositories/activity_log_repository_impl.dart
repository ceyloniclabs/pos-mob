import '../../domain/entities/activity_filter_params.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../domain/entities/activity_logs_result.dart';
import '../../domain/repositories/activity_log_repository.dart';
import '../datasources/activity_log_data_source.dart';

class ActivityLogRepositoryImpl implements ActivityLogRepository {
  final ActivityLogDataSource remoteDataSource;

  ActivityLogRepositoryImpl(this.remoteDataSource);

  @override
  Future<ActivityLogsResult> getActivityLogs(ActivityFilterParams params) async {
    return await remoteDataSource.getActivityLogs(params);
  }

  @override
  Future<List<ActivityLogEntity>> getRecentActivities({int limit = 5}) async {
    final response = await remoteDataSource.getActivityLogs(
      ActivityFilterParams(page: 1, perPage: limit),
    );
    return response.logs.take(limit).toList();
  }
}
