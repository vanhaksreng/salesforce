import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ConnectionType { bluetooth, ble, usb, network }

enum AlignStyle {
  center("center"),
  left("left"),
  right("right"),
  bottom("bottom");

  final String value;
  const AlignStyle(this.value);

  @override
  String toString() => value;
}

Alignment getAlignmentImage(int align) {
  switch (align) {
    case 0:
      return Alignment.centerLeft;
    case 1:
      return Alignment.center;
    case 2:
      return Alignment.centerRight;
    default:
      return Alignment.center;
  }
}

// class PosColumn {
//   final String text;
//   final int width; // Width out of 12 (12 = full width)
//   final AlignStyle align; // 'left', 'center', 'right'
//   final bool bold;

//   PosColumn({
//     required this.text,
//     required this.width,
//     this.align = AlignStyle.left,
//     this.bold = false,
//   });

//   Map<String, dynamic> toMap() {
//     return {'text': text, 'width': width, 'align': align.value, 'bold': bold};
//   }
// }

class PosColumn {
  final String text;
  final int width;
  final AlignStyle align;
  final bool bold;

  PosColumn({
    required this.text,
    required this.width,
    this.align = AlignStyle.left,
    this.bold = false,
  });

  Map<String, dynamic> toMap() {
    return {'text': text, 'width': width, 'align': align.value, 'bold': bold};
  }

  // ✅ Add this method
  PosColumn copyWith({
    String? text,
    int? width,
    AlignStyle? align,
    bool? bold,
  }) {
    return PosColumn(
      text: text ?? this.text,
      width: width ?? this.width,
      align: align ?? this.align,
      bold: bold ?? this.bold,
    );
  }
}

AlignStyle parseAlignStyle(String? align) {
  if (align == null) return AlignStyle.left;

  switch (align.toLowerCase()) {
    case 'center':
      return AlignStyle.center;
    case 'right':
      return AlignStyle.right;
    case 'bottom':
      return AlignStyle.bottom;
    default:
      return AlignStyle.left;
  }
}

class PrinterDeviceDiscover {
  final String name;
  final String address;
  final ConnectionType type;

  PrinterDeviceDiscover({
    required this.name,
    required this.address,
    required this.type,
  });

  factory PrinterDeviceDiscover.fromMap(Map<String, dynamic> map) {
    return PrinterDeviceDiscover(
      name: map['name'] ?? 'Unknown',
      address: map['address'] ?? '',
      type: _parseConnectionType(map['type']),
    );
  }

  static ConnectionType _parseConnectionType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'ble':
          return ConnectionType.ble;
        case 'usb':
          return ConnectionType.usb;
        case 'network':
          return ConnectionType.network;
        default:
          return ConnectionType.bluetooth;
      }
    }
    return ConnectionType.bluetooth;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'type': type.toString().split('.').last,
    };
  }
}

class ThermalPrinter {
  static const MethodChannel _channel = MethodChannel('thermal_printer');

