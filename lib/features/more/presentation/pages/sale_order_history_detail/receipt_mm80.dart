// import 'dart:typed_data';

// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:http/http.dart' as http;
// import 'package:salesforce/core/utils/helpers.dart';
// import 'package:salesforce/core/utils/logger.dart';
// import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/generate_thermal_receipt.dart';
// import 'package:salesforce/realm/scheme/sales_schemas.dart';
// import 'package:salesforce/realm/scheme/schemas.dart';

// class ReceiptMm80 {
//   // Column widths (adjust for 80mm paper)
//   static const int colNum = 3; // Item #
//   static const int colDesc = 25; // Description
//   static const int colQty = 10; // Quantity
//   static const int colPrice = 10; // Price
//   static const int colDisc = 10; // Discount
//   static const int colAmt = 10; // Amount

//   static Future<List<int>> generateCustomReceiptBytes({
//     required SaleDetail? detail,
//     required CompanyInformation? companyInfo,
//   }) async {
//     const PaperSize paper = PaperSize.mm80;
//     final profile = await CapabilityProfile.load();
//     final generator = Generator(paper, profile);
//     List<int> bytes = [];

//     List<StyledTextSegment> receiptContent = [];

//     if (companyInfo != null && companyInfo.logo128 != null) {
//       try {
//         final response = await http.get(Uri.parse(companyInfo.logo128 ?? ""));
//         if (response.statusCode == 200) {
//           final imageBytes = response.bodyBytes;
//           final decodedImage = img.decodeImage(imageBytes);
//           if (decodedImage != null) {
//             final resizedImage = img.copyResize(decodedImage, width: 384);
//             bytes += generator.image(resizedImage);
//           }
//         }
//       } catch (e) {
//         Logger.log(e);
//       }
//     }

//     receiptContent.add(
//       StyledTextSegment(text: "Address : #${companyInfo?.address}"),
//     );

//     receiptContent.add(
//       StyledTextSegment(text: "Email : #${companyInfo?.email}"),
//     );

//     receiptContent.add(
//       StyledTextSegment(text: "Customer :  ${detail?.header.customerName}"),
//     );
//     receiptContent.add(
//       StyledTextSegment(text: "Date :  ${detail?.header.documentDate}"),
//     );
//     receiptContent.add(
//       StyledTextSegment(text: "Invoice No :  ${detail?.header.no}"),
//     );
//     receiptContent.add(
//       StyledTextSegment(text: "Invoice Type :  ${detail?.header.documentType}"),
//     );
//     bytes += generator.hr(ch: "-");

//     // Column headers
//     receiptContent.add(
//       StyledTextSegment(
//         text:
//             '${"#".padRight(colNum)}'
//             '${"Description".padRight(colDesc)}'
//             '${"Qty".padLeft(colQty)}'
//             '${"Price".padLeft(colPrice)}'
//             '${"Disc".padLeft(colDisc)}'
//             '${"Amount".padLeft(colAmt)}\n',
//       ),
//     );

//     // Separator line
//     bytes += generator.hr(ch: "-");

//     // Items
//     int itemNumber = 1;

//     for (PosSalesLine item in (detail?.lines ?? [])) {
//       try {
//         String description = (item.description ?? '').trim();

//         String itemLine = _formatItemLine(
//           itemNumber: itemNumber,
//           description: description,
//           quantity: Helpers.toInt(item.quantity),
//           price: item.unitPrice,
//           discount: item.discountAmount ?? 0,
//           amount: item.amountIncludingVat ?? 0,
//         );

//         receiptContent.add(StyledTextSegment(text: "$itemLine\n"));
//       } catch (e) {
//         receiptContent.add(StyledTextSegment(text: "X Error Item\n"));
//       }
//       itemNumber++;
//     }
//     bytes += generator.hr(ch: "-");

//     // Replace this line:
//     receiptContent.add(
//       StyledTextSegment(text: "Total Amount ${detail?.header.amount}"),
//     );

//     // With this code for space-between alignment:
//     String totalLabel = "Total Amount";
//     String totalValue = "${detail?.header.amount}";
//     int totalWidth =
//         colNum +
//         colDesc +
//         colQty +
//         colPrice +
//         colDisc +
//         colAmt; // Total receipt width
//     int spacesNeeded = totalWidth - totalLabel.length - totalValue.length;

//     receiptContent.add(
//       StyledTextSegment(
//         style: KhmerTextStyle.bold,
//         text:
//             "$totalLabel${' ' * (spacesNeeded > 0 ? spacesNeeded : 1)}$totalValue",
//       ),
//     );

//     receiptContent.addAll([
//       StyledTextSegment(text: "អរគុណសម្រាប់ការជាវនៅហាងរបស់យើង"),
//     ]);
//     final khmerBytes = await printRichKhmerTextFor80mm(receiptContent);
//     bytes.addAll(khmerBytes);

//     bytes += generator.cut();

//     return bytes;
//   }

//   static String _formatItemLine({
//     required int itemNumber,
//     required String description,
//     required int quantity,
//     required dynamic price,
//     required dynamic discount,
//     required dynamic amount,
//   }) {
//     try {
//       double p = Helpers.toDouble(price);
//       double d = Helpers.toDouble(discount);
//       double a = Helpers.toDouble(amount);

