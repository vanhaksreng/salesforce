import 'dart:typed_data';
import 'package:flutter/services.dart';

class IminPrinterService {
  static const MethodChannel _platform = MethodChannel('com.imin.printersdk');

  /// Initializes the printer
  Future<void> initPrinter() async {
    try {
      final String result = await _platform.invokeMethod('sdkInit');
      print("Printer initialized: $result");
    } on PlatformException catch (e) {
      print("Failed to initialize the printer: '${e.message}'.");
    }
  }

  /// Gets the current printer status
  Future<void> getPrinterStatus() async {
    try {
      final String status = await _platform.invokeMethod('getStatus');
      print("Printer status: $status");
    } catch (e) {
      print("Error getting status: $e");
    }
  }

  /// Prints plain text
  Future<void> printText(String text) async {
    try {
      final String result = await _platform.invokeMethod('printText', [text]);
      print("Text printed: $result");
    } catch (e) {
      print("Error printing text: $e");
    }
  }

  /// Opens the cash drawer
  Future<void> openCashBox() async {
    try {
      final String result = await _platform.invokeMethod('opencashBox');
      print("Cash box opened: $result");
    } catch (e) {
      print("Failed to open cash box: $e");
    }
  }

  /// Gets the serial number of the device
  Future<void> getSerialNumber() async {
    try {
      final String sn = await _platform.invokeMethod('getSn');
      print("Device serial number: $sn");
    } catch (e) {
      print("Failed to get serial number: $e");
    }
  }

  /// Prints an image (as byte array)
  Future<void> printImage(Uint8List imageBytes) async {
    try {
      final result = await _platform.invokeMethod('printBitmap', {
        'image': imageBytes,
      });
      print("Image printed: $result");
    } catch (e) {
      print("Failed to print image: $e");
    }
  }
}
