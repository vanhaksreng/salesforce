import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
// Optional: For saving to gallery
// import 'package:image_gallery_saver/image_gallery_saver.dart';

class PrintPreviewData {
  final img.Image image;
  final Uint8List printCommands;

  PrintPreviewData({
    required this.image,
    required this.printCommands,
  });
}

/// Print method options
enum PrintMethod {
  simple,          // ESC * 0 - Single density
  gsv,             // GS v 0 - WORKS FOR XP-P323B ✅
  doubleDensity,   // ESC * 33 - Higher quality but less compatible
}

class ThermalPrintHelper {
  /// Convert text to ESC/POS image commands for thermal printer
  /// Supports Khmer and mixed languages
  /// Returns both the image (for preview) and print commands
  static Future<PrintPreviewData> convertTextToImageCommands(
    String text, {
    double fontSize = 24,
    int paperWidth = 384, // 48mm paper (384 dots)
    FontWeight fontWeight = FontWeight.normal,
    double lineHeight = 1.2,
    PrintMethod method = PrintMethod.gsv, // GS v 0 works best for XP-P323B
  }) async {
    // Step 1: Render text to image
    final image = await _renderTextToImage(
      text,
      fontSize: fontSize,
      paperWidth: paperWidth,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
    );

    // Step 2: Convert to ESC/POS bitmap commands
    Uint8List commands;
    switch (method) {
      case PrintMethod.simple:
        commands = _convertToESCPOSBitmapSimple(image);
        break;
      case PrintMethod.gsv:
        commands = _convertToESCPOSBitmapAlt(image); // This one works!
        break;
      case PrintMethod.doubleDensity:
        commands = _convertToESCPOSBitmap(image);
        break;
    }

    return PrintPreviewData(
      image: image,
      printCommands: commands,
    );
  }



