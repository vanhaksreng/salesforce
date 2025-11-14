import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as img;
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/khmer_text_render.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ReceiptBuilder {
  static Future<Uint8List?> testPrint() async {
    try {
      final receipt = BytesBuilder();
      receipt.add(ESCPOSCommands.initialize());

      final testKhmer = await KhmerTextRenderer.renderESCPOS(
        'សូមស្វាគមន៍',
        fontSize: 24,
      );

      // Check if testKhmer is not null before adding
      if (testKhmer != null) {
        receipt.add(testKhmer);
      }

      final finalData = receipt.toBytes();
      return finalData;
    } catch (e, stack) {
      return null;
    }
  }
}
