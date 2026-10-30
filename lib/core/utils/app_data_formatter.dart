import 'dart:developer';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app_date_time_utils.dart';
import 'package:pos/core/controllers/persistent_data_controller.dart';

class AppDataFormatter {
  static String formatDate(DateTime? date, {String? sdate}) {
    if (date != null) {
      final local = date.isUtc ? date.toLocal() : date;
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(local);
    } else if (sdate != null) {
      final local = AppDateTimeUtils.toLocal(sdate);
      if (local != null) {
        return DateFormat('yyyy-MM-dd').format(local);
      }
      return 'Invalid date';
    } else {
      return 'No date provided';
    }
  }

  static String? formatDateTime(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    final local = AppDateTimeUtils.toLocal(input);
    if (local == null) return null;
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(local);
  }

  static String formatCurrency(dynamic amount, {String? customCurrency, int decimalDigits = 2}) {
    if (amount == null) return '';
    final double? parsed = amount is num
        ? amount.toDouble()
        : double.tryParse(amount.toString().replaceAll(',', '').trim());
    if (parsed == null) return amount.toString();

    String curr = customCurrency ?? '';
    if (curr.isEmpty) {
      if (Get.isRegistered<PersistentDataController>()) {
        curr = PersistentDataController.to.currency;
      }
    }
    if (curr.isEmpty) {
      curr = 'USD';
    }

    final formattedNum = parsed.toStringAsFixed(decimalDigits);
    return '$curr $formattedNum';
  }

  static String formatPhoneNumber(String phonenumber) {
    if (phonenumber.length == 10) {
      return '(${phonenumber.substring(0, 3)}) ${phonenumber.substring(3, 6)} ${phonenumber.substring(6)}';
    } else if (phonenumber.length == 11) {
      return '(${phonenumber.substring(0, 4)}) ${phonenumber.substring(4, 7)} ${phonenumber.substring(7)}';
    }
    return phonenumber;
  }

  static String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  static Color colorFromString(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String greeting() {
    var hour = DateTime.now().hour;
    if (hour <= 12) {
      return 'good_morning'.tr;
    } else if ((hour > 12) && (hour <= 16)) {
      return 'good_afternoon'.tr;
    } else if ((hour > 16) && (hour < 20)) {
      return 'good_evening'.tr;
    } else {
      return 'good_night'.tr;
    }
  }

  static String timeAgo(String isoTimestamp, {String locale = 'en'}) {
    try {
      final dateTime = AppDateTimeUtils.toLocal(isoTimestamp);
      if (dateTime == null) return 'Invalid date';
      String result = timeago.format(
        dateTime,
        locale: locale,
        allowFromNow: true,
      );
      log("Formatted time ago: $result");
      return result;
    } catch (e) {
      return 'Invalid date';
    }
  }

  static String customTimeAgo(String isoTimestamp) {
    try {
      final dateTime = AppDateTimeUtils.toLocal(isoTimestamp);
      if (dateTime == null) return 'Invalid date';
      final now = DateTime.now();
      final isPast = now.isAfter(dateTime);
      final diff = isPast ? now.difference(dateTime) : dateTime.difference(now);

      String suffix = isPast ? 'ago' : 'from now';
      String result;

      if (diff.inSeconds < 60) {
        result = 'just now';
      } else if (diff.inMinutes < 60) {
        result =
            '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} $suffix';
      } else if (diff.inHours < 24) {
        result = '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} $suffix';
      } else if (diff.inDays < 7) {
        result = '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} $suffix';
      } else if (diff.inDays < 30) {
        int weeks = (diff.inDays / 7).floor();
        result = '$weeks week${weeks == 1 ? '' : 's'} $suffix';
      } else if (diff.inDays < 365) {
        int months = (diff.inDays / 30).floor();
        result = '$months month${months == 1 ? '' : 's'} $suffix';
      } else {
        int years = (diff.inDays / 365).floor();
        result = '$years year${years == 1 ? '' : 's'} $suffix';
      }

      log("Formatted custom time ago: $result");
      return result;
    } catch (e) {
      log("TimeAgo error: $e");
      return 'Invalid date';
    }
  }

  static String formatGMTTimeToLocal(String rawDate) {
    final dateTime = AppDateTimeUtils.toLocal(rawDate);
    if (dateTime == null) return 'Invalid date';
    return DateFormat('M/d/yyyy, h:mm:ss a').format(dateTime);
  }

  static String formatDateTimeDisplay(String? dateStr,
      {String pattern = 'yyyy-MM-dd - hh:mm a', String fallback = '---'}) {
    if (dateStr == null || dateStr.isEmpty) return fallback;
    try {
      final date = AppDateTimeUtils.toLocal(dateStr);
      if (date == null) return fallback;
      return DateFormat(pattern).format(date);
    } catch (e) {
      if (dateStr.length >= 16) {
        return dateStr.substring(0, 16);
      }
      return dateStr;
    }
  }

  /// Compact rental period formatter for cards and small screens.
  /// Same day: 'Oct 09 • 1:30 PM → 3:30 PM'
  /// Multi day: 'Oct 09, 1:30 PM → Oct 11, 3:30 PM'
  static String formatRentalPeriod(String? startIso, String? endIso) {
    if (startIso == null || endIso == null || startIso.isEmpty || endIso.isEmpty) {
      return '${startIso ?? ""} → ${endIso ?? ""}';
    }
    try {
      final start = AppDateTimeUtils.toLocal(startIso);
      final end = AppDateTimeUtils.toLocal(endIso);
      if (start == null || end == null) {
        return '$startIso → $endIso';
      }
      final isSameDay = start.year == end.year &&
          start.month == end.month &&
          start.day == end.day;
      final dateFmt = DateFormat('MMM dd');
      final timeFmt = DateFormat('h:mm a');

      if (isSameDay) {
        return '${dateFmt.format(start)} • ${timeFmt.format(start)} → ${timeFmt.format(end)}';
      } else {
        return '${dateFmt.format(start)}, ${timeFmt.format(start)} → ${dateFmt.format(end)}, ${timeFmt.format(end)}';
      }
    } catch (_) {
      return '$startIso → $endIso';
    }
  }
}
