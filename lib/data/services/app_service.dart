class Service {
  static List<String> months = [
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
    'Dec'
  ];

  static String toDateString(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString();
    final day = date.day.toString();

    String zero = date.month <= 9 ? "0" : "";

    return "$year-$zero$month-$day";
  }

  static String toDateNameString(DateTime date) {
    final year = date.year.toString();
    final month = date.month;
    final day = date.day.toString();

    return "$day-${months[month - 1]}-$year";
  }

  static String toDateTimeString(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final h = date.hour;
    final m = date.minute;
    final s = date.second;
    String zero = date.month <= 9 ? "0" : "";

    return "$year-$zero$month-$day $h:$m:$s";
  }

  static String toDateTimeNameString(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final h = date.hour;
    final m = date.minute;
    final s = date.second;
    String zero = date.month <= 9 ? "0" : "";

    return "$day-$zero$month-$year $h:$m:$s";
  }
}
