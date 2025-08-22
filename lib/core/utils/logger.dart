import 'package:flutter/foundation.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/date_extensions.dart';

class Logger {
  static void init(LogMode mode) {}

  static void log(dynamic data, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toTimeString();
      debugPrint('$timestamp: $data');
      debugPrint('-' * 100);
    }
  }
}
