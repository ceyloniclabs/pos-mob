import '../../domain/entities/operational_metrics.dart';
import '../../domain/repositories/operational_metrics_repository.dart';
import '../datasources/operational_metrics_data_source.dart';

class OperationalMetricsRepositoryImpl implements OperationalMetricsRepository {
  final OperationalMetricsDataSource dataSource;

  OperationalMetricsRepositoryImpl(this.dataSource);

  @override
  Future<OperationalMetrics> getOperationalMetrics({required int days}) async {
    return await dataSource.getOperationalMetrics(days: days);
  }
}
