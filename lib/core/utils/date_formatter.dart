import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('HH:mm - dd/MM/yyyy');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _weekdayFormat = DateFormat('EEE', 'vi_VN');

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String formatWeekday(DateTime dateTime) {
    return _weekdayFormat.format(dateTime);
  }

  /// Parse chuỗi thời gian như "13:30 - 05/10/2026" hoặc "05/10/2026"
  static DateTime? parseDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final clean = raw.trim();
      if (clean.contains('-') && clean.contains(':')) {
        // Ví dụ: "13:30 - 05/10/2026"
        return _dateTimeFormat.parse(clean);
      } else if (clean.contains('/')) {
        // Ví dụ: "05/10/2026"
        return _dateFormat.parse(clean);
      }
      return DateTime.tryParse(clean);
    } catch (_) {
      return null;
    }
  }
}
