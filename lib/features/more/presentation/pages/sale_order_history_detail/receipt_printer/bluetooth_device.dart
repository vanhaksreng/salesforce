// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
// import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_builder.dart';
// import 'package:salesforce/realm/scheme/schemas.dart';

// class ESCPOSPrinter {
//   static const MethodChannel _channel = MethodChannel(
//     'native_bluetooth_printer',
//   );

//   static Future<List<BluetoothDevice>> scanDevices({int timeout = 10}) async {
//     try {
//       debugPrint("🔍 Scanning for Bluetooth devices...");
//       final List<dynamic>? devices = await _channel.invokeMethod(
//         'scanDevices',
//         {'timeout': timeout},
//       );

//       if (devices == null) return [];

//       return devices.map((device) {
//         return BluetoothDevice(
//           name: device['name'] ?? 'Unknown',
//           address: device['address'] ?? '',
//         );
//       }).toList();
//     } catch (e) {
//       debugPrint("❌ Error scanning devices: $e");
//       return [];
//     }
//   }

//   static Future<bool> connect(String address) async {
//     try {
//       debugPrint("🔗 Connecting to device: $address");
//       final bool? result = await _channel.invokeMethod('connect', {
//         'address': address,
//       });
//       return result ?? false;
//     } catch (e) {
//       debugPrint("❌ Error connecting: $e");
//       return false;
//     }
//   }

//   static Future<void> disconnect() async {
//     try {
//       await _channel.invokeMethod('disconnect');
//       debugPrint("🔌 Disconnected from printer");
//     } catch (e) {
//       debugPrint("❌ Error disconnecting: $e");
//     }
//   }

//   static Future<bool> isConnected() async {
//     try {
//       final bool? result = await _channel.invokeMethod('isConnected');
//       return result ?? false;
//     } catch (e) {
//       debugPrint("❌ Error checking connection: $e");
//       return false;
//     }
//   }

//   static Future<bool> printRaw(Uint8List? data) async {
//     try {
//       final bool? result = await _channel.invokeMethod('printRaw', {
//         'data': data,
//       });
//       return result ?? false;
//     } catch (e) {
//       debugPrint("❌ Error printing raw data: $e");
//       return false;
//     }
//   }

//   // static Future<bool> printReceiptImage(Uint8List pngData) async {
//   //   try {
//   //     // Convert PNG to ESC/POS bitmap format
//   //     final escPosData = _convertImageToEscPos(pngData);

//   //     // Send to printer
//   //     return await printRaw(escPosData);
//   //   } catch (e) {
//   //     debugPrint("❌ Error printing receipt: $e");
//   //     return false;
//   //   }
//   // }

//   // /// Send raw data to printer (used internally)

//   // /// Convert PNG image to ESC/POS bitmap format
//   // static Uint8List _convertImageToEscPos(Uint8List pngData) {
//   //   // Decode PNG image
//   //   final image = img.decodePng(pngData);
//   //   if (image == null) {
//   //     throw Exception('Failed to decode PNG image');
//   //   }

//   //   // Convert to monochrome (black & white)
//   //   final monoImage = _convertToMonochrome(image);

//   //   // Build ESC/POS commands
//   //   final escPos = BytesBuilder();

//   //   // Initialize printer
//   //   escPos.add([0x1B, 0x40]); // ESC @ - Initialize

//   //   // Set line spacing to 0 for tight image printing
//   //   escPos.add([0x1B, 0x33, 0x00]); // ESC 3 0

//   //   final width = monoImage.width;
//   //   final height = monoImage.height;

//   //   print('📄 Converting image: ${width}x${height}px');

//   //   // Print image using ESC * command (24-dot graphics)
//   //   for (int y = 0; y < height; y += 24) {
//   //     // ESC * m nL nH [data...]
//   //     escPos.add([0x1B, 0x2A, 33]); // ESC * 33 (24-dot double-density)

//   //     // Width in little-endian format
//   //     escPos.add([width % 256, width ~/ 256]);

//   //     // Process 24 rows of pixels (3 bytes per column)
//   //     for (int x = 0; x < width; x++) {
//   //       int byte1 = 0, byte2 = 0, byte3 = 0;

//   //       // First 8 dots
//   //       for (int bit = 0; bit < 8; bit++) {
//   //         if (y + bit < height && _isBlackPixel(monoImage, x, y + bit)) {
//   //           byte1 |= (1 << (7 - bit));
//   //         }
//   //       }

