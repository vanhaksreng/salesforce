import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IminPrinterService {
  static const MethodChannel _channel = MethodChannel('com.imin.printersdk');

  /// Initialize the printer
  static Future<Map<String, dynamic>> initialize() async {
    try {
      final result = await _channel.invokeMethod('sdkInit');
      final data = Map<String, dynamic>.from(result);

      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Scan for available printer devices
  static Future<List<Map<String, dynamic>>> scanDevices() async {
    try {
      final result = await _channel.invokeMethod('scanDevices');

      final devices = List<Map<String, dynamic>>.from(
        (result['devices'] as List).map((d) => Map<String, dynamic>.from(d)),
      );

      return devices;
    } catch (e) {
      return [];
    }
  }

  /// Get printer status
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final result = await _channel.invokeMethod('getStatus');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      rethrow;
    }
  }

  /// Print text (auto-detects Khmer/English)
  static Future<void> printText(
    String text, {
    int fontSize = 24,
    bool bold = false,
    String align = 'left', // 'left', 'center', 'right'
    int maxCharsPerLine = 0,
  }) async {
    try {
      await _channel.invokeMethod('printText', {
        'text': text,
        'fontSize': fontSize,
        'bold': bold,
        'align': align,
        'maxCharsPerLine': maxCharsPerLine,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Print text as image (forces bitmap rendering for custom fonts)
  static Future<void> printTextAsImage(
    String text, {
    int fontSize = 24,
    String? fontName, // e.g., "KhmerOS"
    String align = 'left',
    bool bold = false,
  }) async {
    try {
      await _channel.invokeMethod('printTextAsImage', {
        'text': text,
        'fontSize': fontSize,
        'fontName': fontName,
        'align': align,
        'bold': bold,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ==================== TABLE/ROW PRINTING ====================

  /// Print a row with multiple columns
  ///
  /// Example:
  /// ```dart
  /// await IminPrinterService.printRow([
  ///   {'text': 'Item', 'width': 3, 'align': 'left'},
  ///   {'text': 'Qty', 'width': 1, 'align': 'center'},
  ///   {'text': 'Price', 'width': 2, 'align': 'right'},
  /// ]);
  /// ```
  static Future<void> printRow(
    List<Map<String, dynamic>> columns, {
    int fontSize = 16,
  }) async {
    try {
      await _channel.invokeMethod('printRow', {
        'columns': columns,
        'fontSize': fontSize,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ==================== SEPARATOR ====================

  static Future<void> printSeparator({int width = 48}) async {
    try {
      await _channel.invokeMethod('printSeparator', {'width': width});
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> printImage(
    Uint8List imageBytes, {
    int width = 576,
    int align = 1, // 0=left, 1=center, 2=right
  }) async {
    try {
      await _channel.invokeMethod('printImage', {
        'imageBytes': imageBytes,
        'width': width,
        'align': align,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> printImageWithPadding(
    Uint8List imageBytes, {
    int width = 384,
    int align = 1, // 0=left, 1=center, 2=right
    int paperWidth = 576,
  }) async {
    try {
      await _channel.invokeMethod('printImageWithPadding', {
        'imageBytes': imageBytes,
        'width': width,
        'align': align,
        'paperWidth': paperWidth,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> printBitmap(Uint8List imageBytes) async {
    try {
      await _channel.invokeMethod('printBitmap', {'image': imageBytes});
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> feedPaper({int lines = 1}) async {
    try {
      await _channel.invokeMethod('feedPaper', {'lines': lines});
    } catch (e) {
      rethrow;
    }
  }

  /// Cut paper
  static Future<void> cutPaper() async {
    try {
      await _channel.invokeMethod('cutPaper');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> printReceipt(ReceiptBuilder receipt) async {
    try {
      await _channel.invokeMethod('printReceipt', {
        'receiptData': receipt.toJson(),
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> testPrint() async {
    try {
      await _channel.invokeMethod('testPrint');
    } catch (e) {
      rethrow;
    }
  }

  /// Get device info
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      rethrow;
    }
  }

  /// Get serial number
  static Future<String> getSerialNumber() async {
    try {
      final sn = await _channel.invokeMethod('getSn');
      return sn as String;
    } catch (e) {
      return 'UNKNOWN';
    }
  }

  /// Open cash drawer
  static Future<void> openCashBox() async {
    try {
      await _channel.invokeMethod('opencashBox');
    } catch (e) {
      rethrow;
    }
  }

  /// Reset printer
  static Future<void> reset() async {
    try {
      await _channel.invokeMethod('resetPrinter');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Uint8List?> generateInvoicePreview({
    required Map<String, dynamic> receiptData,
  }) async {
    try {
      final result = await _channel.invokeMethod('generateInvoicePreview', {
        'receiptData': receiptData,
      });

      if (result != null && result['preview'] != null) {
        return result['preview'] as Uint8List;
      }
      return null;
    } catch (e) {
      debugPrint('Error generating preview: $e');
      return null;
    }
  }
}

// ==================== RECEIPT BUILDER CLASSES ====================

class ReceiptBuilder {
  final String? title;
  final String? subtitle;
  final List<String>? headerInfo;
  final List<ReceiptItem> items;
  final List<ReceiptTotal>? totals;
  final String? footerMessage;
  final ReceiptOptions? options;

  ReceiptBuilder({
    this.title,
    this.subtitle,
    this.headerInfo,
    required this.items,
    this.totals,
    this.footerMessage,
    this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'header': {
        if (title != null) 'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (headerInfo != null) 'info': headerInfo,
      },
      'items': items.map((item) => item.toJson()).toList(),
      'footer': {
        if (totals != null) 'totals': totals!.map((t) => t.toJson()).toList(),
        if (footerMessage != null) 'message': footerMessage,
      },
      'options': options?.toJson() ?? {},
    };
  }
}

class ReceiptItem {
  final String item;
  final String qty;
  final String price;
  final String disc;
  final String total;

  ReceiptItem({
    required this.item,
    required this.qty,
    required this.price,
    this.disc = '0%',
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'qty': qty,
      'price': price,
      'disc': disc,
      'total': total,
    };
  }
}

class ReceiptTotal {
  final String label;
  final String value;
  final bool bold;

  ReceiptTotal({required this.label, required this.value, this.bold = false});

  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value, 'bold': bold};
  }
}

class ReceiptOptions {
  final int fontSize;
  final String? fontName;
  final int paperWidth;

  ReceiptOptions({this.fontSize = 24, this.fontName, this.paperWidth = 576});

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      if (fontName != null) 'fontName': fontName,
      'paperWidth': paperWidth,
    };
  }
}
