// import 'dart:typed_data';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/khmer_font_helpers.dart';

// import 'printer_service.dart';
// import 'package:flutter/material.dart';

// class ReceiptExample extends StatefulWidget {
//   const ReceiptExample({super.key});

//   @override
//   State<ReceiptExample> createState() => _ReceiptExampleState();
// }

// class _ReceiptExampleState extends State<ReceiptExample> {
//   bool _isConnected = false;
//   String _printerName = '';

//   Future<void> _connectPrinter() async {
//     final devices = await PrinterService.scanDevices();
//     if (devices.isNotEmpty) {
//       // Example: use the first printer found
//       final device = devices.first;
//       final address = device['address'] ?? device['uuid'];
//       final success = await PrinterService.connect(address);
//       if (success) {
//         setState(() {
//           _isConnected = true;
//           _printerName = device['name'] ?? 'Unknown';
//         });
//       }
//     }
//   }

//   Future<void> _printReceipt() async {
//     if (!_isConnected) {
//       print("⚠️ Not connected to printer");
//       return;
//     }

//     // 1️⃣ Start with printer reset
//     final List<int> receiptData = [0x1B, 0x40]; // ESC @

//     // 2️⃣ Print English line
//     receiptData.addAll("Blue Technology Co., Ltd.\n".codeUnits);
//     receiptData.addAll("Tel: 012345678\n".codeUnits);

//     // 3️⃣ Render Khmer text via native code
//     final khmerData = await PrinterService.renderKhmerText(
//       "សូមអរគុណចំពោះការទិញទំនិញរបស់លោកអ្នក",
//       width: 384,
//       fontSize: 18,
//     );

//     if (khmerData != null) {
//       receiptData.addAll(khmerData);
//     }

//     // 4️⃣ Print totals
//     receiptData.addAll("Total: \$25.00\n".codeUnits);

//     // 5️⃣ Cut paper
//     receiptData.addAll([0x1D, 0x56, 0x00]); // GS V 0

//     await PrinterService.printRaw(Uint8List.fromList(receiptData));
//     print("✅ Receipt sent to printer");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Receipt Printer Example")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: _connectPrinter,
//               child: const Text("Connect Printer"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _printReceipt,
//               child: const Text("Print Receipt"),
//             ),
//             if (_isConnected)
//               Text("Connected: $_printerName", style: const TextStyle(color: Colors.green)),
//           ],
//         ),
//       ),
//     );
//   }
// }
