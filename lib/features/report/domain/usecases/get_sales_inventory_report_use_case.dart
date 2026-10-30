import 'dart:io';

import '../repositories/report_repository.dart';

class GetSalesInventoryReportUseCase {
  final ReportRepository repository;

  GetSalesInventoryReportUseCase(this.repository);

  Future<File> execute({
    String? category,
    String? brand,
    String? stockStatus,
  }) {
    return repository.getSalesInventoryReport(
      category: category,
      brand: brand,
      stockStatus: stockStatus,
    );
  }
}
