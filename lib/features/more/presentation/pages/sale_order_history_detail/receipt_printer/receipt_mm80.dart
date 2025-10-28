import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:salesforce/core/enums/enums.dart' as format;
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/generate_thermal_receipt.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_helpers.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ReceiptMm80 {
  static Future<List<StyledTextSegment>> buildReceiptSegments({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
    bool includeImage = false,
  }) async {
    List<StyledTextSegment> segments = [];
    int numberSign = 56;

    Uint8List? logoBytes;
    if (companyInfo?.logo128 != null && includeImage) {
      try {
        final response = await http.get(Uri.parse(companyInfo?.logo128 ?? ""));

        if (response.statusCode == 200) {
          final decodedImage = img.decodeImage(response.bodyBytes);
          if (decodedImage != null) {
            // final resizedImage = img.copyResize(decodedImage, width: 384);
            final newHeight = (decodedImage.height * 384 / decodedImage.width)
                .round();
            final resizedImage = img.copyResize(
              decodedImage,
              width: 384,
              height: newHeight > 0 ? newHeight : 1,
            );
            logoBytes = img.encodePng(resizedImage);

            segments.add(
              StyledTextSegment(
                text: "",
                isRow: false,
                image: logoBytes,
                imageWidth: 120,
                imageHeight: 120,
              ),
            );
          }
        }
      } catch (e) {
        Logger.log(e);
      }
    }

    if (companyInfo?.name != null) {
      segments.add(
        StyledTextSegment(
          text: companyInfo?.name ?? "",
          style: KhmerTextStyle.bold,
          textAlign: TextAlign.center,
          fontSize: KhmerFontSize.large,
        ),
      );
    }
    if (companyInfo?.address != null) {
      segments.add(
        StyledTextSegment(
          text: companyInfo?.address ?? "",
          style: KhmerTextStyle.bold,
          textAlign: TextAlign.center,
          rowHeight: 30,
        ),
      );
    }
    if (companyInfo?.email != null) {
      segments.add(
        StyledTextSegment(
          text: "Email : ${companyInfo?.email}",
          textAlign: TextAlign.center,
          rowHeight: 24,
        ),
      );
    }

    segments.add(
      StyledTextSegment(
        text: ReceiptHelpers.composeReceiptLine(
          "Customer :",
          detail?.header.customerName ?? '',
          24,
        ),
      ),
    );
    segments.add(
      StyledTextSegment(
        text: ReceiptHelpers.composeReceiptLine(
          "Date :",
          detail?.header.documentDate ?? '',
          24,
        ),
      ),
    );
    segments.add(
      StyledTextSegment(
        text: ReceiptHelpers.composeReceiptLine(
          "Invoice No :",
          detail?.header.no ?? '',
          24,
        ),
        rowHeight: 20,
      ),
    );

    segments.add(
      StyledTextSegment(text: "-" * numberSign, style: KhmerTextStyle.bold),
    );
    segments.add(
      StyledTextSegment(
        text: "#|Description|Qty|Price|Disc|Amount",
        style: KhmerTextStyle.bold,
        fontSize: KhmerFontSize.normal,
        isRow: true,
        rowHeight: 40,
      ),
    );

    segments.add(
      StyledTextSegment(text: "-" * numberSign, style: KhmerTextStyle.bold),
    );
    int itemNumber = 1;
    for (PosSalesLine item in (detail?.lines ?? [])) {
      try {
        segments.add(
          StyledTextSegment(
            fontSize: KhmerFontSize.normal,
            // style: KhmerTextStyle.bold,
            rowHeight: 26,
            text: _formatItemLine(
              itemNumber: itemNumber,
              description: item.description ?? '',
              quantity: Helpers.toInt(item.quantity),
              price: item.unitPrice,
              discount: item.discountAmount ?? 0,
              amount: item.amountIncludingVat ?? 0,
            ),
            isRow: true,
          ),
        );
      } catch (e) {
        segments.add(StyledTextSegment(text: "X Error Item"));
      }
      itemNumber++;
    }

    segments.add(
      StyledTextSegment(
        text: "=" * (numberSign - 13),
        rowHeight: 10,
        style: KhmerTextStyle.bold,
        fontSize: KhmerFontSize.normal,
      ),
    );

    final disPercStr = Helpers.formatNumberLink(
      detail?.header.priceIncludeVat ?? '',
      option: format.FormatType.percentage,
    );
    final disPer = ReceiptHelpers.composeReceiptLine(
      'Discount (%) :',
      disPercStr,
      numberSign + 20,
    );
    segments.add(
      StyledTextSegment(
        rowHeight: 10,
        style: KhmerTextStyle.bold,
        text: disPer,
        fontSize: KhmerFontSize.normal,
        isRow: false,
      ),
    );

    final totalStr = Helpers.formatNumberLink(detail?.header.amount ?? '');
    final total = ReceiptHelpers.composeReceiptLine(
      'Total Amount :',
      totalStr,
      numberSign + 20,
    );

    segments.add(
      StyledTextSegment(
        text: total,
        style: KhmerTextStyle.bold,
        fontSize: KhmerFontSize.normal,
        isRow: false,
        rowHeight: 24,
      ),
    );

    segments.add(
      StyledTextSegment(
        textAlign: TextAlign.center,
        rowHeight: 28,
        text:
            "Thank you for shopping with us. We look forward to serving you again!❤️❤️",
      ),
    );

    segments.add(
      StyledTextSegment(
        // style: KhmerTextStyle.bold,
        fontSize: KhmerFontSize.small,
        textAlign: TextAlign.center,
        text: "Powered by Blue Technology Co., Ltd.",
      ),
    );

    return segments;
  }

  static String _formatItemLine({
    required int itemNumber,
    required String description,
    required int quantity,
    required dynamic price,
    required dynamic discount,
    required dynamic amount,
    int maxDescLength = 18,
  }) {
    double p = Helpers.toDouble(price);
    double d = Helpers.toDouble(discount);
    double a = Helpers.toDouble(amount);

    if (description.isEmpty) {
      description = "-";
    }

    List<String> descLines = _wrapText(description, maxDescLength);

    if (descLines.length == 1) {
      return "$itemNumber|${descLines[0]}|${quantity.toString().padLeft(4)}|${p.toStringAsFixed(2)}|${d > 0 ? d.toStringAsFixed(2) : '_'}|${a.toStringAsFixed(2)}";
    } else {
      List<String> lines = [];
      lines.add(
        "$itemNumber|${descLines[0]}|$quantity|${p.toStringAsFixed(2)}|${d > 0 ? d.toStringAsFixed(2) : '_'}|${a.toStringAsFixed(2)}",
      );

      for (int i = 1; i < descLines.length; i++) {
        lines.add(" |${descLines[i]}|||||");
      }

      return lines.join('\n');
    }
  }

  // # Description           QTY    Price    Disc   Amount
  // 1|Long Product Name  |   2|   15.50|      _|    31.00
  // 2|Short Name         |   1|  100.00|  10.00|    90.00

  // Helper function for smart text wrapping
  static List<String> _wrapText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return [text];
    }

    List<String> lines = [];
    String remaining = text;

    while (remaining.length > maxLength) {
      int splitAt = maxLength;

      int lastSpace = remaining.lastIndexOf(' ', maxLength);
      if (lastSpace > maxLength * 0.7) {
        splitAt = lastSpace;
      }

      lines.add(remaining.substring(0, splitAt).trim());
      remaining = remaining.substring(splitAt).trim();
    }

    if (remaining.isNotEmpty) {
      lines.add(remaining);
    }

    return lines;
  }

  static Future<List<int>> generateCustomReceiptBytes({
    SaleDetail? detail,
    CompanyInformation? companyInfo,
  }) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);
    List<int> bytes = [];
    bytes += generator.reset();
    bytes += generator.text('');
    final segments =
        (await buildReceiptSegments(
          detail: detail,
          companyInfo: companyInfo,
          includeImage: true,
        )).where((segment) {
          if (segment.image != null) return true; // ← Keep image segments!
          return segment.text.trim().isNotEmpty && segment.text.trim() != "0";
        }).toList();

    final khmerBytes = await printRichKhmerTextFor80mm(segments);
    bytes.addAll(khmerBytes);

    bytes += generator.cut();
    return bytes;
  }
}
