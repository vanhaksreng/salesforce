// // Improved Receipt Builder with Perfect Column Alignment
// // This version uses pixel-perfect rendering with proper Khmer support

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/khmer_text_render.dart';

// class ImprovedReceiptBuilder {
//   // Print width configuration
//   static const double printWidth = 576;
//   static const int paddingVertical = 2;

//   // Column width configuration (in pixels)
//   static const ReceiptColumnConfig columnConfig = ReceiptColumnConfig(
//     itemNumber: 40, // "#"
//     description: 200, // Description (wider for Khmer)
//     quantity: 70, // Qty
//     price: 90, // Price
//     discount: 70, // Disc
//     amount: 100, // Amount
//   );

//   /// Main method to build receipt preview image
//   static Future<Uint8List> buildReceiptPreviewImage({
//     required SaleDetail? detail,
//     required CompanyInformation? companyInfo,
//   }) async {
//     final images = <img.Image>[];

//     try {
//       // 1️⃣ Logo Section
//       await _addLogo(images, companyInfo);

//       // 2️⃣ Company Information
//       await _addCompanyInfo(images, companyInfo);

//       // 3️⃣ Divider
//       images.add(_createDivider(heavy: true));
//       images.add(_createSpacing(10));

//       // 4️⃣ Customer & Invoice Info
//       await _addInvoiceInfo(images, detail);

//       // 5️⃣ Table Header
//       images.add(_createDivider());
//       await _addTableHeader(images);
//       images.add(_createDivider());

//       // 6️⃣ Line Items
//       await _addLineItems(images, detail);

//       // 7️⃣ Totals Section
//       images.add(_createDivider());
//       await _addTotals(images, detail);

//       // 8️⃣ Footer
//       images.add(_createDivider(heavy: true));
//       images.add(_createSpacing(10));
//       await _addFooter(images);
//       images.add(_createSpacing(30));

//       // 9️⃣ Combine all images vertically
//       return _combineImages(images);
//     } catch (e) {
//       debugPrint("❌ Critical error in buildReceiptPreviewImage: $e");
//       rethrow;
//     }
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // LOGO SECTION
//   // ═══════════════════════════════════════════════════════════════

//   static Future<void> _addLogo(
//     List<img.Image> images,
//     CompanyInformation? companyInfo,
//   ) async {
//     if (companyInfo?.logo128?.isNotEmpty != true) return;

//     try {
//       final logoImage = await _loadLogoForPrinter(companyInfo!.logo128!);
//       if (logoImage != null) {
//         final centered = _centerImage(logoImage, verticalPadding: 8);
//         images.add(centered);
//         images.add(_createSpacing(5));
//       }
//     } catch (e) {
//       debugPrint("⚠️ Logo rendering failed: $e");
//     }
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // COMPANY INFO SECTION
//   // ═══════════════════════════════════════════════════════════════

//   static Future<void> _addCompanyInfo(
//     List<img.Image> images,
//     CompanyInformation? companyInfo,
//   ) async {
//     if (companyInfo?.name?.isNotEmpty == true) {
//       images.add(
//         await _renderText(
//           companyInfo!.name!,
//           fontSize: KhmerTextRenderer.containsKhmer(companyInfo.name!)
//               ? 26
//               : 22,
//           align: KhmerTextAlign.center,
//           bold: true,
//           maxLines: 2,
//         ),
//       );
//     }

//     if (companyInfo?.address?.isNotEmpty == true) {
//       images.add(
//         await _renderText(
//           companyInfo?.address ?? "",
//           fontSize: 18,
//           align: KhmerTextAlign.center,
//           maxLines: 3,
//         ),
//       );
//     }

//     if (companyInfo?.email?.isNotEmpty == true) {
//       images.add(
//         await _renderText(
//           companyInfo?.email ?? "",
//           fontSize: 18,
//           align: KhmerTextAlign.center,
//         ),
//       );
//     }

//     if (companyInfo?.phone?.isNotEmpty == true) {
//       images.add(
//         await _renderText(
//           'Tel: ${companyInfo?.phone}',
//           fontSize: 18,
//           align: KhmerTextAlign.center,
//         ),
//       );
//     }
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // INVOICE INFO SECTION
//   // ═══════════════════════════════════════════════════════════════

