import 'package:intl/intl.dart';

String formatEventDate(DateTime date) {
  return DateFormat('EEE, d. MMM yyyy.', 'hr').format(date);
}

String formatEventTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}

String formatEventDateTime(DateTime date) {
  return '${formatEventDate(date)} • ${formatEventTime(date)}';
}

String formatDateRange(DateTime start, DateTime? end) {
  final startStr = formatEventDateTime(start);
  if (end == null) return startStr;
  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    return '$startStr – ${formatEventTime(end)}';
  }
  return '$startStr – ${formatEventDateTime(end)}';
}
