extension DateTimeExtensions on DateTime {
  /// Returns true if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Returns true if this date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Returns true if this date is in the current week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Returns true if this date is in the current month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Returns true if this date is in the current year
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  /// Returns the start of the day (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Returns the end of the day (23:59:59.999)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Returns the start of the week (Monday)
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  /// Returns the end of the week (Sunday)
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).endOfDay;
  }

  /// Returns the start of the month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Returns the end of the month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 1).subtract(const Duration(days: 1)).endOfDay;
  }

  /// Returns the start of the year
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  /// Returns the end of the year
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  /// Returns a formatted string for display
  String get displayFormat {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isTomorrow) return 'Tomorrow';
    
    final now = DateTime.now();
    if (year == now.year) {
      return '${_monthNames[month - 1]} $day';
    } else {
      return '${_monthNames[month - 1]} $day, $year';
    }
  }

  /// Returns a short formatted string for display
  String get shortDisplayFormat {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    
    return '${_monthNamesShort[month - 1]} $day';
  }

  /// Returns time in 12-hour format
  String get time12Hour {
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour < 12 ? 'AM' : 'PM';
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  /// Returns time in 24-hour format
  String get time24Hour {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  /// Returns relative time (e.g., "2 hours ago", "in 3 days")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      // Future time
      final futureDiff = difference.abs();
      if (futureDiff.inDays > 0) {
        return 'in ${futureDiff.inDays} day${futureDiff.inDays == 1 ? '' : 's'}';
      } else if (futureDiff.inHours > 0) {
        return 'in ${futureDiff.inHours} hour${futureDiff.inHours == 1 ? '' : 's'}';
      } else if (futureDiff.inMinutes > 0) {
        return 'in ${futureDiff.inMinutes} minute${futureDiff.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'in a few seconds';
      }
    } else {
      // Past time
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'just now';
      }
    }
  }

  /// Returns age from this date to now
  String get ageFromNow {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      final remainingDays = difference.inDays - (years * 365);
      final months = (remainingDays / 30).floor();
      
      if (months > 0) {
        return '$years year${years == 1 ? '' : 's'}, $months month${months == 1 ? '' : 's'}';
      } else {
        return '$years year${years == 1 ? '' : 's'}';
      }
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      final remainingDays = difference.inDays - (months * 30);
      
      if (remainingDays > 0) {
        return '$months month${months == 1 ? '' : 's'}, $remainingDays day${remainingDays == 1 ? '' : 's'}';
      } else {
        return '$months month${months == 1 ? '' : 's'}';
      }
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      final remainingDays = difference.inDays - (weeks * 7);
      
      if (remainingDays > 0) {
        return '$weeks week${weeks == 1 ? '' : 's'}, $remainingDays day${remainingDays == 1 ? '' : 's'}';
      } else {
        return '$weeks week${weeks == 1 ? '' : 's'}';
      }
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'just born';
    }
  }

  /// Returns the day of week name
  String get dayOfWeekName {
    return _dayNames[weekday - 1];
  }

  /// Returns the short day of week name
  String get dayOfWeekNameShort {
    return _dayNamesShort[weekday - 1];
  }

  /// Returns the month name
  String get monthName {
    return _monthNames[month - 1];
  }

  /// Returns the short month name
  String get monthNameShort {
    return _monthNamesShort[month - 1];
  }

  /// Check if this date is the same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if this date is before another date (day comparison only)
  bool isDayBefore(DateTime other) {
    final thisDay = DateTime(year, month, day);
    final otherDay = DateTime(other.year, other.month, other.day);
    return thisDay.isBefore(otherDay);
  }

  /// Check if this date is after another date (day comparison only)
  bool isDayAfter(DateTime other) {
    final thisDay = DateTime(year, month, day);
    final otherDay = DateTime(other.year, other.month, other.day);
    return thisDay.isAfter(otherDay);
  }

  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    var result = this;
    var daysToAdd = days;
    
    while (daysToAdd > 0) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday && result.weekday != DateTime.sunday) {
        daysToAdd--;
      }
    }
    
    return result;
  }

  /// Subtract business days (excluding weekends)
  DateTime subtractBusinessDays(int days) {
    var result = this;
    var daysToSubtract = days;
    
    while (daysToSubtract > 0) {
      result = result.subtract(const Duration(days: 1));
      if (result.weekday != DateTime.saturday && result.weekday != DateTime.sunday) {
        daysToSubtract--;
      }
    }
    
    return result;
  }

  static const List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> _dayNamesShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _monthNamesShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}

/// Utility functions for working with date ranges
class DateTimeUtils {
  /// Get the difference between two dates in a human-readable format
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get a list of dates between two dates
  static List<DateTime> getDaysBetween(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = start.startOfDay;
    final endDate = end.startOfDay;

    while (!current.isAfter(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  /// Get the number of business days between two dates
  static int getBusinessDaysBetween(DateTime start, DateTime end) {
    var count = 0;
    var current = start.startOfDay;
    final endDate = end.startOfDay;

    while (current.isBefore(endDate)) {
      if (current.weekday != DateTime.saturday && current.weekday != DateTime.sunday) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }

  /// Parse date string in various formats
  static DateTime? tryParseDate(String dateString) {
    // Try different date formats
    final formats = [
      RegExp(r'^\d{4}-\d{2}-\d{2}$'), // YYYY-MM-DD
      RegExp(r'^\d{2}/\d{2}/\d{4}$'), // MM/DD/YYYY
      RegExp(r'^\d{2}-\d{2}-\d{4}$'), // MM-DD-YYYY
    ];

    for (final format in formats) {
      if (format.hasMatch(dateString)) {
        try {
          return DateTime.parse(dateString);
        } catch (e) {
          // Try other parsing methods
        }
      }
    }

    return null;
  }
}