//   static Future<void> _addInvoiceInfo(
//     List<img.Image> images,
//     SaleDetail? detail,
//   ) async {
//     if (detail?.header.customerName?.isNotEmpty == true) {
//       images.add(
//         await _renderText(
//           'Customer: ${detail!.header.customerName}',
//           fontSize: 18,
//           align: KhmerTextAlign.left,
//         ),
//       );
//     }

//     if (detail?.header.no?.isNotEmpty == true) {
//       images.add(
//         await _renderText(
//           'Invoice No: ${detail!.header.no}',
//           fontSize: 18,
//           align: KhmerTextAlign.left,
//         ),
//       );
//     }

//     final date = detail?.header.documentDate ?? '';
//     if (date.isNotEmpty) {
//       images.add(
//         await _renderText(
//           'Date: $date',
//           fontSize: 18,
//           align: KhmerTextAlign.left,
//         ),
//       );
//     }

//     images.add(_createSpacing(5));
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // TABLE HEADER
//   // ═══════════════════════════════════════════════════════════════

//   static Future<void> _addTableHeader(List<img.Image> images) async {
//     final headerRow = await _createTableRow(
//       itemNumber: '#',
//       description: 'Description',
//       quantity: 'Qty',
//       price: 'Price',
//       discount: 'Disc',
//       amount: 'Amount',
//       bold: true,
//       fontSize: 16,
//     );
//     images.add(headerRow);
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // LINE ITEMS
//   // ═══════════════════════════════════════════════════════════════

//   static Future<void> _addLineItems(
//     List<img.Image> images,
//     SaleDetail? detail,
//   ) async {
//     int itemNumber = 1;

//     for (final line in detail?.lines ?? []) {
//       try {
//         final description = (line.description ?? '').trim();
//         final qty = Helpers.toInt(line.quantity).toString();
//         final price = Helpers.formatNumber(
//           line.unitPrice,
//           option: FormatType.amount,
//         );
//         final disc = (line.discountAmount != null && line.discountAmount! > 0)
//             ? Helpers.formatNumber(
//                 line.discountAmount!,
//                 option: FormatType.amount,
//               )
//             : '-';
//         final amount = Helpers.formatNumber(
//           line.amountIncludingVat,
//           option: FormatType.amount,
//         );

//         // Render item row
//         final itemRow = await _createTableRow(
//           itemNumber: itemNumber.toString(),
//           description: description,
//           quantity: qty,
//           price: price,
//           discount: disc,
//           amount: amount,
//           fontSize: 16,
//         );

//         images.add(itemRow);
//         itemNumber++;
//       } catch (e) {
//         debugPrint("⚠️ Item $itemNumber rendering failed: $e");
//       }
//     }
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // TOTALS SECTION
//   // ═══════════════════════════════════════════════════════════════

//   static Future<void> _addTotals(
//     List<img.Image> images,
//     SaleDetail? detail,
//   ) async {
//     // Subtotal
//     if (detail?.header.priceIncludeVat != null) {
//       images.add(
//         await _renderText(
//           'Subtotal: ${Helpers.formatNumber(detail!.header.priceIncludeVat!, option: FormatType.amount)}',
//           fontSize: 18,
//           align: KhmerTextAlign.right,
//         ),
//       );
//     }

//     // Discount
//     final discountAmount = detail?.header.discountAmount ?? 0;
//     if (discountAmount > 0) {
//       images.add(
//         await _renderText(
//           'Discount: -${Helpers.formatNumber(discountAmount, option: FormatType.amount)}',
//           fontSize: 18,
//           align: KhmerTextAlign.right,
//         ),
//       );
//     }

//     // VAT
//     final vatAmount = detail?.header.vatAmount ?? 0;
//     if (vatAmount > 0) {
//       images.add(
//         await _renderText(
//           'VAT: ${Helpers.formatNumber(vatAmount, option: FormatType.amount)}',
//           fontSize: 18,
//           align: KhmerTextAlign.right,
//         ),
//       );
//     }

