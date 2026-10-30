class OperationalMetrics {
  final int windowDays;
  final String startDate;
  final String endDate;
  final int rentalsIssued;
  final int salesHandled;
  final int returnsProcessed;
  final int damagesRecorded;
  final int agreementsSigned;
  final num returnRatePct;

  const OperationalMetrics({
    required this.windowDays,
    required this.startDate,
    required this.endDate,
    required this.rentalsIssued,
    required this.salesHandled,
    required this.returnsProcessed,
    required this.damagesRecorded,
    required this.agreementsSigned,
    required this.returnRatePct,
  });

  OperationalMetrics copyWith({
    int? windowDays,
    String? startDate,
    String? endDate,
    int? rentalsIssued,
    int? salesHandled,
    int? returnsProcessed,
    int? damagesRecorded,
    int? agreementsSigned,
    num? returnRatePct,
  }) {
    return OperationalMetrics(
      windowDays: windowDays ?? this.windowDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rentalsIssued: rentalsIssued ?? this.rentalsIssued,
      salesHandled: salesHandled ?? this.salesHandled,
      returnsProcessed: returnsProcessed ?? this.returnsProcessed,
      damagesRecorded: damagesRecorded ?? this.damagesRecorded,
      agreementsSigned: agreementsSigned ?? this.agreementsSigned,
      returnRatePct: returnRatePct ?? this.returnRatePct,
    );
  }
}
