/// Strategy interface for duration types conforming to Open/Closed Principle (OCP).
abstract class DurationTypeStrategy {
  int get unitMinutes;
  String get key;
  List<String> get aliases => const [];
}

class HourlyDuration implements DurationTypeStrategy {
  @override
  int get unitMinutes => 60;

  @override
  String get key => 'hourly';

  @override
  List<String> get aliases => const ['hour', 'hr'];
}

class DailyDuration implements DurationTypeStrategy {
  @override
  int get unitMinutes => 1440; // 24 * 60

  @override
  String get key => 'daily';

  @override
  List<String> get aliases => const ['day'];
}

class WeeklyDuration implements DurationTypeStrategy {
  @override
  int get unitMinutes => 10080; // 7 * 24 * 60

  @override
  String get key => 'weekly';

  @override
  List<String> get aliases => const ['week', 'wk'];
}

class MonthlyDuration implements DurationTypeStrategy {
  @override
  int get unitMinutes => 43200; // 30 * 24 * 60

  @override
  String get key => 'monthly';

  @override
  List<String> get aliases => const ['month', 'mo'];
}

/// Registry that resolves strategies without modifying existing calculator logic.
class DurationTypeRegistry {
  final Map<String, DurationTypeStrategy> _strategies = {};
  DurationTypeStrategy _defaultStrategy = HourlyDuration();

  static final DurationTypeRegistry defaultRegistry = DurationTypeRegistry();

  DurationTypeRegistry({List<DurationTypeStrategy>? initialStrategies}) {
    final strategies = initialStrategies ??
        [
          HourlyDuration(),
          DailyDuration(),
          WeeklyDuration(),
          MonthlyDuration(),
        ];
    for (final strategy in strategies) {
      register(strategy);
    }
  }

  void register(DurationTypeStrategy strategy, {bool isDefault = false}) {
    _strategies[strategy.key.toLowerCase()] = strategy;
    for (final alias in strategy.aliases) {
      _strategies[alias.toLowerCase()] = strategy;
    }
    if (isDefault) {
      _defaultStrategy = strategy;
    }
  }

  DurationTypeStrategy resolve(String? durationType) {
    if (durationType == null) return _defaultStrategy;
    return _strategies[durationType.toLowerCase().trim()] ?? _defaultStrategy;
  }
}
