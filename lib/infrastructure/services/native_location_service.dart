import 'package:flutter/services.dart';
import 'package:salesforce/core/utils/logger.dart';

class NativeLocationService {
  static const MethodChannel _channel = MethodChannel(
    'com.clearviewerp.salesforce/location',
  );

  static Future<void> setCustomPath({
    String? basePath,
    String? fileName,
  }) async {
    try {
      Logger.log("setCustomPath : called");
      final result = await _channel.invokeMethod('setCustomPath', {
        'basePath': basePath,
        'fileName': fileName,
      });

      Logger.log("setCustomPath : $result");
    } on PlatformException catch (e) {
      Logger.log("Failed to set custom path: ${e.message}");
    }
  }

  static Future<void> startNativeTracking() async {
    try {
      final result = await _channel.invokeMethod('startService');
      Logger.log("startNativeTracking : $result");
    } on PlatformException catch (e) {
      Logger.log("Failed to start native tracking: ${e.message}");
    }
  }

  static Future<void> stopNativeTracking() async {
    try {
      final result = await _channel.invokeMethod('stopService');
      Logger.log("stopNativeTracking : $result");
    } on PlatformException catch (e) {
      Logger.log("Failed to start native tracking: ${e.message}");
    }
  }
}