//   //       // Second 8 dots
//   //       for (int bit = 0; bit < 8; bit++) {
//   //         if (y + 8 + bit < height &&
//   //             _isBlackPixel(monoImage, x, y + 8 + bit)) {
//   //           byte2 |= (1 << (7 - bit));
//   //         }
//   //       }

//   //       // Third 8 dots
//   //       for (int bit = 0; bit < 8; bit++) {
//   //         if (y + 16 + bit < height &&
//   //             _isBlackPixel(monoImage, x, y + 16 + bit)) {
//   //           byte3 |= (1 << (7 - bit));
//   //         }
//   //       }

//   //       escPos.addByte(byte1);
//   //       escPos.addByte(byte2);
//   //       escPos.addByte(byte3);
//   //     }

//   //     // Line feed after each 24-dot line
//   //     escPos.addByte(0x0A);
//   //   }

//   //   // Reset line spacing to default
//   //   escPos.add([0x1B, 0x32]); // ESC 2

//   //   // Add extra line feeds for paper separation
//   //   escPos.add([0x0A, 0x0A, 0x0A]);

//   //   // Cut paper (if supported)
//   //   escPos.add([0x1D, 0x56, 0x00]); // GS V 0 - Full cut

//   //   final result = escPos.toBytes();
//   //   print('✅ Converted to ESC/POS: ${result.length} bytes');

//   //   return result;
//   // }

//   // /// Convert image to pure black and white
//   // static img.Image _convertToMonochrome(img.Image image) {
//   //   final mono = img.Image(width: image.width, height: image.height);

//   //   for (int y = 0; y < image.height; y++) {
//   //     for (int x = 0; x < image.width; x++) {
//   //       final pixel = image.getPixel(x, y);

//   //       // Calculate brightness (weighted average for better results)
//   //       final brightness = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114)
//   //           .round();

//   //       // Threshold with dithering for better quality
//   //       final threshold = 128;
//   //       final color = brightness < threshold
//   //           ? img.ColorRgb8(0, 0, 0) // Black
//   //           : img.ColorRgb8(255, 255, 255); // White

//   //       mono.setPixel(x, y, color);
//   //     }
//   //   }

//   //   return mono;
//   // }

//   // /// Check if pixel should be printed as black
//   // static bool _isBlackPixel(img.Image image, int x, int y) {
//   //   final pixel = image.getPixel(x, y);
//   //   final brightness = (pixel.r + pixel.g + pixel.b) / 3;
//   //   return brightness < 128; // Black if darker than middle gray
//   // }

//   // /// Alternative: Convert with Floyd-Steinberg dithering for better quality
//   // static img.Image _convertToMonochromeWithDithering(img.Image image) {
//   //   final mono = img.Image(width: image.width, height: image.height);

//   //   // Copy pixels to buffer for dithering
//   //   final buffer = List.generate(
//   //     image.height,
//   //     (y) => List.generate(image.width, (x) {
//   //       final pixel = image.getPixel(x, y);
//   //       return (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114).round();
//   //     }),
//   //   );

//   //   // Floyd-Steinberg dithering
//   //   for (int y = 0; y < image.height; y++) {
//   //     for (int x = 0; x < image.width; x++) {
//   //       final oldPixel = buffer[y][x];
//   //       final newPixel = oldPixel < 128 ? 0 : 255;
//   //       buffer[y][x] = newPixel;

//   //       final error = oldPixel - newPixel;

//   //       // Distribute error to neighboring pixels
//   //       if (x + 1 < image.width) {
//   //         buffer[y][x + 1] = (buffer[y][x + 1] + error * 7 / 16)
//   //             .clamp(0, 255)
//   //             .round();
//   //       }
//   //       if (y + 1 < image.height) {
//   //         if (x > 0) {
//   //           buffer[y + 1][x - 1] = (buffer[y + 1][x - 1] + error * 3 / 16)
//   //               .clamp(0, 255)
//   //               .round();
//   //         }
//   //         buffer[y + 1][x] = (buffer[y + 1][x] + error * 5 / 16)
//   //             .clamp(0, 255)
//   //             .round();
//   //         if (x + 1 < image.width) {
//   //           buffer[y + 1][x + 1] = (buffer[y + 1][x + 1] + error * 1 / 16)
//   //               .clamp(0, 255)
//   //               .round();
//   //         }
//   //       }

//   //       // Set pixel
//   //       final color = newPixel == 0
//   //           ? img.ColorRgb8(0, 0, 0)
//   //           : img.ColorRgb8(255, 255, 255);
//   //       mono.setPixel(x, y, color);
//   //     }
//   //   }

//   //   return mono;
//   // }
// }
