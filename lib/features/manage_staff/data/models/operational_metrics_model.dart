import '../../domain/entities/operational_metrics.dart';

class OperationalMetricsModel extends OperationalMetrics {
  const OperationalMetricsModel({
    required super.windowDays,
    required super.startDate,
    required super.endDate,
    required super.rentalsIssued,
    required super.salesHandled,
    required super.returnsProcessed,
    required super.damagesRecorded,
    required super.agreementsSigned,
    required super.returnRatePct,
  });

  factory OperationalMetricsModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, [int fallback = 0]) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    num parseNum(dynamic value, [num fallback = 0]) {
      if (value is num) return value;
      if (value is String) return num.tryParse(value) ?? fallback;
      return fallback;
    }

    return OperationalMetricsModel(
      windowDays: parseInt(json['window_days'], 7),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      rentalsIssued: parseInt(json['rentals_issued']),
      salesHandled: parseInt(json['sales_handled']),
      returnsProcessed: parseInt(json['returns_processed']),
      damagesRecorded: parseInt(json['damages_recorded']),
      agreementsSigned: parseInt(json['agreements_signed']),
      returnRatePct: parseNum(json['return_rate_pct']),
    );
  }

  Map<String, dynamic> toJson() => {
        'window_days': windowDays,
        'start_date': startDate,
        'end_date': endDate,
        'rentals_issued': rentalsIssued,
        'sales_handled': salesHandled,
        'returns_processed': returnsProcessed,
        'damages_recorded': damagesRecorded,
        'agreements_signed': agreementsSigned,
        'return_rate_pct': returnRatePct,
      };
}
