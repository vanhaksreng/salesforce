// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;

// class KhmerTextConfig {
//   final String text;
//   final double width;
//   final double fontSize;
//   final int maxLines;

//   KhmerTextConfig({
//     required this.text,
//     this.width = 384,
//     this.fontSize = 24,
//     this.maxLines = 1,
//   });
// }

// class KhmerPrinter {
//   static const MethodChannel _channel = MethodChannel('khmer_text_renderer');

//   static Future<img.Image> renderKhmerText(
//     String text, {
//     double width = 384,
//     double fontSize = 36,
//     int maxLines = 1,
//     bool useCache = true,
//   }) async {
//     try {
//       final Uint8List? result = await _channel.invokeMethod('renderText', {
//         'text': text,
//         'width': width,
//         'fontSize': fontSize,
//         'maxLines': maxLines,
//         'useCache': useCache,
//       });

//       if (result == null) {
//         throw Exception('Failed to render Khmer text');
//       }

//       final image = img.decodeImage(result);
//       if (image == null) {
//         throw Exception('Failed to decode rendered image');
//       }

//       return image;
//     } catch (e) {
//       debugPrint('Error rendering Khmer text: $e');
//       rethrow;
//     }
//   }

//   static Future<Map<String, img.Image>> renderKhmerBatch(
//     Map<String, KhmerTextConfig> configs,
//   ) async {
//     if (configs.isEmpty) return {};

//     try {
//       final startTime = DateTime.now();

//       final texts = configs.keys.toList();
//       final textValues = configs.values.map((c) => c.text).toList();
//       final widths = configs.values.map((c) => c.width).toList();
//       final fontSizes = configs.values.map((c) => c.fontSize).toList();
//       final maxLines = configs.values.map((c) => c.maxLines).toList();

//       debugPrint("📤 Batch rendering ${texts.length} Khmer texts...");

//       final List<dynamic>? results = await _channel
//           .invokeMethod('renderTextBatch', {
//             'texts': textValues,
//             'widths': widths,
//             'fontSizes': fontSizes,
//             'maxLines': maxLines,
//           });

//       if (results == null) {
//         throw Exception('Failed to batch render Khmer text');
//       }

//       final Map<String, img.Image> renderedImages = {};

//       for (int i = 0; i < texts.length; i++) {
//         if (results[i] != null && results[i] is Uint8List) {
//           final image = img.decodeImage(results[i] as Uint8List);
//           if (image != null) {
//             renderedImages[texts[i]] = image;
//           }
//         }
//       }

//       final batchTime = DateTime.now().difference(startTime).inMilliseconds;
//       debugPrint(
//         "✅ Batch rendered ${renderedImages.length} texts in ${batchTime}ms",
//       );

//       return renderedImages;
//     } catch (e) {
//       debugPrint('Error batch rendering Khmer text: $e');
//       return {};
//     }
//   }

//   static Future<void> clearCache() async {
//     try {
//       await _channel.invokeMethod('clearCache');
//       debugPrint('✅ Khmer render cache cleared');
//     } catch (e) {
//       debugPrint('Error clearing cache: $e');
//     }
//   }

//   static bool containsKhmer(String text) {
//     return text.contains(RegExp(r'[\u1780-\u17FF]'));
//   }
// }