//     // Total (prominent)
//     images.add(_createSpacing(5));
//     images.add(
//       await _renderText(
//         'TOTAL: ${Helpers.formatNumber(detail?.header.amount ?? 0, option: FormatType.amount)}',
//         fontSize: 24,
//         align: KhmerTextAlign.right,
//         bold: true,
//       ),
//     );
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // FOOTER SECTION
//   // ═══════════════════════════════════════════════════════════════

//   static Future<void> _addFooter(List<img.Image> images) async {
//     // Thank you message (bilingual)
//     images.add(
//       await _renderText(
//         'សូមអរគុណ! Thank you!',
//         fontSize: 20,
//         align: KhmerTextAlign.center,
//         bold: true,
//         maxLines: 2,
//       ),
//     );

//     images.add(_createSpacing(5));

//     images.add(
//       await _renderText(
//         'We look forward to serving you again!',
//         fontSize: 16,
//         align: KhmerTextAlign.center,
//       ),
//     );

//     images.add(_createSpacing(10));

//     // Powered by
//     images.add(
//       await _renderText(
//         'Powered by Blue Technology Co., Ltd.',
//         fontSize: 14,
//         align: KhmerTextAlign.center,
//       ),
//     );
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // TABLE ROW CREATION (Perfect Column Alignment)
//   // ═══════════════════════════════════════════════════════════════

//   static Future<img.Image> _createTableRow({
//     required String itemNumber,
//     required String description,
//     required String quantity,
//     required String price,
//     required String discount,
//     required String amount,
//     bool bold = false,
//     double fontSize = 16,
//   }) async {
//     final columns = <img.Image>[];

//     // Column 1: Item Number (Left aligned)
//     columns.add(
//       await _renderTextWithWidth(
//         itemNumber,
//         width: columnConfig.itemNumber,
//         fontSize: fontSize,
//         bold: bold,
//         align: KhmerTextAlign.left,
//       ),
//     );

//     // Column 2: Description (Left aligned, can be Khmer)
//     columns.add(
//       await _renderTextWithWidth(
//         description,
//         width: columnConfig.description,
//         fontSize: fontSize,
//         bold: bold,
//         align: KhmerTextAlign.left,
//         maxLines: 3, // Allow wrapping for long descriptions
//       ),
//     );

//     // Column 3: Quantity (Right aligned, monospace)
//     columns.add(
//       await _renderTextWithWidth(
//         quantity,
//         width: columnConfig.quantity,
//         fontSize: fontSize,
//         bold: bold,
//         align: KhmerTextAlign.right,
//         monospace: true,
//       ),
//     );

//     // Column 4: Price (Right aligned, monospace)
//     columns.add(
//       await _renderTextWithWidth(
//         price,
//         width: columnConfig.price,
//         fontSize: fontSize,
//         bold: bold,
//         align: KhmerTextAlign.right,
//         monospace: true,
//       ),
//     );

//     // Column 5: Discount (Right aligned, monospace)
//     columns.add(
//       await _renderTextWithWidth(
//         discount,
//         width: columnConfig.discount,
//         fontSize: fontSize,
//         bold: bold,
//         align: KhmerTextAlign.right,
//         monospace: true,
//       ),
//     );

//     // Column 6: Amount (Right aligned, monospace)
//     columns.add(
//       await _renderTextWithWidth(
//         amount,
//         width: columnConfig.amount,
//         fontSize: fontSize,
//         bold: bold,
//         align: KhmerTextAlign.right,
//         monospace: true,
//       ),
//     );

//     return _composeRow(columns);
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // HELPER METHODS - TEXT RENDERING
//   // ═══════════════════════════════════════════════════════════════

//   static Future<img.Image> _renderText(
//     String text, {
//     double fontSize = 18,
//     KhmerTextAlign align = KhmerTextAlign.left,
//     bool bold = false,
//     bool monospace = false,
//     int maxLines = 0,
//   }) async {
//     final style = KhmerTextStyle(
//       fontSize: fontSize,
//       bold: bold,
//       alignment: align,
//       monospace: monospace,
//     );

//     final data = await KhmerTextRenderer.renderText(
//       text,
//       width: printWidth,
//       style: style,
//       maxLines: maxLines,
//     );

//     if (data == null) {
//       return _createEmptyImage(printWidth.toInt(), 20);
//     }

