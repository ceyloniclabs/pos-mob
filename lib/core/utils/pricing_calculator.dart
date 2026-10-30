/// Abstract contract for rental pricing and late fee calculations.
abstract class PricingCalculator {
  /// Base unit minutes for a duration type.
  int getUnitMinutes(String? durationType);

  /// Calculates billable rental units when booking or creating a rental.
  int calculateRentalUnits({
    required DateTime start,
    required DateTime end,
    required String durationType,
    int gracePeriodMinutes = 0,
  });

  /// Calculates billable overdue units when returning a rental.
  int calculateOverdueUnits({
    required Duration overdueDuration,
    required String durationType,
    int gracePeriodMinutes = 0,
  });

  /// Calculates total late fee for an overdue return.
  double calculateLateFee({
    required Duration overdueDuration,
    required String durationType,
    int gracePeriodMinutes = 0,
    required double lateFeeRate,
  });
}
