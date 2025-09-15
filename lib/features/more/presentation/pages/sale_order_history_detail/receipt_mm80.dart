import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/generate_thermal_receipt.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ReceiptMm80 {
  // Column widths (adjust for 80mm paper)
  static const int colNum = 3; // Item #
  static const int colDesc = 25; // Description
  static const int colQty = 10; // Quantity
  static const int colPrice = 10; // Price
  static const int colDisc = 10; // Discount
  static const int colAmt = 10; // Amount

  static Future<List<int>> generateCustomReceiptBytes({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    print(
      "================== Generating Receipt ==================${{companyInfo?.logo128}}",
    );
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);
    List<int> bytes = [];

    List<StyledTextSegment> receiptContent = [];

    if (companyInfo != null && companyInfo.logo128 != null) {
      try {
        final response = await http.get(Uri.parse(companyInfo.logo128 ?? ""));
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

    receiptContent.add(
      StyledTextSegment(text: "Address : #${companyInfo?.address}"),
    );

    receiptContent.add(
      StyledTextSegment(text: "Email : #${companyInfo?.email}"),
    );

    receiptContent.add(
      StyledTextSegment(text: "Customer :  ${detail?.header.customerName}"),
    );
    receiptContent.add(
      StyledTextSegment(text: "Date :  ${detail?.header.documentDate}"),
    );
    receiptContent.add(
      StyledTextSegment(text: "Invoice No :  ${detail?.header.no}"),
    );
    receiptContent.add(
      StyledTextSegment(text: "Invoice Type :  ${detail?.header.documentType}"),
    );
    bytes += generator.hr(ch: "-");

    // Column headers
    receiptContent.add(
      StyledTextSegment(
        text:
            '${"#".padRight(colNum)}'
            '${"Description".padRight(colDesc)}'
            '${"Qty".padLeft(colQty)}'
            '${"Price".padLeft(colPrice)}'
            '${"Disc".padLeft(colDisc)}'
            '${"Amount".padLeft(colAmt)}\n',
      ),
    );

    // Separator line
    bytes += generator.hr(ch: "-");

    // Items
    int itemNumber = 1;

    for (PosSalesLine item in (detail?.lines ?? [])) {
      try {
        String description = (item.description ?? '').trim();

        String itemLine = _formatItemLine(
          itemNumber: itemNumber,
          description: description,
          quantity: Helpers.toInt(item.quantity),
          price: item.unitPrice,
          discount: item.discountAmount ?? 0,
          amount: item.amountIncludingVat ?? 0,
        );

        receiptContent.add(StyledTextSegment(text: "$itemLine\n"));
      } catch (e) {
        receiptContent.add(StyledTextSegment(text: "X Error Item\n"));
      }
      itemNumber++;
    }
    bytes += generator.hr(ch: "-");

    // Replace this line:
    receiptContent.add(
      StyledTextSegment(text: "Total Amount ${detail?.header.amount}"),
    );

    // With this code for space-between alignment:
    String totalLabel = "Total Amount";
    String totalValue = "${detail?.header.amount}";
    int totalWidth =
        colNum +
        colDesc +
        colQty +
        colPrice +
        colDisc +
        colAmt; // Total receipt width
    int spacesNeeded = totalWidth - totalLabel.length - totalValue.length;

    receiptContent.add(
      StyledTextSegment(
        style: KhmerTextStyle.bold,
        text:
            "$totalLabel${' ' * (spacesNeeded > 0 ? spacesNeeded : 1)}$totalValue",
      ),
    );

    receiptContent.addAll([
      StyledTextSegment(text: "Thanks for buying at our shop\n"),
    ]);

    // Logo

    // Generate Khmer text
    final khmerBytes = await printRichKhmerTextFor80mm(receiptContent);
    bytes.addAll(khmerBytes);
    bytes += generator.cut();

    return bytes;
  }

  // Format individual item line
  static String _formatItemLine({
    required int itemNumber,
    required String description,
    required int quantity,
    required dynamic price,
    required dynamic discount,
    required dynamic amount,
  }) {
    try {
      double p = Helpers.toDouble(price);
      double d = Helpers.toDouble(discount);
      double a = Helpers.toDouble(amount);

      String desc = description.length > colDesc
          ? description.substring(0, colDesc)
          : description;

      String priceStr = p.round() == p
          ? p.round().toString()
          : p.toStringAsFixed(2);
      String discStr = d > 0
          ? (d.round() == d ? d.round().toString() : d.toStringAsFixed(2))
          : '-';
      String amountStr = a.round() == a
          ? a.round().toString()
          : a.toStringAsFixed(2);

      return '${itemNumber.toString().padRight(colNum)}'
          '${desc.padRight(colDesc)}'
          '${quantity.toString().padLeft(colQty)}'
          '${priceStr.padLeft(colPrice)}'
          '${discStr.padLeft(colDisc)}'
          '${amountStr.padLeft(colAmt)}';
    } catch (e) {
      return 'Err'.padRight(
        colNum + colDesc + colQty + colPrice + colDisc + colAmt,
      );
    }
  }
}