  /// Render text widget to image
  static Future<img.Image> _renderTextToImage(
    String text, {
    required double fontSize,
    required int paperWidth,
    required FontWeight fontWeight,
    required double lineHeight,
  }) async {
    // Create text painter
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: lineHeight, // Use adjustable line height
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    textPainter.layout(maxWidth: paperWidth.toDouble() - 16); // Less padding

    final height = textPainter.height.ceil() + 10; // Less vertical padding

    // Create picture recorder
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, paperWidth.toDouble(), height.toDouble()),
      Paint()..color = Colors.white,
    );

    // Draw text
    textPainter.paint(canvas, const Offset(8, 5)); // Less padding

    // Convert to image
    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(paperWidth, height);
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

    // Convert to image package format
    final pngBytes = byteData!.buffer.asUint8List();
    final decodedImage = img.decodeImage(pngBytes)!;

    // Convert to monochrome (black and white only)
    final bwImage = img.grayscale(decodedImage);

    return bwImage;
  }

  /// Convert image to ESC/POS bitmap commands
  static Uint8List _convertToESCPOSBitmap(img.Image image) {
    final width = image.width;
    final height = image.height;

    // ESC/POS expects width to be multiple of 8
    final adjustedWidth = ((width + 7) ~/ 8) * 8;
    final bytesPerLine = adjustedWidth ~/ 8;

    final commands = <int>[];

    // ESC @ - Initialize printer
    commands.addAll([0x1B, 0x40]);

    // Set line spacing to minimum for tighter output
    commands.addAll([0x1B, 0x33, 0x00]);

    // Process image line by line using ESC * command
    for (int y = 0; y < height; y++) {
      // ESC * m nL nH d1...dk
      // m = 33 (24-dot double-density) - better quality
      commands.addAll([
        0x1B, 0x2A, 0x21, // ESC * 33 (24-dot double-density)
        bytesPerLine & 0xFF, // nL - low byte
        (bytesPerLine >> 8) & 0xFF, // nH - high byte
      ]);

      // Convert pixels to bytes
      final lineBytes = <int>[];
      for (int x = 0; x < adjustedWidth; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          final pixelX = x + bit;
          if (pixelX < width) {
            final pixel = image.getPixel(pixelX, y);
            final luminance = img.getLuminance(pixel);
            // Black pixel if luminance < 128
            if (luminance < 128) {
              byte |= (0x80 >> bit); // Set bit from left to right
            }
          }
        }
        lineBytes.add(byte);
      }
      
      commands.addAll(lineBytes);
      commands.add(0x0A); // Line feed
    }

    // Reset line spacing to default
    commands.addAll([0x1B, 0x32]);

    // Single line feed before cut
    commands.add(0x0A);

    // Partial cut command - GS V B 0
    commands.addAll([0x1D, 0x56, 0x42, 0x00]);

    return Uint8List.fromList(commands);
  }

  /// Alternative bitmap method using GS v 0 command
  /// Works better for XP-P323B and similar printers
  static Uint8List _convertToESCPOSBitmapAlt(img.Image image) {
    final width = image.width;
    final height = image.height;

    // Width must be multiple of 8
    final adjustedWidth = ((width + 7) ~/ 8) * 8;
    final widthBytes = adjustedWidth ~/ 8;

    final commands = <int>[];

    // ESC @ - Initialize
    commands.addAll([0x1B, 0x40]);

    // Collect all pixel data
    final pixelData = <int>[];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < adjustedWidth; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          final pixelX = x + bit;
          if (pixelX < width) {
            final pixel = image.getPixel(pixelX, y);
            final luminance = img.getLuminance(pixel);
            if (luminance < 128) {
              byte |= (0x80 >> bit);
            }
          }
        }
        pixelData.add(byte);
      }
    }

    // GS v 0 m xL xH yL yH d1...dk
    commands.addAll([
      0x1D, 0x76, 0x30, 0x00, // GS v 0 (normal mode)
      widthBytes & 0xFF, // xL
      (widthBytes >> 8) & 0xFF, // xH
      height & 0xFF, // yL
      (height >> 8) & 0xFF, // yH
    ]);

    commands.addAll(pixelData);
    commands.add(0x0A);

    // Cut
    commands.addAll([0x1D, 0x56, 0x42, 0x00]);

    return Uint8List.fromList(commands);
  }

  /// Method 3: Using ESC * with single density (most compatible)
  /// Recommended for XP-P323B
  static Uint8List _convertToESCPOSBitmapSimple(img.Image image) {
    final width = image.width;
    final height = image.height;

    final commands = <int>[];

    // ESC @ - Initialize
    commands.addAll([0x1B, 0x40]);
    
    // Set print density (darker) - GS ( K (optional, if supported)
    // commands.addAll([0x1D, 0x28, 0x4B, 0x02, 0x00, 0x32, 0x20]); // Max density

    // Process each line
    for (int y = 0; y < height; y++) {
      final lineData = <int>[];
      
      // Process pixels in groups of 8
      for (int x = 0; x < width; x += 8) {
        int byte = 0;
        
        for (int bit = 0; bit < 8; bit++) {
          if (x + bit < width) {
            final pixel = image.getPixel(x + bit, y);
            final luminance = img.getLuminance(pixel);
            
            // Lower threshold = more black pixels (darker print)
            // Changed from 128 to 160 for darker output
            if (luminance < 160) { 
              byte |= (1 << (7 - bit)); // MSB first
            }
          }
        }
        
        lineData.add(byte);
      }

      // ESC * 0 - Single density bitmap
      final nL = lineData.length & 0xFF;
      final nH = (lineData.length >> 8) & 0xFF;
      
      commands.addAll([0x1B, 0x2A, 0x00, nL, nH]);
      commands.addAll(lineData);
      commands.add(0x0A); // Line feed
    }

    commands.add(0x0A);

    // Cut
    commands.addAll([0x1D, 0x56, 0x42, 0x00]);

    return Uint8List.fromList(commands);
  }

  /// Print receipt with mixed text
  static Future<PrintPreviewData> createReceiptImage({
    required String companyNameKhmer,
    required String companyNameEnglish,
    List<Map<String, String>>? items,
    PrintMethod method = PrintMethod.gsv, // GS v 0 works for XP-P323B ✅
  }) async {
    final buffer = StringBuffer();

    buffer.writeln(companyNameKhmer);
    buffer.writeln(companyNameEnglish);
    buffer.writeln('Hello, សួរស្ដី');
    buffer.writeln();
    buffer.writeln('Description    Qty  Price  Amount');
    buffer.writeln('--------------------------------');

    if (items != null) {
      for (var item in items) {
        buffer.writeln(
          '${item['name']?.padRight(15)} ${item['qty']?.padLeft(3)} '
          '${item['price']?.padLeft(6)} ${item['amount']?.padLeft(7)}',
        );
      }
    }

    buffer.writeln('--------------------------------');
    buffer.write('អរគុណ - Thank You!');

    return await convertTextToImageCommands(
      buffer.toString(),
      fontSize: 18,
      paperWidth: 384,
      lineHeight: 1.1,
      method: method,
    );
  }

  /// Convert img.Image to Flutter Image widget for preview
  static ImageProvider imageToProvider(img.Image image) {
    final pngBytes = img.encodePng(image);
    return MemoryImage(Uint8List.fromList(pngBytes));
  }

  /// Save image to file
  /// Returns the file path if successful
  static Future<String?> saveImageToFile(
    img.Image image, {
    String filename = 'receipt',
    String format = 'png', // 'png' or 'jpg'
  }) async {
    try {
      // Get the appropriate directory
      Directory? directory;
      
      if (Platform.isAndroid) {
        // For Android, use external storage or app directory
        directory = await getExternalStorageDirectory();
        // Or use: directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // For other platforms
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        print('❌ Could not get directory');
        return null;
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = format.toLowerCase();
      final filepath = '${directory.path}/${filename}_$timestamp.$extension';

      // Encode image
      List<int> bytes;
      if (format == 'jpg' || format == 'jpeg') {
        bytes = img.encodeJpg(image, quality: 90);
      } else {
        bytes = img.encodePng(image);
      }

      // Write to file
      final file = File(filepath);
      await file.writeAsBytes(bytes);

      print('✅ Image saved to: $filepath');
      return filepath;
    } catch (e) {
      print('❌ Error saving image: $e');
      return null;
    }
  }

  /// Save image to gallery (Android/iOS)
  /// Requires permission and image_gallery_saver package
  // static Future<bool> saveImageToGallery(img.Image image) async {
  //   try {
  //     final pngBytes = img.encodePng(image);
  //     final result = await ImageGallerySaver.saveImage(
  //       Uint8List.fromList(pngBytes),
  //       quality: 100,
  //       name: 'receipt_${DateTime.now().millisecondsSinceEpoch}',
  //     );
      
  //     print('✅ Image saved to gallery: $result');
  //     return result['isSuccess'] ?? false;
  //   } catch (e) {
  //     print('❌ Error saving to gallery: $e');
  //     return false;
  //   }
  // }
}

