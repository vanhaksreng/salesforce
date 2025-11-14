import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================================
// 1. KHMER TEXT RENDERER SERVICE
// ============================================================================

class KhmerTextRenderer {
  static const MethodChannel _channel = MethodChannel('khmer_text_renderer');

  /// Render text with specified format via the native plugin.
  static Future<Uint8List?> render(
    String text, {
    OutputFormat format = OutputFormat.png,
    double width = 384,
    double fontSize = 24,
    KhmerTextStyle? style,
    double padding = 10,
    int maxLines = 0,
    bool useCache = true,
  }) async {
    try {
      final result = await _channel.invokeMethod('renderText', {
        'text': text,
        'format': format.value,
        'width': width,
        'fontSize': fontSize,
        'style': style?.toMap(),
        'padding': padding,
        'maxLines': maxLines,
        'useCache': useCache,
      });

      return result as Uint8List?;
    } catch (e) {
      debugPrint('❌ KhmerTextRenderer error: $e');
      return null;
    }
  }

  /// Convenience: Render as ESC/POS (Triggers Native Dynamic Handler)
  static Future<Uint8List?> renderESCPOS(
    String text, {
    double width = 384,
    double fontSize = 24,
    KhmerTextStyle? style,
  }) => render(
    text,
    format: OutputFormat.escpos,
    width: width,
    fontSize: fontSize,
    style: style,
  );

  /// Convenience: Render as PNG (For screen display)
  static Future<Uint8List?> renderPNG(
    String text, {
    double width = 384,
    double fontSize = 24,
    KhmerTextStyle? style,
  }) => render(
    text,
    format: OutputFormat.png,
    width: width,
    fontSize: fontSize,
    style: style,
  );
}

enum OutputFormat {
  png('png'),
  escpos('escpos');

  final String value;
  const OutputFormat(this.value);
}

class KhmerTextStyle {
  final double? fontSize;
  final bool? bold;
  final String? alignment; // 'left', 'center', 'right'
  final bool? monospace;

  const KhmerTextStyle({
    this.fontSize,
    this.bold,
    this.alignment,
    this.monospace,
  });

  Map<String, dynamic> toMap() {
    return {
      if (fontSize != null) 'fontSize': fontSize,
      if (bold != null) 'bold': bold,
      if (alignment != null) 'alignment': alignment,
      if (monospace != null) 'monospace': monospace,
    };
  }
}

// ============================================================================
// 2. BLUETOOTH PRINTER SERVICE
// ============================================================================

class BluetoothPrinter {
  static const MethodChannel _channel = MethodChannel(
    'native_bluetooth_printer',
  );

  /// Scan for Bluetooth devices
  static Future<List<BluetoothDevice>> scanDevices() async {
    try {
      final result = await _channel.invokeMethod('scanDevices');
      final devices = (result as List)
          .map((d) => BluetoothDevice.fromMap(d))
          .toList();
      debugPrint('✅ Found ${devices.length} devices');
      return devices;
    } catch (e) {
      debugPrint('❌ Scan error: $e');
      return [];
    }
  }

  /// Connect to device
  static Future<bool> connect(String address) async {
    try {
      await _channel.invokeMethod('connect', {'address': address});
      debugPrint('✅ Connected to $address');
      return true;
    } catch (e) {
      debugPrint('❌ Connect error: $e');
      return false;
    }
  }

  /// Disconnect from device
  static Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
      debugPrint('✅ Disconnected');
    } catch (e) {
      debugPrint('❌ Disconnect error: $e');
    }
  }

  /// Check if connected
  static Future<bool> isConnected() async {
    try {
      final status = await _channel.invokeMethod('isConnected');
      return status == 'connected';
    } catch (e) {
      return false;
    }
  }

  /// Print raw data
  static Future<bool> printRaw(Uint8List data) async {
    try {
      await _channel.invokeMethod('printRaw', {'data': data});
      debugPrint('✅ Print successful');
      return true;
    } catch (e) {
      debugPrint('❌ Print error: $e');
      return false;
    }
  }
}

