import 'package:pos/features/home/domain/entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<DashboardEntity> getAdminStats();
  Future<DashboardEntity> getStaffStats();
}
