class ReportFilter {
  final String? search;
  final String? customerType;
  final String? rentalStatus;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? saleStatus;
  final String? category;
  final String? brand;
  final String? stockStatus;
  final String? resolutionStatus;

  const ReportFilter({
    this.search,
    this.customerType,
    this.rentalStatus,
    this.fromDate,
    this.toDate,
    this.saleStatus,
    this.category,
    this.brand,
    this.stockStatus,
    this.resolutionStatus,
  });

  ReportFilter copyWith({
    String? search,
    String? customerType,
    String? rentalStatus,
    DateTime? fromDate,
    DateTime? toDate,
    String? saleStatus,
    String? category,
    String? brand,
    String? stockStatus,
    String? resolutionStatus,
  }) {
    return ReportFilter(
      search: search ?? this.search,
      customerType: customerType ?? this.customerType,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      saleStatus: saleStatus ?? this.saleStatus,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      stockStatus: stockStatus ?? this.stockStatus,
      resolutionStatus: resolutionStatus ?? this.resolutionStatus,
    );
  }
}
