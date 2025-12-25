import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  static final List<DateFormat> _supportedFormats = [
    // Day-Month(Abbr)-Year
    DateFormat('dd-MMM-yyyy'), // 24-Jun-2025
    DateFormat('dd-MMM-yyyy HH:mm'), // 24-Jun-2025 14:30
    DateFormat('dd-MMM-yyyy HH:mm:ss'), // 24-Jun-2025 14:30:45

    // Day-Month(Number)-Year
    DateFormat('dd-MM-yyyy'), // 24-06-2025
    DateFormat('dd-MM-yyyy HH:mm'), // 24-06-2025 14:30
    DateFormat('dd-MM-yyyy HH:mm:ss'), // 24-06-2025 14:30:45

    // Month(Abbr)-Day-Year
    DateFormat('MMM-dd-yyyy'), // Jun-24-2025
    DateFormat('MMM-dd-yyyy HH:mm'), // Jun-24-2025 14:30
    DateFormat('MMM-dd-yyyy HH:mm:ss'), // Jun-24-2025 14:30:45

    // Month(Number)-Day-Year
    DateFormat('MM-dd-yyyy'), // 06-24-2025
    DateFormat('MM-dd-yyyy HH:mm'), // 06-24-2025 14:30
    DateFormat('MM-dd-yyyy HH:mm:ss'), // 06-24-2025 14:30:45

    // ISO & Common formats
    DateFormat('yyyy-MM-dd'), // 2025-06-24
    DateFormat('yyyy-MM-dd HH:mm'), // 2025-06-24 14:30
    DateFormat('yyyy-MM-dd HH:mm:ss'), // 2025-06-24 14:30:00
    DateFormat("yyyy-MM-dd'T'HH:mm:ss"), // 2025-06-24T14:30:00
    DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS"), // 2025-06-24T14:30:00.000

    // Time-only formats
    DateFormat('HH:mm:ss'), // 14:30:00
    DateFormat('HH:mm'), // 14:30
    DateFormat('HH'), // 14
  ];

  /// Checks if two dates are the same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool get isToday => isSameDay(DateTime.now());

  /// Returns true if date was yesterday
  bool get isYesterday => isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Returns true if date is tomorrow
  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// Returns formatted date string (YYYY-MM-DD)
  String toDateNameString() {
    final d = DateFormat('dd MMM yyyy').format(this);

    if (year == 1999) {
      return "";
    }

    return d;
  }

  /// Returns formatted date string (YYYY-MM-DD)
  String toDateNameSortString() {
    final d = DateFormat('MMM dd').format(this);

    if (year == 1999) {
      return "";
    }

    return d;
  }

  /// Returns formatted date time string (YYYY-MM-DD HH:mm:ss)
  String toDateTimeNameString() {
    final d = DateFormat('dd MMM yyyy HH:mm:ss').format(this);

    if (year == 1999) {
      return "";
    }

    return d;
  }

  String toDateString() {
    final paddedMonth = month.toString().padLeft(2, '0');
    final paddedDay = day.toString().padLeft(2, '0');
    return '$year-$paddedMonth-$paddedDay';
  }

  String toDateTimeString() {
    return toDateString() + DateFormat(' HH:mm:ss').format(this);
  }

  String toTime24String() {
    return DateFormat(' HH:mm:ss').format(this);
  }

  static String toDateNameStr(DateTime? date) {
    if (date == null) {
      return "";
    }

    return date.toDateNameString();
  }

  int aging() {
    final now = DateTime.now();

    if (year < 2000) {
      return 0; // If the date is set to a default value, return 0
    }

    if (now.isBefore(this)) {
      return 0; // If the date is in the future, return 0
    }

    final difference = now.difference(this).inDays;

    // If the date is in the future, return 0
    if (difference < 0) {
      return 0;
    }

    return difference;
  }

  static DateTime parse(String? input) {
    if (input == null || input.isEmpty) {
      return DateTime.parse("1999-01-30");
    }

    input = input.trim();

    // Try parsing with supported date formats first
    for (final format in _supportedFormats) {
      try {
        return format.parseStrict(input);
      } catch (_) {
        // Continue to try other formats
      }
    }

    final RegExp re = RegExp(r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // Day part.
        r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d+))?)?)?' // Time part.
        r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$'); // Timezone part.

    Match? match = re.firstMatch(input);

    if (match != null) {
      int parseIntOrZero(String? matched) {
        if (matched == null) return 0;
        return int.parse(matched);
      }

      // Parses fractional second digits of '.(\d+)' into the combined
      // microseconds. We only use the first 6 digits because of DateTime
      // precision of 999 milliseconds and 999 microseconds.
      int parseMilliAndMicroseconds(String? matched) {
        if (matched == null) return 0;
        int length = matched.length;
        assert(length >= 1);
        int result = 0;
        for (int i = 0; i < 6; i++) {
          result *= 10;
          if (i < matched.length) {
            result += matched.codeUnitAt(i) ^ 0x30;
          }
        }
        return result;
      }

      int years = int.parse(match[1]!);
      int month = int.parse(match[2]!);
      int day = int.parse(match[3]!);
      int hour = parseIntOrZero(match[4]);
      int minute = parseIntOrZero(match[5]);
      int second = parseIntOrZero(match[6]);
      int milliAndMicroseconds = parseMilliAndMicroseconds(match[7]);
      int millisecond = milliAndMicroseconds ~/ Duration.microsecondsPerMillisecond;
      int microsecond = milliAndMicroseconds.remainder(Duration.microsecondsPerMillisecond);
      bool isUtc = false;
      if (match[8] != null) {
        // timezone part
        isUtc = true;
        String? tzSign = match[9];
        if (tzSign != null) {
          // timezone other than 'Z' and 'z'.
          int sign = (tzSign == '-') ? -1 : 1;
          int hourDifference = int.parse(match[10]!);
          int minuteDifference = parseIntOrZero(match[11]);
          minuteDifference += 60 * hourDifference;
          minute -= sign * minuteDifference;
        }
      }
      DateTime? result = _finishParse(years, month, day, hour, minute, second, millisecond, microsecond, isUtc);
      if (result == null) {
        throw FormatException("Time out of range", input);
      }
      return result;
    } else {
      throw FormatException("Invalid date format", input);
    }
  }

  static String getShortCurrentDateTimeForDocNo({String format = "YF"}) {
    try {
      final now = DateTime.now();
      String year = now.year.toString().substring(2, 4);
      String month = now.month.toString().padLeft(2, '0');
      String day = now.day.toString().padLeft(2, '0');

      if (format == "YF") {
        return "$year$month$day";
      } else {
        return "$day$month$year";
      }
    } catch (e) {
      return "";
    }
  }
  // DateTime? tryParseDate(String input) {
  //   final formats = [
  //     DateFormat('dd-MMM-yyyy'), // 24-Jun-2025
  //     DateFormat('yyyy-MM-dd'), // 2025-06-24
  //   ];

  //   for (var format in formats) {
  //     try {
  //       return format.parseStrict(input);
  //     } catch (_) {
  //       // Continue trying next format
  //     }
  //   }

  //   return null; // None matched
  // }

  // external static DateTime? _finishParse(int year, int month, int day, int hour,
  //     int minute, int second, int millisecond, int microsecond, bool isUtc);