class BluetoothDevice {
  final String name;
  final String address;

  BluetoothDevice({required this.name, required this.address});

  factory BluetoothDevice.fromMap(Map<dynamic, dynamic> map) {
    return BluetoothDevice(
      name: map['name'] ?? 'Unknown',
      address: map['address'] ?? '',
    );
  }
}

// ============================================================================
// 3. ESC/POS COMMANDS HELPER (FIXED)
// ============================================================================

class ESCPOSCommands {
  static Uint8List initialize() => Uint8List.fromList([0x1B, 0x40]);
  static Uint8List feedLines(int lines) =>
      Uint8List.fromList([0x1B, 0x64, lines]);
  static Uint8List cutFull() => Uint8List.fromList([0x1D, 0x56, 0x00]);
  static Uint8List cutPartial() => Uint8List.fromList([0x1D, 0x56, 0x01]);

  /// 💡 FINAL FIX: Robustly prints simple ASCII text, ensuring character set isolation.
  static Uint8List printASCII(
    String text, {
    String alignment = 'left',
    bool bold = false,
    int fontSize = 24, // Used to determine double height/width
  }) {
    final builder = BytesBuilder();

    // 1. CRITICAL: Set Code Page 437/USA to prevent Chinese characters
    // This must happen BEFORE the raw text is sent.
    // ESC R 1 (Select International Character Set: USA)
    builder.add([0x1B, 0x52, 0x01]);
    // ESC t 0 (Select Character Code Table: PC437 - standard ASCII)
    builder.add([0x1B, 0x74, 0x00]);

    // 2. Set Alignment (ESC a n)
    int alignValue = 0x00; // 0x00 = left, 0x01 = center, 0x02 = right
    if (alignment == 'center') alignValue = 0x01;
    if (alignment == 'right') alignValue = 0x02;
    builder.add([0x1B, 0x61, alignValue]);

    // 3. Set Bold (ESC E n)
    builder.add([0x1B, 0x45, bold ? 0x01 : 0x00]);

    // 4. Set Font Size (GS !)
    int sizeValue = 0x00;
    if (fontSize > 28)
      sizeValue = 0x11; // Double width and height
    else if (fontSize > 22)
      sizeValue = 0x10; // Double width
    builder.add([0x1D, 0x21, sizeValue]);

    // 5. Add ASCII Text
    // Only includes standard ASCII characters (0-127).
    final asciiBytes = text.codeUnits.where((unit) => unit <= 127).toList();
    builder.add(asciiBytes);

    builder.add([0x0A]); // Line Feed

    // 6. Reset formatting (Bold, Size, Alignment)
    builder.add([0x1B, 0x45, 0x00]); // Bold off
    builder.add([0x1D, 0x21, 0x00]); // Size normal
    builder.add([0x1B, 0x61, 0x00]); // Left align

    // 7. CRITICAL FIX: Re-select the safe code page 437/USA.
    // This is the command that stops the printer from assuming a CJK character set
    // when it prepares for the next line (especially for your image data).
    // builder.add([
    //   0x1B,
    //   0x52,
    //   0x01,
    // ]); // ESC R 1 (Select International Character Set: USA)
    // builder.add([
    //   0x1B,
    //   0x74,
    //   0x00,
    // ]); // ESC t 0 (Select Character Code Table: PC437)

    return builder.toBytes();
  }
}

// ============================================================================
// 4. RECEIPT PRINTER HELPER (OPTIMIZED)
// ============================================================================

class ReceiptPrinter {
  /// Helper to detect non-ASCII characters (e.g., Khmer)
  static bool _containsNonASCII(String text) {
    return text.codeUnits.any((unit) => unit > 127);
  }

