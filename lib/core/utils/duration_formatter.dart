/// Formats [Duration] into human-readable strings.
class DurationFormatter {
  /// Formats duration into "dd d hh:mm:ss" or "hh:mm:ss".
  static String format(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = duration.inDays;
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (days > 0) {
      return "${days}d $hours:$minutes:$seconds";
    } else {
      return "${twoDigits(duration.inHours)}:$minutes:$seconds";
    }
  }
}
