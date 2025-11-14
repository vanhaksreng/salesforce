import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:salesforce/infrastructure/printer/bluetooth/bluetooth_printer_handler.dart';

class ReceiptPrinter {
  // buildReceiptWidget (unchanged, with LayoutBuilder for better sizing)
  static Widget buildReceiptWidget(List<Map<String, dynamic>> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(8),
          color: Colors.white, // Clean background
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ប្លូតិចឡូជី', // Khmer
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'KhmerFont'),
                ),
                const Text(
                  'BLUE TECHNOLOGY CO., LTD',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Table(
                  border: TableBorder.all(color: Colors.black),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    const TableRow(children: [  // Headers
                      Text('Description', style: TextStyle(fontSize: 12)),
                      Text('Qty', style: TextStyle(fontSize: 12)),
                      Text('UOM', style: TextStyle(fontSize: 12)),
                      Text('Price', style: TextStyle(fontSize: 12)),
                      Text('Disc', style: TextStyle(fontSize: 12)),
                      Text('Amount', style: TextStyle(fontSize: 12)),
                    ]),
                    ...items.map((item) => TableRow(children: [  // Dynamic rows
                      Text(item['description'] ?? '', style: const TextStyle(fontSize: 12, fontFamily: 'NotoSansKhmer')),
                      Text(item['qty'].toString(), style: const TextStyle(fontSize: 12)),
                      Text(item['uom'] ?? '', style: const TextStyle(fontSize: 12)),
                      Text(item['price'].toString(), style: const TextStyle(fontSize: 12)),
                      Text(item['disc'].toString(), style: const TextStyle(fontSize: 12)),
                      Text(item['amount'].toString(), style: const TextStyle(fontSize: 12)),
                    ])),
                  ],
                ),
                const SizedBox(height: 20), // Footer
              ],
            ),
          ),
        );
      },
    );
  }

  // NEW: Off-screen capture via positioned Stack in Overlay (fixes type/assertion errors)
  static Future<ui.Image?> _captureImageOffScreen(BuildContext context, List<Map<String, dynamic>> items) async {
    final GlobalKey _boundaryKey = GlobalKey();
    final Completer<ui.Image?> completer = Completer<ui.Image?>();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Temporary OverlayEntry with Stack (positions receipt off-screen)
    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (overlayContext) => LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Invisible placeholder (no child needed)
              const SizedBox.shrink(),
              // Position receipt far off-screen (below visible area)
              Positioned(
                left: 0,
                top: screenHeight * 2, // Far below—renders but invisible
                right: 0,
                height: constraints.maxHeight, // Full available height
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: ReceiptPrinter.buildReceiptWidget(items),
                ),
              ),
            ],
          );
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Wait for layout/paint, then capture
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        // Short delay for full render (fonts/table)
        await Future.delayed(const Duration(milliseconds: 50));
        
        final RenderRepaintBoundary boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
        
        debugPrint('Captured off-screen image: ${image.width} x ${image.height}');
        
        if (image.width == 0 || image.height == 0) {
          image.dispose();
          completer.completeError(Exception('Invalid dimensions: ${image.width}x${image.height}'));
          return;
        }
        
        completer.complete(image);
      } catch (e) {
        completer.completeError(e);
      } finally {
        overlayEntry.remove(); // Always cleanup
      }
    });

    return completer.future;
  }

  // _uiImageToMonochrome (unchanged)
  static Future<Uint8List> _uiImageToMonochrome(ui.Image uiImage, int width, int height) async {
    final byteWidth = (width + 7) ~/ 8;
    final totalBytes = byteWidth * height;
    final List<int> bitmap = List<int>.filled(totalBytes, 0);

    final ByteData? tempByteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (tempByteData == null) {
      throw Exception('Failed to convert image to ByteData');
    }
    final ByteData byteData = tempByteData;
    final pixels = byteData.buffer.asUint8List();

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final idx = (y * width + x) * 4;
        final r = pixels[idx];
        final g = pixels[idx + 1];
        final b = pixels[idx + 2];
        final gray = (0.3 * r + 0.59 * g + 0.11 * b).round();
        if (gray > 128) {
          final byteIdx = y * byteWidth + (x ~/ 8);
          final bitIdx = 7 - (x % 8);
          bitmap[byteIdx] |= (1 << bitIdx);
        }
      }
    }

    return Uint8List.fromList(bitmap);
  }

  // _bitmapToEscPos (unchanged)
  static Uint8List _bitmapToEscPos(Uint8List bitmap, int width, int height) {
    final byteWidth = (width + 7) ~/ 8;

    final List<int> escPos = [0x1B, 0x40]; // ESC @ init

    escPos.addAll([0x1D, 0x76, 0x30, 0]); // GS v 0 m=0
    escPos.add(byteWidth & 0xFF); // xL
    escPos.add((byteWidth >> 8) & 0xFF); // xH
    escPos.add(height & 0xFF); // yL
    escPos.add((height >> 8) & 0xFF); // yH

    escPos.addAll(bitmap);

    escPos.add(0x0A); // LF
    escPos.addAll([0x1D, 0x56, 0x42, 0x00]); // Partial cut

    return Uint8List.fromList(escPos);
  }

  // UPDATED: Main print function—now passes context to off-screen capture
  static Future<void> printReceipt(BuildContext context, List<Map<String, dynamic>> items) async {
    if (!context.mounted) return;

    try {
      final ui.Image? image = await _captureImageOffScreen(context, items);
      if (image == null) {
        throw Exception('Failed to capture receipt image');
      }

      final width = image.width;
      final height = image.height;

      final bitmap = await _uiImageToMonochrome(image, width, height);
      final escPosBytes = _bitmapToEscPos(bitmap, width, height);

      if (BluetoothPrinterHandler.isConnected) {
        await BluetoothPrinterHandler.printRaw(escPosBytes);
      } else {
        throw Exception('Printer not connected');
      }
      
      image.dispose();
    } catch (e) {
      debugPrint('Print error: $e');
      rethrow;
    }
  }
}