  /// The dynamic print data method: Uses Dart-only raw commands if possible (ASCII)
  /// or falls back to native image rendering (Khmer).
  static Future<Uint8List?> _getPrintData(
    String text, {
    double width = 384,
    double fontSize = 24,
    KhmerTextStyle? style,
  }) async {
    // 1. FAST PATH: Pure ASCII (English, numbers) - Dart only
    if (!_containsNonASCII(text)) {
      debugPrint('⚡ Printing pure ASCII text directly in Dart.');
      return ESCPOSCommands.printASCII(
        text,
        alignment: style?.alignment ?? 'left',
        bold: style?.bold ?? false,
        fontSize: fontSize.toInt(),
      );
    }
    // 2. SLOW PATH: Non-ASCII (Khmer) - Native image rendering
    else {
      debugPrint('🖼️ Printing non-ASCII text via native image rendering.');
      return await KhmerTextRenderer.renderESCPOS(
        text,
        width: width,
        fontSize: fontSize,
        style: style,
      );
    }
  }

  /// Print a simple Khmer receipt
  static Future<bool> printKhmerReceipt({
    required String storeName,
    required String address,
    required List<ReceiptItem> items,
    required String total,
  }) async {
    try {
      final receipt = BytesBuilder();
      receipt.add(ESCPOSCommands.initialize());

      // 1. Store name (uses fast/slow path dynamically)
      final storeTitleData = await _getPrintData(
        storeName,
        fontSize: 32,
        style: KhmerTextStyle(bold: true, alignment: 'center'),
      );
      if (storeTitleData != null) receipt.add(storeTitleData);

      // 2. Address (uses fast/slow path dynamically)
      final addressData = await _getPrintData(
        address,
        fontSize: 20,
        style: KhmerTextStyle(alignment: 'center'),
      );
      if (addressData != null) receipt.add(addressData);

      // 3. Separator
      receipt.add(ESCPOSCommands.feedLines(1));

      // 4. Items
      for (final item in items) {
        // This item line contains both text and a price. If item.name is Khmer,
        // it uses image. If item.name and price are ASCII, it uses the fast Dart path.
        final itemData = await _getPrintData(
          '${item.name}  ${item.price}',
          width: 384,
          fontSize: 20,
        );
        if (itemData != null) receipt.add(itemData);
      }

      // 5. Separator
      receipt.add(ESCPOSCommands.feedLines(1));

      // 6. Total
      final totalData = await _getPrintData(
        'សរុប: $total',
        fontSize: 28,
        style: KhmerTextStyle(bold: true, alignment: 'right'),
      );
      if (totalData != null) receipt.add(totalData);

      // 7. Thank you message
      final thankYouData = await _getPrintData(
        'សូមអរគុណ',
        fontSize: 24,
        style: KhmerTextStyle(bold: true, alignment: 'center'),
      );
      if (thankYouData != null) receipt.add(thankYouData);

      // 8. Feed and cut
      receipt.add(ESCPOSCommands.feedLines(3));
      receipt.add(ESCPOSCommands.cutFull());

      // 9. Print
      return await BluetoothPrinter.printRaw(receipt.toBytes());
    } catch (e) {
      debugPrint('❌ Print error: $e');
      return false;
    }
  }
}

class ReceiptItem {
  final String name;
  final String price;

  ReceiptItem({required this.name, required this.price});
}

// ============================================================================
// 5. EXAMPLE USAGE - COMPLETE PRINTING SCREEN
// ============================================================================

class KhmerPrintingScreen extends StatefulWidget {
  @override
  _KhmerPrintingScreenState createState() => _KhmerPrintingScreenState();
}

