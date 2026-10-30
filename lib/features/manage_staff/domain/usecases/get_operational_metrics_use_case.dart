import '../entities/operational_metrics.dart';
import '../repositories/operational_metrics_repository.dart';

class GetOperationalMetricsUseCase {
  final OperationalMetricsRepository repository;

  GetOperationalMetricsUseCase(this.repository);

  Future<OperationalMetrics> execute({required int days}) async {
    return await repository.getOperationalMetrics(days: days);
  }
}