//     img.Image rendered = img.decodePng(data)!;
//     return _trimVerticalWhitespace(rendered, padding: paddingVertical);
//   }

//   static Future<img.Image> _renderTextWithWidth(
//     String text, {
//     required double width,
//     double fontSize = 18,
//     KhmerTextAlign align = KhmerTextAlign.left,
//     bool bold = false,
//     bool monospace = false,
//     int maxLines = 1,
//   }) async {
//     final style = KhmerTextStyle(
//       fontSize: fontSize,
//       bold: bold,
//       alignment: align,
//       monospace: monospace,
//     );

//     final data = await KhmerTextRenderer.renderText(
//       text,
//       width: width,
//       style: style,
//       maxLines: maxLines,
//     );

//     if (data == null) {
//       return _createEmptyImage(width.toInt(), 20);
//     }

//     img.Image rendered = img.decodePng(data)!;

//     // Ensure exact width by padding/cropping
//     if (rendered.width != width.toInt()) {
//       return _ensureExactWidth(rendered, width.toInt());
//     }

//     return rendered;
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // HELPER METHODS - IMAGE COMPOSITION
//   // ═══════════════════════════════════════════════════════════════

//   static img.Image _composeRow(List<img.Image> columns) {
//     if (columns.isEmpty) {
//       return _createEmptyImage(printWidth.toInt(), 20);
//     }

//     // Find maximum height among all columns
//     final maxHeight = columns.fold<int>(
//       0,
//       (max, col) => col.height > max ? col.height : max,
//     );

//     // Create row canvas
//     final row = img.Image(width: printWidth.toInt(), height: maxHeight);
//     img.fill(row, color: img.ColorRgb8(255, 255, 255));

//     // Composite columns horizontally
//     int xOffset = 0;
//     for (final col in columns) {
//       // Vertically center shorter columns
//       final yOffset = (maxHeight - col.height) ~/ 2;
//       img.compositeImage(row, col, dstX: xOffset, dstY: yOffset);
//       xOffset += col.width;
//     }

//     return row;
//   }

//   static img.Image _centerImage(img.Image image, {int verticalPadding = 0}) {
//     final centered = img.Image(
//       width: printWidth.toInt(),
//       height: image.height + (verticalPadding * 2),
//     );
//     img.fill(centered, color: img.ColorRgb8(255, 255, 255));

//     final xOffset = (printWidth - image.width) ~/ 2;
//     img.compositeImage(centered, image, dstX: xOffset, dstY: verticalPadding);

//     return centered;
//   }

//   static img.Image _ensureExactWidth(img.Image image, int targetWidth) {
//     final canvas = img.Image(width: targetWidth, height: image.height);
//     img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

//     if (image.width <= targetWidth) {
//       // Center if smaller
//       final xOffset = (targetWidth - image.width) ~/ 2;
//       img.compositeImage(canvas, image, dstX: xOffset, dstY: 0);
//     } else {
//       // Crop if larger
//       final cropped = img.copyCrop(
//         image,
//         x: 0,
//         y: 0,
//         width: targetWidth,
//         height: image.height,
//       );
//       img.compositeImage(canvas, cropped, dstX: 0, dstY: 0);
//     }

//     return canvas;
//   }

//   static Uint8List _combineImages(List<img.Image> images) {
//     final totalHeight = images.fold<int>(0, (sum, img) => sum + img.height);

//     final combined = img.Image(width: printWidth.toInt(), height: totalHeight);
//     img.fill(combined, color: img.ColorRgb8(255, 255, 255));

//     int yOffset = 0;
//     for (final image in images) {
//       img.compositeImage(combined, image, dstY: yOffset);
//       yOffset += image.height;
//     }

//     return Uint8List.fromList(img.encodePng(combined));
//   }

//   // ═══════════════════════════════════════════════════════════════
//   // HELPER METHODS - UTILITIES
//   // ═══════════════════════════════════════════════════════════════

//   static img.Image _createSpacing(int height) {
//     final spacing = img.Image(width: printWidth.toInt(), height: height);
//     img.fill(spacing, color: img.ColorRgb8(255, 255, 255));
//     return spacing;
//   }

//   static img.Image _createDivider({bool heavy = false}) {
//     final char = heavy ? '═' : '─';
//     final text = char * 64;

