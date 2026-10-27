/// Formatting for the rescue screens (no intl dependency yet).
abstract final class RescueFormat {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// 10:20 AM
  static String time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  /// Sep 12, 2024 • 11:10 AM
  static String dateTime(DateTime t) =>
      '${_months[t.month - 1]} ${t.day}, ${t.year} • ${time(t)}';

  /// Sep 05, 2024 • 09:10 AM (history lists).
  static String dateTimePadded(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${_months[t.month - 1]} ${two(t.day)}, ${t.year} • '
        '${two(h)}:${two(t.minute)} ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  /// Aug 2024
  static String monthYear(DateTime t) => '${_months[t.month - 1]} ${t.year}';

  /// 45 minutes (never "0 minutes").
  static String duration(Duration d) {
    final m = d.inMinutes < 1 ? 1 : d.inMinutes;
    return '$m minute${m == 1 ? '' : 's'}';
  }

  /// ₹650.00
  static String rupees(int amount) => '₹$amount.00';
}