class _KhmerPrintingScreenState extends State<KhmerPrintingScreen> {
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  bool isScanning = false;
  bool isConnected = false;
  bool isPrinting = false;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    final connected = await BluetoothPrinter.isConnected();
    setState(() => isConnected = connected);
  }

  Future<void> scanForDevices() async {
    setState(() => isScanning = true);
    final foundDevices = await BluetoothPrinter.scanDevices();
    setState(() {
      devices = foundDevices;
      isScanning = false;
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    final success = await BluetoothPrinter.connect(device.address);
    if (success) {
      setState(() {
        selectedDevice = device;
        isConnected = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Connected to ${device.name}')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Connection failed')));
    }
  }

  Future<void> disconnect() async {
    await BluetoothPrinter.disconnect();
    setState(() {
      isConnected = false;
      selectedDevice = null;
    });
  }

  Future<void> printTestReceipt() async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Please connect to printer first')),
      );
      return;
    }

    setState(() => isPrinting = true);

    // This data will test the dynamic handler:
    final success = await ReceiptPrinter.printKhmerReceipt(
      storeName: 'ហាងលក់របស់យើង COFFEE',
      address: 'Phnom Penh, Cambodia 012 345 678',
      items: [
        ReceiptItem(name: 'កាហ្វេ', price: '\$2.50'),
        ReceiptItem(name: 'Bread', price: '\$1.00'),
        ReceiptItem(name: 'ទឹកក្រូច', price: '\$1.50'),
      ],
      total: 'សរុប: \$5.00',
    );

    setState(() => isPrinting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '✅ Print successful' : '❌ Print failed'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Khmer Bluetooth Printer'),
        actions: [
          if (isConnected)
            IconButton(
              icon: Icon(Icons.bluetooth_connected),
              onPressed: disconnect,
              tooltip: 'Disconnect',
            ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status
          Container(
            padding: EdgeInsets.all(16),
            color: isConnected ? Colors.green[100] : Colors.grey[200],
            child: Row(
              children: [
                Icon(
                  isConnected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  color: isConnected ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 8),
                Text(
                  isConnected
                      ? 'Connected to ${selectedDevice?.name ?? "printer"}'
                      : 'Not connected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isConnected ? Colors.green[900] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Scan Button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: isScanning ? null : scanForDevices,
              icon: Icon(isScanning ? Icons.hourglass_empty : Icons.search),
              label: Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),

          // Device List
          Expanded(
            child: devices.isEmpty
                ? Center(
                    child: Text(
                      'No devices found\nTap "Scan for Devices" to start',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      final isSelected =
                          selectedDevice?.address == device.address;

                      return ListTile(
                        leading: Icon(
                          Icons.print,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        title: Text(device.name),
                        subtitle: Text(device.address),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        onTap: () => connectToDevice(device),
                      );
                    },
                  ),
          ),

          // Print Test Button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: isConnected && !isPrinting ? printTestReceipt : null,
              icon: Icon(isPrinting ? Icons.hourglass_empty : Icons.print),
              label: Text(isPrinting ? 'Printing...' : 'Print Test Receipt'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. QUICK USAGE EXAMPLES
// ============================================================================

class QuickExamples {
  /// Example 1: Simple text print (If Khmer, uses image. If ASCII, uses raw Dart.)
  static Future<void> printSimpleText() async {
    // 1. Get the print data using the dynamic router
    // Use a pure ASCII string to test the FAST PATH (Dart-only printASCII)
    final data = await ReceiptPrinter._getPrintData(
      'សរុប', // Simple Khmer word
      fontSize: 24,
      style: KhmerTextStyle(alignment: 'center'),
    );

    if (data != null) {
      final receipt = BytesBuilder();

      // 2. Add INIT command
      receipt.add(ESCPOSCommands.initialize());

      // 3. Add the actual text data
      receipt.add(data);

      // 4. Add feed and cut
      receipt.add(ESCPOSCommands.feedLines(3));
      receipt.add(ESCPOSCommands.cutFull());

      // 5. Send to printer
      await BluetoothPrinter.printRaw(receipt.toBytes());
    } else {
      debugPrint('❌ Failed to generate print data for Simple Text.');
    }
  }

  /// Example 2: Mixed language receipt (Uses the optimized _getPrintData)
  static Future<void> printMixedReceipt() async {
    final receipt = BytesBuilder();
    receipt.add(ESCPOSCommands.initialize());

    // Khmer header (via image)
    final header = await ReceiptPrinter._getPrintData(
      'ឈ្លោះ​គ្នា​ក្នុង​គ្រួបច្ចា​ឥត​អាវុធ-hahahaha',
      fontSize: 24,
      width: 576,
      style: KhmerTextStyle(bold: true, alignment: 'left'),
    );
    if (header != null) receipt.add(header);

    // English subtitle (via raw Dart ASCII)
    final subtitle = await ReceiptPrinter._getPrintData(
      'Coffee Shop',
      fontSize: 20,
      style: KhmerTextStyle(alignment: 'center'),
    );
    
    if (subtitle != null) receipt.add(subtitle);

    receipt.add(ESCPOSCommands.feedLines(3));
    receipt.add(ESCPOSCommands.cutFull());

    // receipt.add(ESCPOSCommands.initialize());
    await BluetoothPrinter.printRaw(receipt.toBytes());
  }
}

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// // ============================================================================
// // 1. KHMER TEXT RENDERER SERVICE
// // ============================================================================

// class KhmerTextRenderer {
//   static const MethodChannel _channel = MethodChannel('khmer_text_renderer');

//   /// Render Khmer text with specified format
//   static Future<Uint8List?> render(
//     String text, {
//     OutputFormat format = OutputFormat.png,
//     double width = 384,
//     double fontSize = 24,
//     KhmerTextStyle? style,
//     double padding = 10,
//     int maxLines = 0,
//     bool useCache = true,
//   }) async {
//     try {
//       final result = await _channel.invokeMethod('renderText', {
//         'text': text,
//         'format': format.value,
//         'width': width,
//         'fontSize': fontSize,
//         'style': style?.toMap(),
//         'padding': padding,
//         'maxLines': maxLines,
//         'useCache': useCache,
//       });

//       return result as Uint8List?;
//     } catch (e) {
//       debugPrint('❌ KhmerTextRenderer error: $e');
//       return null;
//     }
//   }

//   /// Convenience: Render as PNG
//   static Future<Uint8List?> renderPNG(
//     String text, {
//     double width = 384,
//     double fontSize = 24,
//     KhmerTextStyle? style,
//   }) => render(
//     text,
//     format: OutputFormat.png,
//     width: width,
//     fontSize: fontSize,
//     style: style,
//   );

//   /// Convenience: Render as ESC/POS
//   static Future<Uint8List?> renderESCPOS(
//     String text, {
//     double width = 384,
//     double fontSize = 24,
//     KhmerTextStyle? style,
//   }) => render(
//     text,
//     format: OutputFormat.escpos,
//     width: width,
//     fontSize: fontSize,
//     style: style,
//   );
// }

// enum OutputFormat {
//   png('png'),
//   escpos('escpos');

//   final String value;
//   const OutputFormat(this.value);
// }

// class KhmerTextStyle {
//   final double? fontSize;
//   final bool? bold;
//   final String? alignment; // 'left', 'center', 'right'
//   final bool? monospace;

//   const KhmerTextStyle({
//     this.fontSize,
//     this.bold,
//     this.alignment,
//     this.monospace,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       if (fontSize != null) 'fontSize': fontSize,
//       if (bold != null) 'bold': bold,
//       if (alignment != null) 'alignment': alignment,
//       if (monospace != null) 'monospace': monospace,
//     };
//   }
// }

// // ============================================================================
// // 2. BLUETOOTH PRINTER SERVICE
// // ============================================================================

// class BluetoothPrinter {
//   static const MethodChannel _channel = MethodChannel(
//     'native_bluetooth_printer',
//   );

//   /// Scan for Bluetooth devices
//   static Future<List<BluetoothDevice>> scanDevices() async {
//     try {
//       final result = await _channel.invokeMethod('scanDevices');
//       final devices = (result as List)
//           .map((d) => BluetoothDevice.fromMap(d))
//           .toList();
//       debugPrint('✅ Found ${devices.length} devices');
//       return devices;
//     } catch (e) {
//       debugPrint('❌ Scan error: $e');
//       return [];
//     }
//   }

//   /// Connect to device
//   static Future<bool> connect(String address) async {
//     try {
//       await _channel.invokeMethod('connect', {'address': address});
//       debugPrint('✅ Connected to $address');
//       return true;
//     } catch (e) {
//       debugPrint('❌ Connect error: $e');
//       return false;
//     }
//   }

//   /// Disconnect from device
//   static Future<void> disconnect() async {
//     try {
//       await _channel.invokeMethod('disconnect');
//       debugPrint('✅ Disconnected');
//     } catch (e) {
//       debugPrint('❌ Disconnect error: $e');
//     }
//   }

//   /// Check if connected
//   static Future<bool> isConnected() async {
//     try {
//       final status = await _channel.invokeMethod('isConnected');
//       return status == 'connected';
//     } catch (e) {
//       return false;
//     }
//   }

//   /// Print raw data
//   static Future<bool> printRaw(Uint8List data) async {
//     try {
//       await _channel.invokeMethod('printRaw', {'data': data});
//       debugPrint('✅ Print successful');
//       return true;
//     } catch (e) {
//       debugPrint('❌ Print error: $e');
//       return false;
//     }
//   }
// }

// class BluetoothDevice {
//   final String name;
//   final String address;

//   BluetoothDevice({required this.name, required this.address});

//   factory BluetoothDevice.fromMap(Map<dynamic, dynamic> map) {
//     return BluetoothDevice(
//       name: map['name'] ?? 'Unknown',
//       address: map['address'] ?? '',
//     );
//   }
// }

// // ============================================================================
// // 3. ESC/POS COMMANDS HELPER
// // ============================================================================

// class ESCPOSCommands {
//   static Uint8List initialize() => Uint8List.fromList([0x1B, 0x40]);
//   static Uint8List feedLines(int lines) =>
//       Uint8List.fromList([0x1B, 0x64, lines]);
//   static Uint8List cutFull() => Uint8List.fromList([0x1D, 0x56, 0x00]);
//   static Uint8List cutPartial() => Uint8List.fromList([0x1D, 0x56, 0x01]);
// }

// // ============================================================================
// // 4. RECEIPT PRINTER HELPER
// // ============================================================================

// class ReceiptPrinter {
//   /// Print a simple Khmer receipt
//   static Future<bool> printKhmerReceipt({
//     required String storeName,
//     required String address,
//     required List<ReceiptItem> items,
//     required String total,
//   }) async {
//     try {
//       final receipt = BytesBuilder();

//       // 1. Initialize
//       receipt.add(ESCPOSCommands.initialize());

//       // 2. Store name (large, bold, centered)
//       final storeTitleData = await KhmerTextRenderer.renderESCPOS(
//         storeName,
//         width: 384,
//         fontSize: 32,
//         style: KhmerTextStyle(bold: true, alignment: 'center'),
//       );
//       if (storeTitleData != null) receipt.add(storeTitleData);

//       // 3. Address (centered)
//       final addressData = await KhmerTextRenderer.renderESCPOS(
//         address,
//         width: 384,
//         fontSize: 20,
//         style: KhmerTextStyle(alignment: 'center'),
//       );
//       if (addressData != null) receipt.add(addressData);

//       // 4. Separator
//       receipt.add(ESCPOSCommands.feedLines(1));

//       // 5. Items
//       for (final item in items) {
//         final itemData = await KhmerTextRenderer.renderESCPOS(
//           '${item.name}  ${item.price}',
//           width: 384,
//           fontSize: 20,
//         );
//         if (itemData != null) receipt.add(itemData);
//       }

//       // 6. Separator
//       receipt.add(ESCPOSCommands.feedLines(1));

//       // 7. Total (bold, larger)
//       final totalData = await KhmerTextRenderer.renderESCPOS(
//         'សរុប: $total',
//         width: 384,
//         fontSize: 28,
//         style: KhmerTextStyle(bold: true, alignment: 'right'),
//       );
//       if (totalData != null) receipt.add(totalData);

//       // 8. Thank you message
//       final thankYouData = await KhmerTextRenderer.renderESCPOS(
//         'សូមអរគុណ',
//         width: 384,
//         fontSize: 24,
//         style: KhmerTextStyle(bold: true, alignment: 'center'),
//       );
//       if (thankYouData != null) receipt.add(thankYouData);

//       // 9. Feed and cut
//       receipt.add(ESCPOSCommands.feedLines(3));
//       receipt.add(ESCPOSCommands.cutFull());

//       // 10. Print
//       return await BluetoothPrinter.printRaw(receipt.toBytes());
//     } catch (e) {
//       debugPrint('❌ Print error: $e');
//       return false;
//     }
//   }
// }

// class ReceiptItem {
//   final String name;
//   final String price;

//   ReceiptItem({required this.name, required this.price});
// }

// // ============================================================================
// // 5. EXAMPLE USAGE - COMPLETE PRINTING SCREEN
// // ============================================================================

// class KhmerPrintingScreen extends StatefulWidget {
//   @override
//   _KhmerPrintingScreenState createState() => _KhmerPrintingScreenState();
// }

// class _KhmerPrintingScreenState extends State<KhmerPrintingScreen> {
//   List<BluetoothDevice> devices = [];
//   BluetoothDevice? selectedDevice;
//   bool isScanning = false;
//   bool isConnected = false;
//   bool isPrinting = false;

//   @override
//   void initState() {
//     super.initState();
//     checkConnection();
//   }

//   Future<void> checkConnection() async {
//     final connected = await BluetoothPrinter.isConnected();
//     setState(() => isConnected = connected);
//   }

//   Future<void> scanForDevices() async {
//     setState(() => isScanning = true);
//     final foundDevices = await BluetoothPrinter.scanDevices();
//     setState(() {
//       devices = foundDevices;
//       isScanning = false;
//     });
//   }

//   Future<void> connectToDevice(BluetoothDevice device) async {
//     final success = await BluetoothPrinter.connect(device.address);
//     if (success) {
//       setState(() {
//         selectedDevice = device;
//         isConnected = true;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('✅ Connected to ${device.name}')));
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('❌ Connection failed')));
//     }
//   }

//   Future<void> disconnect() async {
//     await BluetoothPrinter.disconnect();
//     setState(() {
//       isConnected = false;
//       selectedDevice = null;
//     });
//   }

//   Future<void> printTestReceipt() async {
//     if (!isConnected) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Please connect to printer first')),
//       );
//       return;
//     }

//     setState(() => isPrinting = true);

//     final success = await ReceiptPrinter.printKhmerReceipt(
//       storeName: 'ហាងលក់របស់យើង',
//       address: 'ភ្នំពេញ ប្រទេសកម្ពុជា',
//       items: [
//         ReceiptItem(name: 'កាហ្វេ', price: '\$2.50'),
//         ReceiptItem(name: 'នំបុ័ង', price: '\$1.00'),
//         ReceiptItem(name: 'ទឹកក្រូច', price: '\$1.50'),
//       ],
//       total: '\$5.00',
//     );

//     setState(() => isPrinting = false);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(success ? '✅ Print successful' : '❌ Print failed'),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Khmer Bluetooth Printer'),
//         actions: [
//           if (isConnected)
//             IconButton(
//               icon: Icon(Icons.bluetooth_connected),
//               onPressed: disconnect,
//               tooltip: 'Disconnect',
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Connection Status
//           Container(
//             padding: EdgeInsets.all(16),
//             color: isConnected ? Colors.green[100] : Colors.grey[200],
//             child: Row(
//               children: [
//                 Icon(
//                   isConnected
//                       ? Icons.bluetooth_connected
//                       : Icons.bluetooth_disabled,
//                   color: isConnected ? Colors.green : Colors.grey,
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   isConnected
//                       ? 'Connected to ${selectedDevice?.name ?? "printer"}'
//                       : 'Not connected',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: isConnected ? Colors.green[900] : Colors.grey[700],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Scan Button
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: ElevatedButton.icon(
//               onPressed: isScanning ? null : scanForDevices,
//               icon: Icon(isScanning ? Icons.hourglass_empty : Icons.search),
//               label: Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: Size(double.infinity, 50),
//               ),
//             ),
//           ),

//           // Device List
//           Expanded(
//             child: devices.isEmpty
//                 ? Center(
//                     child: Text(
//                       'No devices found\nTap "Scan for Devices" to start',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: devices.length,
//                     itemBuilder: (context, index) {
//                       final device = devices[index];
//                       final isSelected =
//                           selectedDevice?.address == device.address;

//                       return ListTile(
//                         leading: Icon(
//                           Icons.print,
//                           color: isSelected ? Colors.blue : Colors.grey,
//                         ),
//                         title: Text(device.name),
//                         subtitle: Text(device.address),
//                         trailing: isSelected
//                             ? Icon(Icons.check_circle, color: Colors.green)
//                             : null,
//                         onTap: () => connectToDevice(device),
//                       );
//                     },
//                   ),
//           ),

//           // Print Test Button
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: ElevatedButton.icon(
//               onPressed: isConnected && !isPrinting ? printTestReceipt : null,
//               icon: Icon(isPrinting ? Icons.hourglass_empty : Icons.print),
//               label: Text(isPrinting ? 'Printing...' : 'Print Test Receipt'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: Size(double.infinity, 50),
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ============================================================================
// // 6. QUICK USAGE EXAMPLES
// // ============================================================================

// class QuickExamples {
//   /// Example 1: Simple text print
//   static Future<void> printSimpleText() async {
//     final data = await KhmerTextRenderer.renderESCPOS(
//       'សូមស្វាគមន៍',
//       fontSize: 24,
//     );

//     if (data != null) {
//       final receipt = BytesBuilder();
//       receipt.add(ESCPOSCommands.initialize());
//       receipt.add(data);
//       receipt.add(ESCPOSCommands.feedLines(3));
//       receipt.add(ESCPOSCommands.cutFull());

//       await BluetoothPrinter.printRaw(receipt.toBytes());
//     }
//   }

//   /// Example 2: Display image in Flutter
//   static Future<Widget?> displayKhmerText(String text) async {
//     final pngData = await KhmerTextRenderer.renderPNG(
//       text,
//       fontSize: 24,
//       style: KhmerTextStyle(alignment: 'center'),
//     );

//     if (pngData != null) {
//       return Image.memory(pngData);
//     }
//     return null;
//   }

//   /// Example 3: Mixed language receipt
//   static Future<void> printMixedReceipt() async {
//     final receipt = BytesBuilder();
//     receipt.add(ESCPOSCommands.initialize());

//     // Khmer header
//     final header = await KhmerTextRenderer.renderESCPOS(
//       'ហាងកាហ្វេ',
//       fontSize: 32,
//       style: KhmerTextStyle(bold: true, alignment: 'center'),
//     );
//     if (header != null) receipt.add(header);

//     // English subtitle (can be rendered as image too)
//     final subtitle = await KhmerTextRenderer.renderESCPOS(
//       'Coffee Shop',
//       fontSize: 20,
//       style: KhmerTextStyle(alignment: 'center'),
//     );
//     if (subtitle != null) receipt.add(subtitle);

//     receipt.add(ESCPOSCommands.feedLines(3));
//     receipt.add(ESCPOSCommands.cutFull());

//     await BluetoothPrinter.printRaw(receipt.toBytes());
//   }
// }
