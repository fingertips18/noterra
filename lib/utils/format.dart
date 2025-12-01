import 'package:intl/intl.dart';

String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final aDate = DateTime(date.year, date.month, date.day);

  final difference = today.difference(aDate).inDays;

  // Use 12-hour format with AM/PM
  final timeFormat = DateFormat('h:mm a');
  final fullFormat = DateFormat('yyyy-MM-dd h:mm a');

  // Today
  if (difference == 0) {
    final diff = now.difference(date);

    // Less than 1 minute ago
    if (diff.inMinutes == 0) {
      return "${diff.inSeconds} seconds ago";
    }
    // Less than 1 hour ago
    else if (diff.inHours == 0) {
      return "${diff.inMinutes} minutes ago";
    }
    // Less than 24 hours ago
    else if (diff.inHours < 24) {
      return "${diff.inHours} hours ago";
    }
    // Otherwise just show today with time
    else {
      return "Today ${timeFormat.format(date)}";
    }
  }
  // Yesterday
  else if (difference == 1) {
    return "Yesterday ${timeFormat.format(date)}";
  }
  // Within last 7 days
  else if (difference < 7) {
    return "$difference days ago ${timeFormat.format(date)}";
  }
  // Older -> full date
  else {
    return fullFormat.format(date);
  }
}
