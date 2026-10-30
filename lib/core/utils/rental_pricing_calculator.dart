import 'package:pos/core/utils/duration_type_registry.dart';
import 'package:pos/core/utils/pricing_calculator.dart';

/// Concrete implementation of [PricingCalculator] supporting strategy-based duration types (OCP & DIP).
class RentalPricingCalculatorImpl implements PricingCalculator {
  final DurationTypeRegistry _registry;

  RentalPricingCalculatorImpl({DurationTypeRegistry? registry})
      : _registry = registry ?? DurationTypeRegistry.defaultRegistry;

  @override
  int getUnitMinutes(String? durationType) {
    return _registry.resolve(durationType).unitMinutes;
  }

  @override
  int calculateRentalUnits({
    required DateTime start,
    required DateTime end,
    required String durationType,
    int gracePeriodMinutes = 0,
  }) {
    final duration = end.difference(start);
    if (duration <= Duration.zero) return 0;

    final int totalSeconds = duration.inSeconds;
    final int unitSeconds = getUnitMinutes(durationType) * 60;
    final int gracePeriodSeconds = gracePeriodMinutes * 60;

    final int fullUnits = totalSeconds ~/ unitSeconds;
    final int extraSeconds = totalSeconds % unitSeconds;

    if (extraSeconds == 0) {
      return fullUnits;
    }

    if (extraSeconds <= gracePeriodSeconds) {
      return fullUnits > 0 ? fullUnits : 1;
    }

    return fullUnits + 1;
  }

  @override
  int calculateOverdueUnits({
    required Duration overdueDuration,
    required String durationType,
    int gracePeriodMinutes = 0,
  }) {
    if (overdueDuration <= Duration.zero) return 0;

    final int totalSeconds = overdueDuration.inSeconds;
    final int unitSeconds = getUnitMinutes(durationType) * 60;
    final int gracePeriodSeconds = gracePeriodMinutes * 60;

    final int fullUnits = totalSeconds ~/ unitSeconds;
    final int extraSeconds = totalSeconds % unitSeconds;

    if (extraSeconds <= gracePeriodSeconds) {
      return fullUnits;
    }

    return fullUnits + 1;
  }

  @override
  double calculateLateFee({
    required Duration overdueDuration,
    required String durationType,
    int gracePeriodMinutes = 0,
    required double lateFeeRate,
  }) {
    final int units = calculateOverdueUnits(
      overdueDuration: overdueDuration,
      durationType: durationType,
      gracePeriodMinutes: gracePeriodMinutes,
    );
    return units * lateFeeRate;
  }
}

/// Static facade for [RentalPricingCalculatorImpl] maintaining backward compatibility.
class RentalPricingCalculator {
  /// Configurable [PricingCalculator] instance (e.g., for testing or DI).
  static PricingCalculator instance = RentalPricingCalculatorImpl();

  /// Returns the base unit duration in minutes for a given duration type.
  static int getUnitMinutes(String? durationType) {
    return instance.getUnitMinutes(durationType);
  }

  /// Calculates billable rental units when booking or creating a rental.
  static int calculateRentalUnits({
    required DateTime start,
    required DateTime end,
    required String durationType,
    int gracePeriodMinutes = 0,
  }) {
    return instance.calculateRentalUnits(
      start: start,
      end: end,
      durationType: durationType,
      gracePeriodMinutes: gracePeriodMinutes,
    );
  }

  /// Calculates billable overdue units when returning a rental.
  static int calculateOverdueUnits({
    required Duration overdueDuration,
    required String durationType,
    int gracePeriodMinutes = 0,
  }) {
    return instance.calculateOverdueUnits(
      overdueDuration: overdueDuration,
      durationType: durationType,
      gracePeriodMinutes: gracePeriodMinutes,
    );
  }

  /// Calculates total late fee for an overdue return.
  static double calculateLateFee({
    required Duration overdueDuration,
    required String durationType,
    int gracePeriodMinutes = 0,
    required double lateFeeRate,
  }) {
    return instance.calculateLateFee(
      overdueDuration: overdueDuration,
      durationType: durationType,
      gracePeriodMinutes: gracePeriodMinutes,
      lateFeeRate: lateFeeRate,
    );
  }
}
