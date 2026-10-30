import 'dart:async';
import 'package:pos/core/utils/duration_formatter.dart';

/// Service that handles periodic countdown or elapsed timer updates for rentals.
class RentalTimerService {
  Timer? _timer;

  /// Starts a 1-second interval timer that counts down until [dueTime],
  /// and once passed [dueTime], tracks elapsed overdue time.
  /// On each tick, [onTick] is called with (isOverdue, duration, formatted).
  void startTracking({
    required DateTime? dueTime,
    required void Function(bool isOverdue, Duration duration, String formatted) onTick,
  }) {
    stop();
    if (dueTime == null) {
      onTick(false, Duration.zero, '00:00:00');
      return;
    }

    final due = dueTime.isUtc ? dueTime.toLocal() : dueTime;

    // Immediate first tick
    final initialNow = DateTime.now();
    final bool initialOverdue = initialNow.isAfter(due);
    final initialDiff = initialOverdue
        ? initialNow.difference(due)
        : due.difference(initialNow);
    onTick(initialOverdue, initialDiff, DurationFormatter.format(initialDiff));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final bool isOverdue = now.isAfter(due);
      final diff = isOverdue ? now.difference(due) : due.difference(now);
      onTick(isOverdue, diff, DurationFormatter.format(diff));
    });
  }

  /// Starts a 1-second interval timer that counts down until [dueTime].
  /// On each tick, [onTick] is called with the remaining duration and its formatted representation.
  void startCountdown({
    required DateTime? dueTime,
    required void Function(Duration remaining, String formatted) onTick,
  }) {
    stop();
    if (dueTime == null) {
      onTick(Duration.zero, '00:00:00');
      return;
    }

    final due = dueTime.isUtc ? dueTime.toLocal() : dueTime;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (now.isBefore(due)) {
        final diff = due.difference(now);
        onTick(diff, DurationFormatter.format(diff));
      } else {
        onTick(Duration.zero, '00:00:00');
      }
    });
  }

  /// Cancels any active timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Alias for stop to clean up resources when disposing controllers/services.
  void dispose() {
    stop();
  }
}
