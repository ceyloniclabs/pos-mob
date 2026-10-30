import 'dart:io';

abstract class ReportRepository {
  Future<File> getCustomerListReport({
    String? search,
    String? customerType,
  });

  Future<File> getSalesReport({
    String? saleStatus,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<File> getSalesInventoryReport({
    String? category,
    String? brand,
    String? stockStatus,
  });
}
