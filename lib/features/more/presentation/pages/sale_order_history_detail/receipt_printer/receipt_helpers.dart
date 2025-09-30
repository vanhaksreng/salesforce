import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/generate_thermal_receipt.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_mm80.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ReceiptHelpers {
  static img.Image convertTo1BitDithered(img.Image input) {
    final gray = img.grayscale(input);
    final dithered = img.ditherImage(gray);
    return dithered;
  }

  static Future<List<StyledTextSegment>> buildReceiptSegmentsForPreview({
    SaleDetail? detail,
    CompanyInformation? companyInfo,
  }) async {
    return await ReceiptMm80.buildReceiptSegments(
      detail: detail,
      companyInfo: companyInfo,
      includeImage: true,
    );
  }

  static Future<ReceiptPreview?> generateReceiptPreview(
    List<StyledTextSegment> segments,
  ) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    const int paperWidthPixels = XP323BConfig.paperWidthPixels;

    final image = await generateRichKhmerTextAsImgImage(
      segments,
      paperWidthPixels,
      null,
    );

    if (image == null) return null;

    final bwImage = ReceiptHelpers.convertTo1BitDithered(image);
    final bytes = generator.image(bwImage) + generator.feed(1);

    return ReceiptPreview(bytes: bytes, image: bwImage);
  }

  static String composeReceiptLine(String label, String value, int lineWidth) {
    final maxValueLen =
        lineWidth - label.runes.length - 1; // leave at least 1 space
    if (value.runes.length > maxValueLen) {
      value = value.substring(0, maxValueLen); // truncate
    }
    final totalLen = label.runes.length + value.runes.length;
    final padding = totalLen < lineWidth ? ' ' * (lineWidth - totalLen) : ' ';
    return label + padding + value;
  }
}

class ReceiptPreview {
  final List<int> bytes;
  final img.Image? image;
  ReceiptPreview({required this.bytes, this.image});
}

class XP323BConfig {
  static const PaperSize paperSize = PaperSize.mm80;
  static const int paperWidthPixels = 576;
  static const int leftMargin = 20;
  static const int topMargin = 0;
}

class StyledTextSegment {
  final String text;
  final KhmerTextStyle style;
  final KhmerFontSize fontSize;
  final Color? color;
  final int maxline;
  final bool isRow;
  final double? rowHeight;
  final Uint8List? image; // new field for image bytes
  final double? imageWidth; // optional custom width
  final double? imageHeight; // optional custom height
  final TextAlign? textAlign; // optional custom height

  StyledTextSegment({
    required this.text,
    this.style = KhmerTextStyle.normal,
    this.fontSize = KhmerFontSize.normal,
    this.color,
    this.maxline = 2,
    this.isRow = false,
    this.rowHeight,
    this.image,
    this.imageWidth,
    this.imageHeight,
    this.textAlign,
  });
}

enum KhmerTextStyle { normal, bold, italic, boldItalic }

enum KhmerFontSize { small, normal, large, extraLarge }
