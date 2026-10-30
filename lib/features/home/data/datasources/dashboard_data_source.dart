abstract class DashboardDataSource {
  Future<Map<String, dynamic>> getAdminStats();
  Future<Map<String, dynamic>> getStaffStats();
}
