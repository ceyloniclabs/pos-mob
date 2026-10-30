class ReportValidator {
  static String? validateDateRange(DateTime? fromDate, DateTime? toDate) {
    if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
      return 'Date from cannot be after date to.';
    }
    return null;
  }
}