//     // Create a simple divider using pixels
//     final divider = img.Image(width: printWidth.toInt(), height: heavy ? 3 : 1);
//     img.fill(divider, color: img.ColorRgb8(0, 0, 0));

//     return divider;
//   }

//   static img.Image _createEmptyImage(int width, int height) {
//     final empty = img.Image(width: width, height: height);
//     img.fill(empty, color: img.ColorRgb8(255, 255, 255));
//     return empty;
//   }

//   static img.Image _trimVerticalWhitespace(img.Image image, {int padding = 1}) {
//     int? topCrop;
//     int? bottomCrop;

//     // Find first non-white row from top
//     for (int y = 0; y < image.height; y++) {
//       if (_rowHasContent(image, y)) {
//         topCrop = (y - padding).clamp(0, image.height - 1);
//         break;
//       }
//     }

//     // Find last non-white row from bottom
//     for (int y = image.height - 1; y >= 0; y--) {
//       if (_rowHasContent(image, y)) {
//         bottomCrop = (y + padding).clamp(0, image.height - 1);
//         break;
//       }
//     }

//     if (topCrop == null || bottomCrop == null || topCrop >= bottomCrop) {
//       return image;
//     }

//     final newHeight = (bottomCrop - topCrop + 1).clamp(1, image.height);

//     return img.copyCrop(
//       image,
//       x: 0,
//       y: topCrop,
//       width: image.width,
//       height: newHeight,
//     );
//   }

//   static bool _rowHasContent(img.Image image, int y) {
//     const threshold = 240;
//     for (int x = 0; x < image.width; x++) {
//       final pixel = image.getPixel(x, y);
//       if (pixel.r < threshold || pixel.g < threshold || pixel.b < threshold) {
//         return true;
//       }
//     }
//     return false;
//   }

//   static Future<img.Image?> _loadLogoForPrinter(String base64Logo) async {
//     // Implement your logo loading logic here
//     // This is a placeholder - replace with your actual implementation
//     return null;
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // CONFIGURATION CLASSES
// // ═══════════════════════════════════════════════════════════════

// class ReceiptColumnConfig {
//   final double itemNumber;
//   final double description;
//   final double quantity;
//   final double price;
//   final double discount;
//   final double amount;

//   const ReceiptColumnConfig({
//     required this.itemNumber,
//     required this.description,
//     required this.quantity,
//     required this.price,
//     required this.discount,
//     required this.amount,
//   });

//   double get totalWidth =>
//       itemNumber + description + quantity + price + discount + amount;
// }

// // ═══════════════════════════════════════════════════════════════
// // PLACEHOLDER CLASSES (Replace with your actual models)
// // ═══════════════════════════════════════════════════════════════

// class SaleDetail {
//   final SaleHeader header;
//   final List<PosSalesLine> lines;

//   SaleDetail({required this.header, required this.lines});
// }

// class SaleHeader {
//   final String? customerName;
//   final String? no;
//   final String? documentDate;
//   final double? priceIncludeVat;
//   final double? discountAmount;
//   final double? vatAmount;
//   final double? amount;

//   SaleHeader({
//     this.customerName,
//     this.no,
//     this.documentDate,
//     this.priceIncludeVat,
//     this.discountAmount,
//     this.vatAmount,
//     this.amount,
//   });
// }

// class PosSalesLine {
//   final String? description;
//   final double? quantity;
//   final double? unitPrice;
//   final double? discountAmount;
//   final double? amountIncludingVat;

//   PosSalesLine({
//     this.description,
//     this.quantity,
//     this.unitPrice,
//     this.discountAmount,
//     this.amountIncludingVat,
//   });
// }

// class CompanyInformation {
//   final String? name;
//   final String? address;
//   final String? email;
//   final String? phone;
//   final String? logo128;

//   CompanyInformation({
//     this.name,
//     this.address,
//     this.email,
//     this.phone,
//     this.logo128,
//   });
// }

// class Helpers {
//   static int toInt(double? value) => value?.toInt() ?? 0;

//   static String formatNumber(double? value, {FormatType? option}) {
//     if (value == null) return '\$0.00';
//     return '\$${value.toStringAsFixed(2)}';
//   }
// }

// enum FormatType { amount }
