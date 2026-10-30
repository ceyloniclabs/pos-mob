import 'dart:io';

import '../repositories/report_repository.dart';

class GetSalesReportUseCase {
  final ReportRepository repository;

  GetSalesReportUseCase(this.repository);

  Future<File> execute({
    String? saleStatus,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return repository.getSalesReport(
      saleStatus: saleStatus,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
