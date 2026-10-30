import '../entities/operational_metrics.dart';

abstract class OperationalMetricsRepository {
  Future<OperationalMetrics> getOperationalMetrics({required int days});
}