/// Preview Dialog Widget
class PrintPreviewDialog extends StatelessWidget {
  final PrintPreviewData previewData;
  final VoidCallback onPrint;

  const PrintPreviewDialog({
    Key? key,
    required this.previewData,
    required this.onPrint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Print Preview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Preview Image
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Image(
                  image: ThermalPrintHelper.imageToProvider(previewData.image),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info
            Text(
              'Size: ${previewData.image.width}x${previewData.image.height}px',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            Text(
              'Data: ${previewData.printCommands.length} bytes',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPrint();
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Usage Example:
// 
// 1. Add to pubspec.yaml:
//    dependencies:
//      path_provider: ^2.1.0
//      image: ^4.0.0
//
// 2. For XP-P323B printer (RECOMMENDED):
//
// final previewData = await ThermalPrintHelper.createReceiptImage(
//   companyNameKhmer: 'ប្លូតិចឡូជី',
//   companyNameEnglish: 'BLUE TECHNOLOGY CO., LTD',
//   items: [
//     {'name': 'កាហ្វេ', 'qty': '2', 'price': '2.50', 'amount': '5.00'},
//   ],
//   method: PrintMethod.simple, // DEFAULT - Works best for XP-P323B
// );
//
// 3. If simple method doesn't work, try other methods:
//
// method: PrintMethod.gsv,           // Try this second
// method: PrintMethod.doubleDensity, // Try this last (higher quality)
//
// 4. Show preview and print:
//
// showDialog(
//   context: context,
//   builder: (context) => PrintPreviewDialog(
//     previewData: previewData,
//     onPrint: () async {
//       await platform.invokeMethod('printRaw', {
//         'data': previewData.printCommands
//       });
//     },
//   ),
// );