//       String desc = description.length > colDesc
//           ? description.substring(0, colDesc)
//           : description;

//       String priceStr = p.round() == p
//           ? p.round().toString()
//           : p.toStringAsFixed(2);
//       String discStr = d > 0
//           ? (d.round() == d ? d.round().toString() : d.toStringAsFixed(2))
//           : '-';
//       String amountStr = a.round() == a
//           ? a.round().toString()
//           : a.toStringAsFixed(2);

//       return '${itemNumber.toString().padRight(colNum)}'
//           '${desc.padRight(colDesc)}'
//           '${quantity.toString().padLeft(colQty)}'
//           '${priceStr.padLeft(colPrice)}'
//           '${discStr.padLeft(colDisc)}'
//           '${amountStr.padLeft(colAmt)}';
//     } catch (e) {
//       return 'Err'.padRight(
//         colNum + colDesc + colQty + colPrice + colDisc + colAmt,
//       );
//     }
//   }
// }

//==========================================================================test preview
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/generate_thermal_receipt.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ReceiptMm80 {
  // Column X positions in pixels (for 80mm, ~576px width)
  static const List<double> colX = [
    10, // Item #
    60, // Description
    300, // Qty
    370, // Price
    440, // Disc
    510, // Amount
  ];

  // SHARED METHOD: Generate receipt segments
  static List<StyledTextSegment> _buildReceiptSegments({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
    bool includeImage = false,
  }) {
    List<StyledTextSegment> segments = [];

    // Company name (bold, large)
    if (companyInfo?.name != null) {
      segments.add(
        StyledTextSegment(
          text: companyInfo!.name!,
          style: KhmerTextStyle.bold,
          fontSize: KhmerFontSize.large,
        ),
      );
    }

    // Company details
    if (companyInfo?.address != null) {
      segments.add(
        StyledTextSegment(text: "Address : ${companyInfo!.address}"),
      );
    }
    if (companyInfo?.email != null) {
      segments.add(StyledTextSegment(text: "Email : ${companyInfo!.email}"));
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

    // Separator
    segments.add(StyledTextSegment(text: "-" * 80));

    // Column headers
    segments.add(
      StyledTextSegment(
        text: "#|Description|Qty|Price|Disc|Amount",
        style: KhmerTextStyle.bold,
        isRow: true,
      ),
    );

    segments.add(StyledTextSegment(text: "-" * 80));

    // Items
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

    segments.add(StyledTextSegment(text: "-" * 80));

    // Total Amount
    segments.add(
      StyledTextSegment(
        text: " | | | |Total|${detail?.header.amount ?? ''}",
        style: KhmerTextStyle.bold,
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
  }) {
    double p = Helpers.toDouble(price);
    double d = Helpers.toDouble(discount);
    double a = Helpers.toDouble(amount);

    String desc = description.length > 20
        ? "${description.substring(0, 18)}.."
        : description;

    return "$itemNumber|$desc|$quantity|${p.toStringAsFixed(2)}|${d > 0 ? d.toStringAsFixed(2) : '—'}|${a.toStringAsFixed(2)}";
  }

  static Future<List<int>> generateCustomReceiptBytes({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);
    List<int> bytes = [];

    if (companyInfo != null && companyInfo.logo128 != null) {
      try {
        final response = await http.get(Uri.parse(companyInfo.logo128!));
        if (response.statusCode == 200) {
          final imageBytes = response.bodyBytes;
          final decodedImage = img.decodeImage(imageBytes);
          if (decodedImage != null) {
            final resizedImage = img.copyResize(decodedImage, width: 384);
            bytes += generator.image(resizedImage);
          }
        }
      } catch (e) {
        Logger.log(e);
      }
    }

    final segments = _buildReceiptSegments(
      detail: detail,
      companyInfo: companyInfo,
    );

    final khmerBytes = await printRichKhmerTextFor80mm(segments);
    bytes.addAll(khmerBytes);

    bytes += generator.cut();
    return bytes;
  }
}

// --- Shared Preview Utils ---

List<StyledTextSegment> buildReceiptSegmentsForPreview({
  SaleDetail? detail,
  CompanyInformation? companyInfo,
}) {
  return ReceiptMm80._buildReceiptSegments(
    detail: detail,
    companyInfo: companyInfo,
    includeImage: false,
  );
}

class ReceiptPreview {
  final List<int> bytes;
  final img.Image image;
  ReceiptPreview({required this.bytes, required this.image});
}

Uint8List convertImageToUint8List(img.Image image) {
  final png = img.encodePng(image);
  return Uint8List.fromList(png);
}

Future<ReceiptPreview?> generateReceiptPreview(
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

  final bwImage = convertTo1BitDithered(image);
  final bytes = generator.image(bwImage) + generator.feed(1);

  return ReceiptPreview(bytes: bytes, image: bwImage);
}

img.Image convertTo1BitDithered(img.Image input) {
  final gray = img.grayscale(input);
  final dithered = img.ditherImage(gray);
  return dithered;
}

void showReceiptPreviewDialog(BuildContext context, ReceiptPreview? preview) {
  final Uint8List imageBytes = Uint8List.fromList(
    img.encodePng(preview!.image),
  );
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Receipt Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
    },
  );
}

// --- StyledTextSegment Update ---