//============================new
  static DateTime? _finishParse(
      int year, int month, int day, int hour, int minute, int second, int millisecond, int microsecond, bool isUtc) {
    // Validate ranges
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;
    if (hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;
    if (second < 0 || second > 59) return null;
    if (millisecond < 0 || millisecond > 999) return null;
    if (microsecond < 0 || microsecond > 999) return null;

    try {
      if (isUtc) {
        return DateTime.utc(year, month, day, hour, minute, second, millisecond, microsecond);
      } else {
        return DateTime(year, month, day, hour, minute, second, millisecond, microsecond);
      }
    } catch (e) {
      return null;
    }
  }

  static String? validateDate(String? input) {
    if (input is DateTime) {
      return null;
    }

    if (input == null || input.isEmpty) return null;

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input)) {
      return 'YYYY-MM-DD';
    }

    try {
      final parts = input.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final date = DateTime(year, month, day);

      if (date.year != year || date.month != month || date.day != day) {
        return 'Invalid Date. Please check the day and month values.';
      }

      return null;
    } catch (e) {
      return 'Invalid date';
    }
  }

  String toRelativeDate() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isTomorrow) return 'Tomorrow';

    final now = DateTime.now();
    final difference = now.difference(this).inDays;

    if (difference < 7) {
      return DateFormat('EEEE').format(this); // Full weekday name
    } else if (year == now.year) {
      return DateFormat('MMM d').format(this); // Jun 14
    } else {
      return DateFormat('MMM d, yyyy').format(this); // Jun 14, 2025
    }
  }

  String whatDayOfWeek() {
    final now = DateTime.now();
    return DateFormat('EEEE').format(now);
  }

  String dayName() {
    final now = DateTime.now();
    return DateFormat('EEEE').format(now);
  }

  /// Returns formatted time (12:30 PM)
  String toTimeString() {
    return DateFormat('h:mm a').format(this);
  }

  /// Returns formatted date and time with relative dates
  String toRelativeDateTimeString() {
    return '${toRelativeDate()} at ${toTimeString()}';
  }

  DateTime firstDayOfMonth() {
    return firstOfMonth;
  }

  DateTime endDayOfMonth() {
    return endOfMonth;
  }

  DateTime firstDayOfWeek() {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  /// Returns the last day of the week (Sunday)
  DateTime endDayOfWeek() {
    return add(Duration(days: DateTime.sunday - weekday)).endOfDay;
  }

  /// Add or subtract days
  DateTime addDays(int days) => add(Duration(days: days));

  /// Add or subtract months (handles year rollover)
  DateTime addMonths(int months) {
    int newYear = year + ((month + months - 1) ~/ 12);
    int newMonth = ((month + months - 1) % 12) + 1;
    int newDay = day;
    // Handle end-of-month overflow
    int lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    if (newDay > lastDayOfNewMonth) newDay = lastDayOfNewMonth;
    return DateTime(newYear, newMonth, newDay);
  }

  /// Add or subtract years
  DateTime addYears(int years) {
    int newYear = year + years;
    int newDay = day;
    // Handle leap years and end-of-month overflow
    int lastDayOfNewMonth = DateTime(newYear, month + 1, 0).day;
    if (newDay > lastDayOfNewMonth) newDay = lastDayOfNewMonth;
    return DateTime(newYear, month, newDay);
  }

  /// Returns true if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Returns true if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Returns true if date is within this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return isAfter(weekStart) && isBefore(weekEnd);
  }

  /// Returns true if date is within this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Gets current month (1-12)
  int get thisMonth => month;

  /// Gets next month (handles year rollover)
  int get nextMonth => month < 12 ? month + 1 : 1;

  /// Gets current year
  int get thisYear => year;

  /// Gets next year
  int get nextYear => year + 1;

  /// Returns first day of month
  DateTime get firstOfMonth => DateTime(year, month, 1);

  /// Returns last day of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0);

  /// Checks if date is weekend
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Returns start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}
