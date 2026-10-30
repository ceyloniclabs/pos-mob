import 'dart:io';

import '../repositories/report_repository.dart';

class GetCustomerListReportUseCase {
  final ReportRepository repository;

  GetCustomerListReportUseCase(this.repository);

  Future<File> execute({String? search, String? customerType}) {
    return repository.getCustomerListReport(
      search: search,
      customerType: customerType,
    );
  }
}
