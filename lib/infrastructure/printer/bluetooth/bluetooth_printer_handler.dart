import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';

class BluetoothPrinterHandler {
  static const String channelName = "com.clearviewerp.salesforce/bluetoothprinter";
  static const _channel = MethodChannel(channelName);
  static Function(Map<String, dynamic>)? _onDeviceFound;
  static bool _isConnected = false;
  static String? _connectedDeviceAddress;

  /// Register the method channel handler
  /// Call this in main() before runApp()
  static void register() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle incoming method calls from native platforms
  static Future<dynamic> _handleMethodCall(MethodCall call) async {

    // print("Called Method : ${call.method}");

    switch (call.method) {
      
      case 'onDeviceFound':
        if (_onDeviceFound != null) {
          final device = Map<String, dynamic>.from(call.arguments);

          final code = device['code'];
          if (code == "BLUETOOTH_ERROR") {
            Helpers.showMessage(
              msg: device['message'],
              status: MessageStatus.errors,
            );
            return;
          }

          _onDeviceFound!(device);
        }
        break;
      default:
        throw MissingPluginException('Unknown method: ${call.method}');
    }
    return null;
  }

  /// Set callback for when a device is found during scanning
  static void setDeviceFoundCallback(Function(Map<String, dynamic>) callback) {
    _onDeviceFound = callback;
  }

  /// Check if a printer is currently connected
  static bool get isConnected => _isConnected;

  /// Get the address of the connected device
  static String? get connectedDeviceAddress => _connectedDeviceAddress;

  /// Scan for Bluetooth devices
  static Future<void> scanDevices() async {
    try {
      print("scanDevices called");
      await _channel.invokeMethod('scanDevices');
      print("scanDevices ended");
    } on PlatformException catch (e) {
      print('Failed to scan devices: ${e.toString()}');
      throw Exception('Failed to scan devices: ${e.message}');
    }
  }

  /// Connect to a Bluetooth device
  /// Must be called before printing
  static Future<bool> connectDevice(String address) async {
    try {
      final result = await _channel.invokeMethod('connectDevice', {
        'address': address,
      });

      if (result == true) {
        _isConnected = true;
        _connectedDeviceAddress = address;
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      _isConnected = false;
      _connectedDeviceAddress = null;
      Helpers.showMessage(msg: e.toString(), status: MessageStatus.errors);
      throw Exception('Failed to connect: ${e.message}');
    }
  }

  /// Print text to the connected printer
  /// Throws exception if not connected
  static Future<void> printText(String text) async {
    if (!_isConnected) {
      throw Exception(
        'Not connected to any printer. Call connectDevice() first.',
      );
    }

    try {
      print("print called");
      await _channel.invokeMethod('printText', {'text': text});
      print("print end");
    } on PlatformException catch (e) {
      print(e);
      throw Exception('Failed to print: ${e.message}');
    }
  }
  /// Print text to the connected printer
  /// Throws exception if not connected
  static Future<void> printImage(Uint8List bytes) async {
    if (!_isConnected) {
      throw Exception(
        'Not connected to any printer. Call connectDevice() first.',
      );
    }

    try {
      print("print called");
      await _channel.invokeMethod('printImage', {'imageBytes': bytes});
      print("print end");
    } on PlatformException catch (e) {
      print(e);
      throw Exception('Failed to print: ${e.message}');
    }
  }

  static Future<void> printRaw(Uint8List text) async {
    if (!_isConnected) {
      throw Exception(
        'Not connected to any printer. Call connectDevice() first.',
      );
    }

    try {
      print("print called");
      await _channel.invokeMethod('printRaw', {'rawBytes': text});
      print("print end");
    } on PlatformException catch (e) {
      print(e);
      throw Exception('Failed to print: ${e.message}');
    }
  }

  static Future<void> printHtml(String html) async {
    if (!_isConnected) {
      throw Exception(
        'Not connected to any printer. Call connectDevice() first.',
      );
    }

    try {
      print("print called");
      await _channel.invokeMethod('printHtml', {'html': html});
      print("print end");
    } on PlatformException catch (e) {
      print(e);
      throw Exception('Failed to print: ${e.message}');
    }
  }

  /// Disconnect from the current device
  static Future<void> disconnect() async {
    try {

      if (!_isConnected) {
        return;
      }

      await _channel.invokeMethod('disconnect');
      _isConnected = false;
      _connectedDeviceAddress = null;
    } on PlatformException catch (e) {
      throw Exception('Failed to disconnect: ${e.message}');
    }
  }

  /// Clear the device found callback
  static void clearCallback() {
    _onDeviceFound = null;
  }

  /// Print Khmer text with UTF-8 encoding
  /// Ensures proper character encoding for Khmer language
  static Future<void> printKhmerText(String khmerText) async {
    if (!_isConnected) {
      throw Exception(
        'Not connected to any printer. Call connectDevice() first.',
      );
    }

    try {
      // Encode Khmer text as UTF-8
      final utf8Bytes = utf8.encode(khmerText);
      await printRaw(Uint8List.fromList(utf8Bytes));
    } on PlatformException catch (e) {
      throw Exception('Failed to print Khmer text: ${e.message}');
    }
  }

  /// Wait for printer connection with timeout
  static Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final startTime = DateTime.now();
    
    while (!_isConnected) {
      if (DateTime.now().difference(startTime) > timeout) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return true;
  }

  /// Auto-scan and connect to a specific printer by name
  static Future<bool> autoScanAndConnect(String printerName) async {
    try {
      setDeviceFoundCallback((device) {
        if (device['name'] == printerName && !_isConnected) {
          connectDevice(device['address']);
        }
      });

      await scanDevices();
      
      // Wait for connection
      final result = await waitForConnection();
      clearCallback();
      
      return result;
    } catch (e) {
      clearCallback();
      throw Exception('Auto-scan failed: $e');
    }
  }
}
