// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:salesforce/core/enums/enums.dart';
// import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
// import 'package:salesforce/core/utils/helpers.dart';
// import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_screen.dart';
// import 'package:salesforce/realm/scheme/schemas.dart';

// class ReceiptPreviewExact extends StatefulWidget {
//   final SaleDetail? detail;
//   final CompanyInformation? companyInfo;

//   const ReceiptPreviewExact({
//     super.key,
//     required this.detail,
//     required this.companyInfo,
//   });

//   @override
//   State<ReceiptPreviewExact> createState() => _ReceiptPreviewExactState();
// }

// class _ReceiptPreviewExactState extends State<ReceiptPreviewExact> {
//   late Future<List<Widget>> _preview;

//   @override
//   void initState() {
//     super.initState();
//     _preview = _generatePreview();
//   }

//   Future<List<Widget>> _generatePreview() async {
//     final List<Widget> parts = [];
//     final detail = widget.detail;
//     final companyInfo = widget.companyInfo;

//     Future<void> addLine(
//       String text, {
//       int fontSize = 24,
//       bool center = false,
//       int maxLines = 1,
//     }) async {
//       final img = await KhmerPrinter.renderKhmerText(
//         text,
//         width: 384,

//         maxLines: maxLines,
//       );
//       parts.add(
//         Align(
//           alignment: center ? Alignment.center : Alignment.centerLeft,
//           child: Image.memory(img.toUint8List(), width: 384),
//         ),
//       );
//     }

//     // === Logo ===
//     if (companyInfo?.logo128 != null && companyInfo!.logo128!.isNotEmpty) {
//       final logo = await _loadLogo(companyInfo.logo128!);
//       if (logo != null) {
//         parts.add(ImageNetWorkWidget(imageUrl: companyInfo.logo128 ?? ""));
//       }
//     }

//     // === Company name ===
//     if (companyInfo?.name != null) {
//       await addLine(
//         companyInfo!.name!,
//         fontSize: 32,
//         center: true,
//         maxLines: 2,
//       );
//     }

//     // === Address ===
//     if (companyInfo?.address != null) {
//       await addLine(
//         companyInfo!.address!,
//         fontSize: 22,
//         center: true,
//         maxLines: 2,
//       );
//     }

//     if (companyInfo?.email?.isNotEmpty ?? false) {
//       await addLine(companyInfo!.email!, fontSize: 20, center: true);
//     }

//     await addLine('=' * 48, fontSize: 22);

//     // === Customer Info ===
//     await addLine('Customer: ${detail?.header.customerName ?? ''}');
//     await addLine('Invoice No: ${detail?.header.no ?? ''}');
//     await addLine('Date: ${detail?.header.documentDate ?? ''}');
//     await addLine('-' * 48, fontSize: 22);

//     // === Table Header ===
//     await addLine(
//       '# Description                    Qty   Price  Disc  Amount',
//       fontSize: 20,
//     );
//     await addLine('-' * 48, fontSize: 22);

//     // === Items ===
//     int i = 1;
//     for (final line in detail?.lines ?? []) {
//       final desc = line.description ?? '';
//       final qty = Helpers.toInt(line.quantity).toString();
//       final price = Helpers.formatNumber(
//         line.unitPrice,
//         option: FormatType.amount,
//       );
//       final disc = line.discountAmount?.toString() ?? '—';
//       final amount = Helpers.formatNumber(
//         line.amountIncludingVat,
//         option: FormatType.amount,
//       );

//       const maxDesc = 24;
//       final descLines = <String>[];
//       if (desc.length <= maxDesc) {
//         descLines.add(desc.padRight(maxDesc));
//       } else {
//         int start = 0;
//         while (start < desc.length) {
//           int end = (start + maxDesc > desc.length)
//               ? desc.length
//               : start + maxDesc;
//           int space = desc.substring(start, end).lastIndexOf(' ');
//           if (space > 0) end = start + space;
//           descLines.add(desc.substring(start, end).padRight(maxDesc));
//           start = end + 1;
//         }
//       }

//       // First line
//       await addLine(
//         '${i.toString().padRight(3)}${descLines[0]}${qty.padLeft(4)} ${price.padLeft(7)} ${disc.padLeft(4)} ${amount.padLeft(7)}',
//         fontSize: 20,
//       );

//       // Continuation lines
//       for (int j = 1; j < descLines.length; j++) {
//         await addLine('   ${descLines[j]}', fontSize: 20);
//       }
//       i++;
//     }

//     await addLine('-' * 48, fontSize: 22);

//     // === Totals ===
//     final header = detail?.header;
//     final subtotal = header?.priceIncludeVat ?? 0;
//     final discount = header?.amount ?? 0;
//     await addLine(
//       'Subtotal: ${Helpers.formatNumber(subtotal, option: FormatType.amount)}',
//     );
//     await addLine(
//       'Discount: -${Helpers.formatNumber(discount, option: FormatType.amount)}',
//     );
//     await addLine(
//       'VAT: ${Helpers.formatNumber(discount, option: FormatType.amount)}',
//     );
//     await addLine('=' * 48, fontSize: 22);
//     await addLine(
//       'TOTAL: ${Helpers.formatNumber(header?.amount ?? 0, option: FormatType.amount)}',
//       fontSize: 26,
//       center: false,
//     );
//     await addLine('=' * 48, fontSize: 22);

//     // === Footer ===
//     const thankYou = 'សូមអរគុណ! Thank you for your business!';
//     await addLine(thankYou, fontSize: 22, center: true, maxLines: 2);
//     await addLine(
//       'We look forward to serving you again!',
//       fontSize: 20,
//       center: true,
//     );
//     await addLine(
//       'Powered by Blue Technology Co., Ltd.',
//       fontSize: 18,
//       center: true,
//     );

//     return parts;
//   }

//   Future<Uint8List?> _loadLogo(String base64Logo) async {
//     try {
//       return Uint8List.fromList(base64Decode(base64Logo));
//     } catch (_) {
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Widget>>(
//       future: _preview,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return Container(
//           color: Colors.white,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: snapshot.data!,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
