import '../entities/activity_log_entity.dart';
import '../repositories/activity_log_repository.dart';

class GetRecentActivitiesUseCase {
  final ActivityLogRepository repository;

  GetRecentActivitiesUseCase(this.repository);

  Future<List<ActivityLogEntity>> execute({int limit = 5}) async {
    return await repository.getRecentActivities(limit: limit);
  }
}
