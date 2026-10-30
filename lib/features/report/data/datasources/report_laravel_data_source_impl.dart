import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/network/api_service.dart';
import 'package:pos/core/utils/app_date_time_utils.dart';

import 'report_data_source.dart';

class ReportLaravelDataSourceImpl implements ReportDataSource {
  final ApiService apiService;

  ReportLaravelDataSourceImpl({required this.apiService});

  Map<String, dynamic> _cleanQueryParams(Map<String, dynamic> raw) {
    final cleaned = <String, dynamic>{};
    raw.forEach((key, value) {
      if (value == null) return;
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty || trimmed.toLowerCase() == 'all') return;
        cleaned[key] = trimmed;
        return;
      }
      cleaned[key] = value;
    });
    return cleaned;
  }

  Future<File> _downloadReport(
    String endpoint,
    String defaultFilename,
    Map<String, dynamic> queryParams,
  ) async {
    final dir = await getTemporaryDirectory();
    final uniquePrefix = DateTime.now().millisecondsSinceEpoch;
    final savePath = '${dir.path}/${uniquePrefix}_$defaultFilename';

    await apiService.downloadRequest(
      endpoint,
      savePath,
      queryParameters: queryParams,
    );

    final file = File(savePath);
    if (!await file.exists() || await file.length() == 0) {
      throw Exception('Downloaded report file was not found or is empty.');
    }
    return file;
  }

  @override
  Future<File> getCustomerListReport({
    String? search,
    String? customerType,
  }) async {
    final queryParams = _cleanQueryParams({
      'search': search,
      'customer_type': customerType,
    });
    return _downloadReport(
      EndPoints.customerListReport,
      'customer_list.pdf',
      queryParams,
    );
  }

  @override
  Future<File> getSalesInventoryReport({
    String? category,
    String? brand,
    String? stockStatus,
  }) {
    final queryParams = _cleanQueryParams({
      'category': category,
      'brand': brand,
      'stock_status': stockStatus,
    });
    return _downloadReport(
      EndPoints.salesInventoryReport,
      'sales_inventory_report.pdf',
      queryParams,
    );
  }

  @override
  Future<File> getSalesReport({
    String? saleStatus,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final queryParams = _cleanQueryParams({
      'sale_status': saleStatus,
      'date_from': AppDateTimeUtils.toUtcDateOnly(fromDate),
      'date_to': AppDateTimeUtils.toUtcDateOnly(toDate),
    });
    return _downloadReport(
      EndPoints.salesReport,
      'sales_report.pdf',
      queryParams,
    );
  }
}
