import 'package:flutter/foundation.dart';
import 'package:salesforce/core/enums/enums.dart';

class Logger {
  static void init(LogMode mode) {}

  static void log(dynamic data, {StackTrace? stackTrace, LogMode logMode = LogMode.debug}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().split('.').first;
      final logMessage = "MESSAGE = $data";
      final stackTraceMsg = "STACKTRACE = $stackTrace";
      final border = '\x1B[90m${'-' * 120}\x1B[0m';
      debugPrint(border);
      switch (logMode) {
        case LogMode.debug:
          {
            debugPrint('\x1B[36m$timestamp\x1B[0m');
            debugPrint('\x1B[33m ⚡ DEBUG MODE $logMessage\x1B[0m');
            debugPrint('\x1B[32m$stackTraceMsg\x1B[0m');
            break;
          }
        case LogMode.info:
          {
            debugPrint('\x1B[36m$timestamp\x1B[0m');
            debugPrint('\x1B[32m${"⚡ INFO $logMessage"}\x1B[0m');
            debugPrint('\x1B[32m$stackTraceMsg\x1B[0m');
            break;
          }
        case LogMode.error:
          {
            debugPrint('\x1B[36m$timestamp\x1B[0m');
            debugPrint('\x1B[31m${"🚨 ERROR $logMessage"}\x1B[0m');
            debugPrint('\x1B[32m$stackTraceMsg\x1B[0m');
            break;
          }
        case LogMode.live:
          debugPrint('\x1B[36m$timestamp\x1B[0m');
          debugPrint('\x1B[32m${"💎 LIVE $logMessage"}\x1B[0m');
          debugPrint('\x1B[32m$stackTraceMsg\x1B[0m');
          break;
        case LogMode.warning:
          debugPrint('\x1B[36m$timestamp\x1B[0m');
          debugPrint('\x1B[33m${"🚨 WARNING $logMessage"}\x1B[0m');
          debugPrint('\x1B[32m$stackTraceMsg\x1B[0m');
          break;
      }
      debugPrint(border);
    }
  }
}
