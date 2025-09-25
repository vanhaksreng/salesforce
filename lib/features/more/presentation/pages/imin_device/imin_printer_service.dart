import 'package:flutter/services.dart';

class PrinterService {
  // Channel name must match the one in MainActivity
  static const MethodChannel _channel = MethodChannel('com.imin.printersdk');

  /// Initialize the printer SDK
  /// Must be called before using any other printer methods
  static Future<String> initPrinter() async {
    try {
      final result = await _channel.invokeMethod('sdkInit');
      print('Printer initialized: $result');
      return result;
    } on PlatformException catch (e) {
      print('Failed to initialize printer: ${e.message}');
      throw Exception('Failed to initialize printer: ${e.message}');
    }
  }

  /// Get printer status
  static Future<Map<String, dynamic>> getPrinterStatus() async {
    try {
      final result = await _channel.invokeMethod('getStatus');
      print('Printer status: $result');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('Failed to get printer status: ${e.message}');
      throw Exception('Failed to get printer status: ${e.message}');
    }
  }

  /// Print text - using Map format (matches your Kotlin code)
  static Future<String?> printText(String text) async {
    try {
      final String result = await _channel.invokeMethod('printText', {
        'text': text,
      });
      print("Print Text Result: $result");
      return result;
    } on PlatformException catch (e) {
      print("Failed to print text: '${e.message}' - Code: ${e.code}");
      return null;
    }
  }

  /// Get device serial number
  static Future<String> getSerialNumber() async {
    try {
      final result = await _channel.invokeMethod('getSn');
      print('Serial number: $result');
      return result;
    } on PlatformException catch (e) {
      print('Failed to get serial number: ${e.message}');
      throw Exception('Failed to get serial number: ${e.message}');
    }
  }

  /// Open cash box
  static Future<String> openCashBox() async {
    try {
      final result = await _channel.invokeMethod('opencashBox');
      print('Cash box opened: $result');
      return result;
    } on PlatformException catch (e) {
      print('Failed to open cash box: ${e.message}');
      throw Exception('Failed to open cash box: ${e.message}');
    }
  }

  /// Print bitmap image
  static Future<String> printBitmap(Uint8List imageBytes) async {
    try {
      final result = await _channel.invokeMethod('printBitmap', {
        'image': imageBytes,
      });
      print('Bitmap printed: $result');
      return result;
    } on PlatformException catch (e) {
      print('Failed to print bitmap: ${e.message}');
      throw Exception('Failed to print bitmap: ${e.message}');
    }
  }
}
