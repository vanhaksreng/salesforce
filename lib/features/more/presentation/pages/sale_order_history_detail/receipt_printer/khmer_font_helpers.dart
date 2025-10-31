import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

// ==================== OPTIMIZED NATIVE BLUETOOTH PRINTER ====================
class NativeBluetoothPrinter {
  static const MethodChannel _channel = MethodChannel(
    'native_bluetooth_printer',
  );

  static Future<List<BluetoothDevice>> scanDevices({int timeout = 10}) async {
    try {
      print("🔍 Scanning for Bluetooth devices...");
      final List<dynamic>? devices = await _channel.invokeMethod(
        'scanDevices',
        {'timeout': timeout},
      );

      if (devices == null) return [];

      return devices.map((device) {
        return BluetoothDevice(
          name: device['name'] ?? 'Unknown',
          address: device['address'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("❌ Error scanning devices: $e");
      return [];
    }
  }

  static Future<bool> connect(String address) async {
    try {
      print("🔗 Connecting to device: $address");
      final bool? result = await _channel.invokeMethod('connect', {
        'address': address,
      });
      return result ?? false;
    } catch (e) {
      print("❌ Error connecting: $e");
      return false;
    }
  }

  static Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
      print("🔌 Disconnected from printer");
    } catch (e) {
      print("❌ Error disconnecting: $e");
    }
  }

  static Future<bool> isConnected() async {
    try {
      final bool? result = await _channel.invokeMethod('isConnected');
      return result ?? false;
    } catch (e) {
      print("❌ Error checking connection: $e");
      return false;
    }
  }

  static Future<String> getConnectionStatus() async {
    try {
      final String? status = await _channel.invokeMethod('getConnectionStatus');
      return status ?? 'disconnected';
    } catch (e) {
      return 'disconnected';
    }
  }

  // ✅ OPTIMIZED: Use JPEG instead of PNG (3-5x faster encoding)
  // ✅ NEW OPTIMIZED CODE:
  static Future<bool> printImage(img.Image image) async {
    try {
      print("📄 Preparing image for printing...");
      final startTime = DateTime.now();

      // ✅ Use JPEG instead of PNG (3-5x faster!)
      final jpegBytes = img.encodeJpg(image, quality: 95);

      final convertTime = DateTime.now().difference(startTime).inMilliseconds;
      print("✓ Image encoded in ${convertTime}ms (${jpegBytes.length} bytes)");

      print("📤 Sending to printer...");
      final sendTime = DateTime.now();

      final bool? result = await _channel.invokeMethod('printImage', {
        'imageData': jpegBytes, // Using JPEG
      });

      final totalSendTime = DateTime.now().difference(sendTime).inMilliseconds;
      print("✓ Print completed in ${totalSendTime}ms");

      final totalTime = DateTime.now().difference(startTime).inMilliseconds;
      print("🎉 Total print time: ${totalTime}ms");

      return result ?? false;
    } catch (e) {
      print("❌ Error printing: $e");
      return false;
    }
  }

  static Future<bool> printRaw(Uint8List data) async {
    try {
      final bool? result = await _channel.invokeMethod('printRaw', {
        'data': data,
      });
      return result ?? false;
    } catch (e) {
      print("❌ Error printing raw data: $e");
      return false;
    }
  }
}

class BluetoothDevice {
  final String name;
  final String address;

  BluetoothDevice({required this.name, required this.address});

  @override
  String toString() => 'BluetoothDevice(name: $name, address: $address)';
}

// ==================== OPTIMIZED IMAGE PROCESSING ====================
class ImageProcessor {
  // ✅ OPTIMIZED: Fast grayscale and threshold conversion
  static img.Image processForPrinting(img.Image image) {
    final startTime = DateTime.now();
    print("🎨 Processing image...");

    // Step 1: Grayscale conversion (built-in is fast)
    var processed = img.grayscale(image);

    // Step 2: High contrast to create black/white effect
    processed = img.adjustColor(processed, contrast: 2.5, brightness: 1.15);

    final processTime = DateTime.now().difference(startTime).inMilliseconds;
    print("✓ Image processed in ${processTime}ms");

    return processed;
  }

  // ✅ ALTERNATIVE: Minimal processing (fastest)
  static img.Image quickProcessForPrinting(img.Image image) {
    final startTime = DateTime.now();
    print("🎨 Quick processing image...");

    // Just grayscale with high contrast
    var processed = img.grayscale(image);
    processed = img.adjustColor(processed, contrast: 2.0);

    final processTime = DateTime.now().difference(startTime).inMilliseconds;
    print("✓ Image quick-processed in ${processTime}ms");

    return processed;
  }

  // ✅ BEST QUALITY: Manual threshold (slower but cleanest output)
  static img.Image fastThreshold(img.Image image, {int threshold = 200}) {
    final startTime = DateTime.now();
    print("🎨 Fast threshold processing...");

    // First convert to grayscale
    final grayscale = img.grayscale(image);

    // Apply threshold using pixel iteration
    for (int y = 0; y < grayscale.height; y++) {
      for (int x = 0; x < grayscale.width; x++) {
        final pixel = grayscale.getPixel(x, y);

        // Get red channel (all channels are same in grayscale)
        final value = pixel.r;

        // Apply threshold: white if above threshold, black if below
        final color = value > threshold ? 255 : 0;
        grayscale.setPixelRgba(x, y, color, color, color, 255);
      }
    }

    final processTime = DateTime.now().difference(startTime).inMilliseconds;
    print("✓ Fast threshold completed in ${processTime}ms");

    return grayscale;
  }

  // ✅ OPTIMIZED: Resize image before processing (reduces pixel count)
  static img.Image resizeForPrinter(img.Image image, {int width = 576}) {
    if (image.width == width) return image;

    final startTime = DateTime.now();
    print("📐 Resizing image to ${width}px...");

    final resized = img.copyResize(
      image,
      width: width,
      interpolation: img.Interpolation.nearest, // Fastest interpolation
    );

    final resizeTime = DateTime.now().difference(startTime).inMilliseconds;
    print("✓ Image resized in ${resizeTime}ms");

    return resized;
  }
}

// ==================== OPTIMIZED KHMER PRINTER ====================
class KhmerPrinter {
  static const MethodChannel _channel = MethodChannel('khmer_text_renderer');

  static Future<img.Image> renderKhmerText(
    String text, {
    double width = 384,
    double fontSize = 24,
    bool useCache = true,
  }) async {
    try {
      final Uint8List? result = await _channel.invokeMethod('renderText', {
        'text': text,
        'width': width,
        'fontSize': fontSize,
        'useCache': useCache,
      });

      if (result == null) {
        throw Exception('Failed to render Khmer text');
      }

      // ✅ Swift now returns JPEG, decode it
      final image = img.decodeImage(result);
      if (image == null) {
        throw Exception('Failed to decode rendered image');
      }

      return image;
    } catch (e) {
      debugPrint('Error rendering Khmer text: $e');
      rethrow;
    }
  }

  // ✅ OPTIMIZED: Batch render multiple texts in parallel
  static Future<Map<String, img.Image>> renderKhmerBatch(
    Map<String, KhmerTextConfig> configs,
  ) async {
    if (configs.isEmpty) return {};

    try {
      final startTime = DateTime.now();

      final texts = configs.keys.toList();
      final textValues = configs.values.map((c) => c.text).toList();
      final widths = configs.values.map((c) => c.width).toList();
      final fontSize = configs.values.first.fontSize;

      print("🔤 Batch rendering ${texts.length} Khmer texts...");

      final List<dynamic>? results = await _channel.invokeMethod(
        'renderTextBatch',
        {'texts': textValues, 'widths': widths, 'fontSize': fontSize},
      );

      if (results == null) {
        throw Exception('Failed to batch render Khmer text');
      }

      final Map<String, img.Image> renderedImages = {};

      for (int i = 0; i < texts.length; i++) {
        if (results[i] != null && results[i] is Uint8List) {
          final image = img.decodeImage(results[i] as Uint8List);
          if (image != null) {
            renderedImages[texts[i]] = image;
          }
        }
      }

      final batchTime = DateTime.now().difference(startTime).inMilliseconds;
      print(
        "✓ Batch rendered ${renderedImages.length} texts in ${batchTime}ms",
      );

      return renderedImages;
    } catch (e) {
      debugPrint('Error batch rendering Khmer text: $e');

      // Fallback to sequential rendering
      final Map<String, img.Image> renderedImages = {};
      for (var entry in configs.entries) {
        try {
          renderedImages[entry.key] = await renderKhmerText(
            entry.value.text,
            width: entry.value.width,
            fontSize: entry.value.fontSize,
          );
        } catch (e2) {
          debugPrint('Failed to render ${entry.key}: $e2');
        }
      }
      return renderedImages;
    }
  }

  static Future<void> clearCache() async {
    try {
      await _channel.invokeMethod('clearCache');
      debugPrint('✓ Khmer render cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  static Future<String> getCacheInfo() async {
    try {
      final String? info = await _channel.invokeMethod('getCacheInfo');
      return info ?? 'No cache info available';
    } catch (e) {
      debugPrint('Error getting cache info: $e');
      return 'Error getting cache info';
    }
  }

  static bool containsKhmer(String text) {
    return text.contains(RegExp(r'[\u1780-\u17FF]'));
  }
}

class KhmerTextConfig {
  final String text;
  final double width;
  final double fontSize;

  KhmerTextConfig({required this.text, this.width = 384, this.fontSize = 24});
}

// ==================== USAGE EXAMPLE ====================
/*
// In your _createReceiptImage method, replace the final processing section with:

Future<img.Image> _createReceiptImage({
  required SaleDetail? detail,
  required CompanyInformation? companyInfo,
}) async {
  const width = 576;
  final startTime = DateTime.now();

  // ... (your existing code to build finalImage)

  debugPrint("✓ Receipt built in ${DateTime.now().difference(startTime).inMilliseconds}ms");

  // ✅ OPTIMIZED: Use new fast processing
  debugPrint("🎨 Processing image...");
  final processStartTime = DateTime.now();
  
  // Option 1: Full processing (good quality)
  img.Image processed = ImageProcessor.processForPrinting(finalImage);
  
  // Option 2: Quick processing (faster, slightly lower quality)
  // img.Image processed = ImageProcessor.quickProcessForPrinting(finalImage);

  final processTime = DateTime.now().difference(processStartTime).inMilliseconds;
  debugPrint("✓ Image processed in ${processTime}ms");

  debugPrint("🎉 Total time: ${DateTime.now().difference(startTime).inMilliseconds}ms");

  return processed;
}

// For printing, use:
final success = await NativeBluetoothPrinter.printImage(receiptImage);
// This now uses JPEG encoding (3-5x faster than PNG)
*/
