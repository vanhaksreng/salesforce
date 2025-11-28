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

class PosColumn {
  final String text;
  final int width; // Width out of 12 (12 = full width)
  final AlignStyle align; // 'left', 'center', 'right'
  final bool bold;

  PosColumn({
    required this.text,
    required this.width,
    this.align = AlignStyle.left,
    this.bold = false,
  });

  Map<String, dynamic> toMap() {
    return {'text': text, 'width': width};
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

  /// Discover available thermal printers of specific type
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

  /// Print text
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

  /// Check printer status
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

  static Future<bool> setPrinterWidth(int width) async {
    try {
      final bool result = await _channel.invokeMethod('setPrinterWidth', {
        'width': width,
      });
      return result;
    } catch (e) {
      throw Exception('Failed to feed paper: $e');
    }
  }
}