  static Future<List<PrinterDeviceDiscover>> discoverPrinters({
    ConnectionType type = ConnectionType.bluetooth,
  }) async {
    try {
      final List<dynamic> printers = await _channel.invokeMethod(
        'discoverPrinters',
        {'type': type.toString().split('.').last},
      );
      return printers
          .map(
            (p) => PrinterDeviceDiscover.fromMap(Map<String, dynamic>.from(p)),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to discover printers: $e');
    }
  }

  /// Discover all available printers (all connection types)
  static Future<List<PrinterDeviceDiscover>> discoverAllPrinters() async {
    try {
      final List<dynamic> printers = await _channel.invokeMethod(
        'discoverAllPrinters',
      );
      return printers
          .map(
            (p) => PrinterDeviceDiscover.fromMap(Map<String, dynamic>.from(p)),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to discover printers: $e');
    }
  }

  // ====================================================================
  // CONNECTION METHODS (3)
  // ====================================================================

  /// Connect to a printer
  static Future<bool> connect(PrinterDeviceDiscover device) async {
    try {
      final bool result = await _channel.invokeMethod(
        'connect',
        device.toMap(),
      );
      return result;
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  /// Connect to network printer by IP and port
  static Future<bool> connectNetwork(
    String ipAddress, {
    int port = 9100,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('connectNetwork', {
        'ipAddress': ipAddress,
        'port': port,
      });
      return result;
    } catch (e) {
      throw Exception('Failed to connect to network printer: $e');
    }
  }

  /// Disconnect from the current printer
  static Future<bool> disconnect() async {
    try {
      final bool result = await _channel.invokeMethod('disconnect');
      return result;
    } catch (e) {
      throw Exception('Failed to disconnect: $e');
    }
  }

  // ====================================================================
  // BATCH MODE METHODS (2)
  // ====================================================================

  /// Start batch mode - collects all commands in buffer
  /// Call this before building a receipt for optimized transmission
  static Future<bool> startBatch() async {
    try {
      final bool result = await _channel.invokeMethod('startBatch');
      return result;
    } catch (e) {
      throw Exception('Failed to start batch: $e');
    }
  }

  /// End batch mode - optimizes and sends all buffered commands
  /// Call this after all receipt commands are added
  static Future<bool> endBatch() async {
    try {
      final bool result = await _channel.invokeMethod('endBatch');
      return result;
    } catch (e) {
      throw Exception('Failed to end batch: $e');
    }
  }

  // ====================================================================
  // PRINTING METHODS (5)
  // ====================================================================

  /// Print text with formatting options
  static Future<bool> printText(
    String text, {
    int fontSize = 24,
    int maxCharPerLine = 5,
    bool bold = false,
    String align = "left",
  }) async {
    try {
      final bool result = await _channel.invokeMethod('printText', {
        'text': text,
        'fontSize': fontSize,
        'bold': bold,
        "maxCharsPerLine": maxCharPerLine,
        "align": align,
      });
      return result;
    } catch (e) {
      throw Exception('Failed to print text: $e');
    }
  }

  /// Print a table row with multiple columns
  static Future<bool> printRow({
    required List<Map<String, dynamic>> columns,
    int fontSize = 24,
  }) async {
    try {
      final result = await _channel.invokeMethod('printRow', {
        'columns': columns,
        'fontSize': fontSize,
      });
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Print image from bytes
  static Future<bool> printImage(
    Uint8List imageBytes, {
    int width = 384,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('printImage', {
        'imageBytes': imageBytes,
        'width': width,
        "align": 1,
      });
      return result;
    } catch (e) {
      throw Exception('Failed to print image: $e');
    }
  }

  /// Print image with padding for proper alignment
  ///
  /// This method centers/aligns the image on the paper by adding padding
  ///
  /// [imageBytes] - Image data to print
  /// [width] - Image width in pixels (e.g., 384 for 58mm)
  /// [align] - Alignment: 0=left, 1=center, 2=right
  /// [paperWidth] - Paper width in pixels (384 for 58mm, 576 for 80mm)
  static Future<bool> printImageWithPadding(
    Uint8List imageBytes, {
    int width = 384,
    int align = 1, // 0=left, 1=center, 2=right
    int paperWidth = 576,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('printImageWithPadding', {
        'imageBytes': imageBytes,
        'width': width,
        'align': align,
        'paperWidth': paperWidth,
      });
      return result;
    } catch (e) {
      throw Exception('Failed to print image with padding: $e');
    }
  }

  /// Print a separator line
  ///
  /// Uses lower density pattern for lines made of "=" or "-" characters
  /// [width] - Number of characters (e.g., 48 for 80mm, 32 for 58mm)
  static Future<bool> printSeparator({int width = 48}) async {
    try {
      final bool result = await _channel.invokeMethod('printSeparator', {
        'width': width,
      });
      return result;
    } catch (e) {
      throw Exception('Failed to print separator: $e');
    }
  }

  // ====================================================================
  // PAPER CONTROL METHODS (2)
  // ====================================================================

  /// Feed paper (move paper forward)
  static Future<bool> feedPaper(int lines) async {
    try {
      final bool result = await _channel.invokeMethod('feedPaper', {
        'lines': lines,
      });
      return result;
    } catch (e) {
      throw Exception('Failed to feed paper: $e');
    }
  }

  /// Cut paper (if printer supports it)
  static Future<bool> cutPaper() async {
    try {
      final bool result = await _channel.invokeMethod('cutPaper');
      return result;
    } catch (e) {
      throw Exception('Failed to cut paper: $e');
    }
  }

  // ====================================================================
  // CONFIGURATION METHODS (4)
  // ====================================================================

  /// Set printer width for 58mm or 80mm paper
  ///
  /// [width] - Paper width in pixels:
  ///   - 384 for 58mm paper
  ///   - 576 for 80mm paper
  ///
  /// ⚠️ CRITICAL: Must be called BEFORE printing
  static Future<bool> setPrinterWidth(int width) async {
    try {
      final bool result = await _channel.invokeMethod('setPrinterWidth', {
        'width': width,
      });
      return result;
    } catch (e) {
      throw Exception('Failed to set printer width: $e');
    }
  }

  /// Configure printer with OOMAS-specific settings
  ///
  /// Sets optimal parameters for OOMAS thermal printers
  static Future<bool> configureOOMAS() async {
    try {
      final bool result = await _channel.invokeMethod('configureOOMAS');
      return result;
    } catch (e) {
      throw Exception('Failed to configure OOMAS: $e');
    }
  }

  /// Warm up printer before first print
  ///
  /// Sends initialization commands to prepare printer
  /// Recommended to call after connection
  static Future<bool> warmUpPrinter() async {
    try {
      final bool result = await _channel.invokeMethod('warmUpPrinter');
      return result;
    } catch (e) {
      throw Exception('Failed to warm up: $e');
    }
  }

  /// Initialize printer with optimal settings
  ///
  /// Performs complete printer initialization sequence
  static Future<bool> initializePrinter() async {
    try {
      final bool result = await _channel.invokeMethod('initializePrinter');
      return result;
    } catch (e) {
      throw Exception('Failed to initialize printer: $e');
    }
  }

  // ====================================================================
  // STATUS & DIAGNOSTIC METHODS (6)
  // ====================================================================

  /// Check printer connection and Bluetooth status
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final Map<dynamic, dynamic> status = await _channel.invokeMethod(
        'getStatus',
      );
      return status.cast<String, dynamic>();
    } catch (e) {
      throw Exception('Failed to get status: $e');
    }
  }

  /// Check if Bluetooth permissions are granted
  static Future<bool> checkBluetoothPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'checkBluetoothPermission',
      );
      return result;
    } catch (e) {
      throw Exception('Failed to check Bluetooth permission: $e');
    }
  }

  /// Check printer status and readiness
  ///
  /// Returns detailed printer status including:
  /// - Paper status
  /// - Temperature
  /// - Errors
  static Future<Map<String, dynamic>> checkPrinterStatus() async {
    try {
      final Map<dynamic, dynamic> status = await _channel.invokeMethod(
        'checkPrinterStatus',
      );
      return status.cast<String, dynamic>();
    } catch (e) {
      throw Exception('Failed to check printer status: $e');
    }
  }

  /// Detect printer model and speed characteristics
  ///
  /// Returns: "SLOW", "MEDIUM", or "FAST"
  /// - SLOW: Old printers (< 3 bytes/ms)
  /// - MEDIUM: Standard printers (3-6 bytes/ms)
  /// - FAST: Modern printers (> 6 bytes/ms)
  static Future<String> detectPrinterModel() async {
    try {
      final String model = await _channel.invokeMethod('detectPrinterModel');
      return model;
    } catch (e) {
      throw Exception('Failed to detect printer model: $e');
    }
  }

  /// Test paper feed mechanism
  ///
  /// Performs a simple paper feed test to verify motor function
  static Future<bool> testPaperFeed() async {
    try {
      final bool result = await _channel.invokeMethod('testPaperFeed');
      return result;
    } catch (e) {
      throw Exception('Failed to test paper feed: $e');
    }
  }

  /// Test slow printing to diagnose "stuck stuck" sound
  ///
  /// Prints test pattern with delays to identify motor issues
  static Future<bool> testSlowPrint() async {
    try {
      final bool result = await _channel.invokeMethod('testSlowPrint');
      return result;
    } catch (e) {
      throw Exception('Failed to test slow print: $e');
    }
  }

  /// Run complete diagnostic test
  ///
  /// Performs comprehensive printer diagnostic including:
  /// - Paper feed test
  /// - Slow print test
  /// - Status check
  /// - Speed detection
  ///
  /// Returns diagnostic results with details
  static Future<Map<String, dynamic>> runDiagnostic() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'runDiagnostic',
      );
      return result.cast<String, dynamic>();
    } catch (e) {
      throw Exception('Failed to run diagnostic: $e');
    }
  }
}
