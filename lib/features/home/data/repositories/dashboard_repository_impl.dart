import 'package:pos/features/home/domain/entities/dashboard_entity.dart';
import 'package:pos/features/home/domain/repositories/dashboard_repository.dart';
import 'package:pos/features/home/data/datasources/dashboard_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? (double.tryParse(value)?.toInt() ?? 0);
    }
    if (value is Map) {
      final nested = value['count'] ?? value['total'] ?? value['value'];
      return _safeInt(nested);
    }
    return 0;
  }

  @override
  Future<DashboardEntity> getAdminStats() async {
    final data = await remoteDataSource.getAdminStats();

    final rentals = data['rentals'] is Map ? data['rentals'] : {};
    final sales = data['sales'] is Map ? data['sales'] : {};
    final customers = data['customers'] is Map ? data['customers'] : {};
    final recentRentals = (data['recent_rentals'] as List?) ?? [];

    final recentActivity = recentRentals.map((e) => ActivityEntity(
      title: 'Rental - ${e['customer_name']}',
      time: e['created_at'].toString(),
      iconType: 'rental',
    )).toList();

    return DashboardEntity(
      activeRentals: _safeInt(rentals['active']),
      todaysSales: _safeInt(sales['today']),
      customers: _safeInt(customers['total']),
      overdueRentals: _safeInt(rentals['overdue']),
      recentActivity: recentActivity,
    );
  }

  @override
  Future<DashboardEntity> getStaffStats() async {
    final data = await remoteDataSource.getStaffStats();

    final global = data['global'] is Map ? data['global'] : {};
    final mySales = data['my_sales'] is Map ? data['my_sales'] : {};
    final recentRentals = (data['recent_rentals'] as List?) ?? [];

    final recentActivity = recentRentals.map((e) => ActivityEntity(
      title: 'Rental - ${e['customer_name']}',
      time: e['created_at'].toString(),
      iconType: 'rental',
    )).toList();

    return DashboardEntity(
      activeRentals: _safeInt(global['active_rentals']),
      todaysSales: _safeInt(mySales['today']),
      customers: 0, // Staff dashboard might not have total customers
      overdueRentals: _safeInt(global['overdue_rentals']),
      recentActivity: recentActivity,
    );
  }
}
