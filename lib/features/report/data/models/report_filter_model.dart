import 'package:pos/core/utils/app_date_time_utils.dart';
import '../../domain/entities/report_filter.dart';

class ReportFilterModel extends ReportFilter {
  const ReportFilterModel({
    super.search,
    super.customerType,
    super.rentalStatus,
    super.fromDate,
    super.toDate,
    super.saleStatus,
    super.category,
    super.brand,
    super.stockStatus,
    super.resolutionStatus,
  });

  factory ReportFilterModel.fromEntity(ReportFilter filter) {
    return ReportFilterModel(
      search: filter.search,
      customerType: filter.customerType,
      rentalStatus: filter.rentalStatus,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
      saleStatus: filter.saleStatus,
      category: filter.category,
      brand: filter.brand,
      stockStatus: filter.stockStatus,
      resolutionStatus: filter.resolutionStatus,
    );
  }

  Map<String, dynamic> toCustomerListQueryParams() {
    return _cleanQueryParams({
      'search': search,
      'customer_type': customerType,
    });
  }

  Map<String, dynamic> toRentalQueryParams() {
    return _cleanQueryParams({
      'rental_status': rentalStatus,
      'date_from': AppDateTimeUtils.toUtcDateOnly(fromDate),
      'date_to': AppDateTimeUtils.toUtcDateOnly(toDate),
    });
  }

  Map<String, dynamic> toSalesQueryParams() {
    return _cleanQueryParams({
      'sale_status': saleStatus,
      'date_from': AppDateTimeUtils.toUtcDateOnly(fromDate),
      'date_to': AppDateTimeUtils.toUtcDateOnly(toDate),
    });
  }

  Map<String, dynamic> toSalesInventoryQueryParams() {
    return _cleanQueryParams({
      'category': category,
      'brand': brand,
      'stock_status': stockStatus,
    });
  }

  Map<String, dynamic> toDamageQueryParams() {
    return _cleanQueryParams({
      'resolution_status': resolutionStatus,
      'date_from': AppDateTimeUtils.toUtcDateOnly(fromDate),
      'date_to': AppDateTimeUtils.toUtcDateOnly(toDate),
    });
  }

  static Map<String, dynamic> _cleanQueryParams(Map<String, dynamic> queryParams) {
    final cleaned = <String, dynamic>{};
    queryParams.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is String && value.toLowerCase() == 'all') return;
      cleaned[key] = value;
    });
    return cleaned;
  }
}
