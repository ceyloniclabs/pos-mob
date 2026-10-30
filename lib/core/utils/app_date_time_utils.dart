import 'package:intl/intl.dart';

/// Centralized utility for bi-directional UTC and Local DateTime conversions.
///
/// Guidelines:
/// - All timestamps sent to the backend MUST be in UTC.
/// - All timestamps received from the backend ARE in UTC and MUST be parsed
///   as UTC before being converted to local time for display or calculations.
class AppDateTimeUtils {
  AppDateTimeUtils._();

  static final DateFormat _sqlDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _dateOnlyFormat = DateFormat('yyyy-MM-dd');

  /// Parses a server timestamp into a UTC [DateTime].
  ///
  /// Handles:
  /// - ISO 8601 with trailing 'Z' (e.g. `2026-10-12T14:30:00Z`)
  /// - ISO 8601 with explicit offset (e.g. `2026-10-12T14:30:00+00:00`)
  /// - SQL format without timezone (e.g. `2026-10-12 14:30:00`) - interpreted as UTC
  /// - Date only (e.g. `2026-10-12`) - interpreted as UTC midnight
  /// - Unix epoch timestamps (seconds or milliseconds)
  /// - Existing [DateTime] objects
  static DateTime? parseServerUtc(dynamic input) {
    if (input == null) return null;

    if (input is DateTime) {
      return input.isUtc ? input : input.toUtc();
    }

    if (input is int) {
      // If epoch is in seconds (< 10^11), multiply by 1000
      final millis = input < 100000000000 ? input * 1000 : input;
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    }

    final raw = input.toString().trim();
    if (raw.isEmpty) return null;

    // Case 1: Pure date 'YYYY-MM-DD'
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
      return DateTime.tryParse('${raw}T00:00:00Z')?.toUtc();
    }

    // Case 2: Explicit UTC 'Z' or ISO timezone offset after time
    final hasUtcZ = raw.endsWith('Z') || raw.endsWith('z');
    final hasOffset = RegExp(r'[T ]\d{2}:\d{2}(:\d{2}(\.\d+)?)?([+-]\d{2}:?\d{2})$').hasMatch(raw);

    if (hasUtcZ || hasOffset) {
      final parsed = DateTime.tryParse(raw);
      return parsed?.toUtc();
    }

    // Server returned a timestamp without timezone suffix (e.g. 'YYYY-MM-DD HH:mm:ss')
    // In Dart, DateTime.parse without Z assumes local time, so append 'Z' to force UTC interpretation.
    String normalized = raw;
    if (normalized.contains(' ')) {
      normalized = normalized.replaceFirst(' ', 'T');
    }
    if (!normalized.contains('T')) {
      // Pure date string 'YYYY-MM-DD'
      normalized = '${normalized}T00:00:00';
    }

    final parsedUtc = DateTime.tryParse('${normalized}Z');
    if (parsedUtc != null) {
      return parsedUtc.toUtc();
    }

    // Fallback if parsing with appended 'Z' failed
    final fallback = DateTime.tryParse(raw);
    return fallback?.toUtc();
  }

  /// Parses a server timestamp and returns it as device local [DateTime].
  static DateTime? toLocal(dynamic input) {
    final utc = parseServerUtc(input);
    return utc?.toLocal();
  }

  /// Alias for [toLocal].
  static DateTime? parseToLocal(dynamic input) => toLocal(input);

  /// Formats time in device local time (e.g. `02:30 PM`).
  static String formatTime(dynamic input, {String pattern = 'hh:mm a', String fallback = '---'}) {
    return formatLocal(input, pattern: pattern, fallback: fallback);
  }

  /// Formats a [DateTime] into an ISO-8601 UTC string (e.g. `2026-10-12T14:30:00.000Z`).
  /// Ideal for API request payloads.
  static String? toUtcIso(DateTime? date) {
    if (date == null) return null;
    return date.toUtc().toIso8601String();
  }

  /// Formats a [DateTime] into a SQL UTC string (`yyyy-MM-dd HH:mm:ss`).
  static String? toUtcSql(DateTime? date) {
    if (date == null) return null;
    return _sqlDateFormat.format(date.toUtc());
  }

  /// Formats a [DateTime] into a UTC date-only string (`yyyy-MM-dd`).
  static String? toUtcDateOnly(DateTime? date) {
    if (date == null) return null;
    return _dateOnlyFormat.format(date.toUtc());
  }

  /// Parses a server UTC timestamp and formats it into device local time string.
  static String formatLocal(
    dynamic input, {
    String pattern = 'yyyy-MM-dd HH:mm:ss',
    String fallback = '---',
  }) {
    final local = toLocal(input);
    if (local == null) return fallback;
    try {
      return DateFormat(pattern).format(local);
    } catch (_) {
      return local.toString();
    }
  }
}

/// Extension on [DateTime] for quick UTC formatting.
extension DateTimeUtcExt on DateTime {
  /// Converts this [DateTime] to a UTC ISO-8601 string.
  String toUtcIsoString() => AppDateTimeUtils.toUtcIso(this)!;

  /// Converts this [DateTime] to a UTC SQL string (`yyyy-MM-dd HH:mm:ss`).
  String toUtcSqlString() => AppDateTimeUtils.toUtcSql(this)!;

  /// Converts this [DateTime] to a UTC date-only string (`yyyy-MM-dd`).
  String toUtcDateOnlyString() => AppDateTimeUtils.toUtcDateOnly(this)!;
}

/// Extension on [String] for server UTC parsing.
extension StringUtcExt on String {
  /// Parses this string as a server UTC timestamp.
  DateTime? parseAsServerUtc() => AppDateTimeUtils.parseServerUtc(this);

  /// Parses this string as a server UTC timestamp and converts to device local time.
  DateTime? toLocalDateTime() => AppDateTimeUtils.toLocal(this);
}
