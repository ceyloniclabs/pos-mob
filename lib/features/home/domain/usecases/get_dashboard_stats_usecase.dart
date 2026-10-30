import 'package:pos/features/home/domain/entities/dashboard_entity.dart';
import 'package:pos/features/home/domain/repositories/dashboard_repository.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<DashboardEntity> execute() async {
    final role = AuthController.to.user.value?.role;
    if (role == 'admin') {
      return await repository.getAdminStats();
    } else {
      return await repository.getStaffStats();
    }
  }
}
