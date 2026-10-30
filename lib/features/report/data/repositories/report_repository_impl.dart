import 'dart:io';

import '../../domain/repositories/report_repository.dart';
import '../datasources/report_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportDataSource dataSource;

  ReportRepositoryImpl(this.dataSource);

  @override
  Future<File> getCustomerListReport({
    String? search,
    String? customerType,
  }) {
    return dataSource.getCustomerListReport(
      search: search,
      customerType: customerType,
    );
  }

  @override
  Future<File> getSalesInventoryReport({
    String? category,
    String? brand,
    String? stockStatus,
  }) {
    return dataSource.getSalesInventoryReport(
      category: category,
      brand: brand,
      stockStatus: stockStatus,
    );
  }

  @override
  Future<File> getSalesReport({
    String? saleStatus,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return dataSource.getSalesReport(
      saleStatus: saleStatus,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
