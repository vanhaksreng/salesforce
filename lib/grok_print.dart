// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/scheduler.dart';

// /// Captures the Khmer receipt as PNG bytes (offscreen, invisible to user).
// /// Call from a built context, e.g., onPressed: () => captureKhmerReceipt(context)
// Future<Uint8List> captureKhmerReceipt(BuildContext context) async {
//   final completer = Completer<Uint8List>();
  
//   // GlobalKey for the RepaintBoundary
//   final GlobalKey globalKey = GlobalKey();
  
//   // Build the receipt widget (your template)
//   final Widget receiptContent = Container(
//     width: 300.0,  // ~80mm paper width (adjust DPI: 576 dots / 72 DPI ≈ 8in, but pixels for render)
//     padding: const EdgeInsets.all(8.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Header: Company Name in Khmer and English
//         Center(
//           child: Column(
//             children: [
//               Text(
//                 'អាជីវកម្ម',  // Khmer header (customize as needed)
//                 style: GoogleFonts.notoSansKhmer(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 'MONISUN CO.,LTD',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               ),
//               const Text(
//                 'VATIN: K005-901704358',
//                 style: TextStyle(fontSize: 10),
//               ),
//               const Text(
//                 'Street 215, Phsar Depot 3, Toul Kork, Phnom Penh',
//                 style: TextStyle(fontSize: 9),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 2),
//               const Text(
//                 'Tel: 096 30 43250',
//                 style: TextStyle(fontSize: 10),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),

//         // Divider
//         const Divider(thickness: 1, color: Colors.black),

//         // Title: Khmer + English "TAX INVOICE"
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 'ពន្ធ វិក្កយបត្រ',  // Khmer for "Tax Invoice"
//                 style: GoogleFonts.notoSansKhmer(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const Expanded(
//               child: Text(
//                 'TAX INVOICE',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.right,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),

//         // Customer Details (right-aligned for PANHA BOY etc.)
//         const Text(
//           'Customer ID:',
//           style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: const [
//             Text(
//               'PANHA BOY',
//               style: TextStyle(fontSize: 10),
//             ),
//           ],
//         ),
//         const SizedBox(height: 2),
//         const Text(
//           'Customer Name:',
//           style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: const [
//             Text(
//               'Boy123',
//               style: TextStyle(fontSize: 10),
//             ),
//           ],
//         ),
//         const SizedBox(height: 2),
//         const Text(
//           'Tel:',
//           style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: const [
//             Text(
//               '089214054',
//               style: TextStyle(fontSize: 10),
//             ),
//           ],
//         ),
//         const SizedBox(height: 2),
//         const Text(
//           'Invoice No:',
//           style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: const [
//             Text(
//               'S00000000003',
//               style: TextStyle(fontSize: 10),
//             ),
//           ],
//         ),
//         const SizedBox(height: 2),
//         const Text(
//           'Date:',
//           style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: const [
//             Text(
//               '31-Oct-2025',
//               style: TextStyle(fontSize: 10),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),

//         // Items Table Header
//         Row(
//           children: [
//             const Expanded(flex: 1, child: Text('#', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
//             const Expanded(flex: 3, child: Text('Description', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
//             const Expanded(flex: 1, child: Text('QTY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
//             const Expanded(flex: 1, child: Text('Amt', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
//           ],
//         ),
//         const SizedBox(height: 4),

//         // Items (using your template)
//         _buildItemRow('#1', 'Puthea', '1', '44\$'),
//         _buildItemRow('#2', 'Rice', '1', '11.62\$'),
//         _buildItemRow('#3', 'General Knowledge Book', '5', '4\$'),
//         _buildItemRow('#4', 'Pentel Marker Blue', '4', '40\$'),

//         const SizedBox(height: 8),

//         // Totals (right-aligned)
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: const [
//             Expanded(child: Text('Sub Total:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
//             Text('94.56\$', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: const [
//             Expanded(child: Text('VAT 20%:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
//             Text('5.06\$', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: const BoxDecoration(
//             border: Border(top: BorderSide(color: Colors.black, width: 2)),
//           ),
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Expanded(child: Text('Grand Total:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
//               Text('99.62\$', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),

//         const SizedBox(height: 8),

//         // Footer
//         Center(
//           child: Column(
//             children: const [
//               Text(
//                 'Tel: 096 30 43250',
//                 style: TextStyle(fontSize: 10),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );

//   // Offscreen capture logic (adapted from https://gist.github.com/slightfoot/8eeadd8028c373df87f3a47bd4a35e36)
//   // Temporarily overlay the receipt offscreen using Stack + Positioned
//   OverlayEntry? overlayEntry;
//   overlayEntry = OverlayEntry(
//     builder: (context) => LayoutBuilder(
//       builder: (context, constraints) {
//         final offscreenHeight = constraints.maxHeight * 2;  // Push offscreen
//         return Stack(
//           fit: StackFit.passthrough,
//           children: [
//             // Invisible placeholder (no child here, as it's utility)
//             Positioned(
//               left: 0,
//               right: 0,
//               top: offscreenHeight,  // Offscreen
//               height: offscreenHeight,
//               child: RepaintBoundary(
//                 key: globalKey,
//                 child: receiptContent,  // Your receipt
//               ),
//             ),
//           ],
//         );
//       },
//     ),
//   );

//   // Insert into overlay tree
//   Overlay.of(context).insert(overlayEntry);

//   // Wait for layout (post-frame)
//   await SchedulerBinding.instance.endOfFrame;
  
//   try {
//     // Now capture (context is available after build)
//     final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     final pixelRatio = MediaQuery.of(context).devicePixelRatio;
//     final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio * 2.0);  // Higher for print clarity
//     final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     completer.complete(byteData!.buffer.asUint8List());
//   } catch (e) {
//     completer.completeError(e);
//   } finally {
//     // Clean up overlay
//     overlayEntry.remove();
//   }

//   return completer.future;
// }

// // Helper for item rows (unchanged)
// Widget _buildItemRow(String num, String desc, String qty, String amt) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 1.0),
//     child: Row(
//       children: [
//         Expanded(flex: 1, child: Text(num, style: const TextStyle(fontSize: 9))),
//         Expanded(
//           flex: 3,
//           child: Text(
//             desc,
//             style: const TextStyle(fontSize: 9),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         Expanded(flex: 1, child: Text(qty, style: const TextStyle(fontSize: 9))),
//         Expanded(flex: 1, child: Text(amt, style: const TextStyle(fontSize: 9))),
//       ],
//     ),
//   );
// }