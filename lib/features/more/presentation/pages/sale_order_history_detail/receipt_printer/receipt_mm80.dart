import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
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
    int numberSign = 88;

    Uint8List? logoBytes;
    if (companyInfo?.logo128 != null && includeImage) {
      try {
        final response = await http.get(Uri.parse(companyInfo!.logo128!));
        if (response.statusCode == 200) {
          final decodedImage = img.decodeImage(response.bodyBytes);
          if (decodedImage != null) {
            final resizedImage = img.copyResize(decodedImage, width: 384);
            logoBytes = img.encodePng(resizedImage);
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
          fontSize: KhmerFontSize.large,
        ),
      );
    }

    // Company details
    if (companyInfo?.address != null) {
      segments.add(
        StyledTextSegment(text: "Address : ${companyInfo?.address}"),
      );
    }
    if (companyInfo?.email != null) {
      segments.add(StyledTextSegment(text: "Email : ${companyInfo?.email}"));
    }

    // Customer and invoice details
    segments.add(
      StyledTextSegment(
        text: "Customer : ${detail?.header.customerName ?? ''}",
      ),
    );
    segments.add(
      StyledTextSegment(text: "Date : ${detail?.header.documentDate ?? ''}"),
    );
    segments.add(
      StyledTextSegment(text: "Invoice No : ${detail?.header.no ?? ''}"),
    );
    segments.add(
      StyledTextSegment(
        text: "Invoice Type : ${detail?.header.documentType ?? ''}",
      ),
    );
    segments.add(StyledTextSegment(text: "-" * numberSign));
    segments.add(
      StyledTextSegment(
        text: "#|Description|Qty|Price|Disc|Amount",
        style: KhmerTextStyle.bold,
        isRow: true,
      ),
    );

    segments.add(StyledTextSegment(text: "-" * numberSign));
    int itemNumber = 1;
    for (PosSalesLine item in (detail?.lines ?? [])) {
      try {
        segments.add(
          StyledTextSegment(
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

    segments.add(StyledTextSegment(text: "=" * (numberSign - 38)));

    // Total Amount
    segments.add(
      StyledTextSegment(
        text: " | | | |Total Amount|${detail?.header.amount ?? ''}",
        style: KhmerTextStyle.bold,
        fontSize: KhmerFontSize.large,
        isRow: true,
      ),
    );

    // Thank you message
    segments.add(
      StyledTextSegment(
        style: KhmerTextStyle.bold,
        fontSize: KhmerFontSize.large,
        text: "អរគុណសម្រាប់ការជាវនៅហាងរបស់យើង",
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
    int maxDescLength = 18, // characters per line for description
  }) {
    double p = Helpers.toDouble(price);
    double d = Helpers.toDouble(discount);
    double a = Helpers.toDouble(amount);

    if (description.isEmpty) {
      description = "-";
    }

    List<String> descLines = _wrapText(description, maxDescLength);

    if (descLines.length == 1) {
      return "$itemNumber|${descLines[0]}|$quantity|${p.toStringAsFixed(2)}|${d > 0 ? d.toStringAsFixed(2) : '_'}|${a.toStringAsFixed(2)}";
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

    // if (companyInfo != null && companyInfo.logo128 != null) {
    //   try {
    //     final response = await http.get(Uri.parse(companyInfo.logo128 ?? ""));
    //     if (response.statusCode == 200) {
    //       final imageBytes = response.bodyBytes;
    //       final decodedImage = img.decodeImage(imageBytes);
    //       if (decodedImage != null) {
    //         final resizedImage = img.copyResize(decodedImage, width: 384);
    //         bytes += generator.image(resizedImage);
    //       }
    //     }
    //   } catch (e) {
    //     Logger.log(e);
    //   }
    // }

    final segments = await buildReceiptSegments(
      detail: detail,
      companyInfo: companyInfo,
    );

    final khmerBytes = await printRichKhmerTextFor80mm(segments);
    bytes.addAll(khmerBytes);

    bytes += generator.cut();
    return bytes;
  }
}
