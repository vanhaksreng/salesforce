// import 'package:flutter/material.dart';
// import 'package:html_2_pdf/imin_device/imin_printer_service.dart';

// class IminM203App extends StatefulWidget {
//   @override
//   _IminM203AppState createState() => _IminM203AppState();
// }

// class _IminM203AppState extends State<IminM203App> {
//   @override
//   void initState() {
//     super.initState();

//     initPrinter();
//   }

//   // Future<void> initPrinter() async {
//   //   String? initResult = await IminPrinterService.initializeSDK();
//   //   if (initResult != null) {
//   //     print("SDK initialized: $initResult");

//   //     // Print some text
//   //     String? printResult = await IminPrinterService.printText("Hello World!");
//   //     if (printResult != null) {
//   //       print("Print result: $printResult");
//   //     }
//   //   }
//   // }

//   Future<void> initPrinter() async {
//     try {
//       // Initialize SDK
//       String? initResult = await IminPrinterService.initializeSDK();
//       if (initResult == null) {
//         print("Failed to initialize SDK");
//         return;
//       }
//       print("SDK initialized: $initResult");

//       // Set print density (try values between 1-15)
//       await IminPrinterService.setPrintDensity(10);

//       // Check printer status
//       String? status = await IminPrinterService.checkPrinterStatus();
//       print("Printer status: $status");

//       // Wait for printer to be ready
//       await Future.delayed(Duration(seconds: 2));

//       // Test print with clear formatting
//       String testText = "=== TEST PRINT ===\n";
//       testText += "Hello World!\n";
//       testText += "Print Test Successful\n";
//       testText += "==================\n\n";

//       String? printResult =
//           await IminPrinterService.printTextWithFeed(testText);
//       if (printResult != null) {
//         print("Print result: $printResult");
//       } else {
//         print("Print failed");
//       }
//     } catch (e) {
//       print("Error during printer initialization: $e");
//     }
//   }

//   // Future<void> printReceipt() async {
//   //   try {
//   //     // Set printer style
//   //     await iminPrinter.setAlignment(IminPrintAlign.center);
//   //     await iminPrinter.setTextSize(30);

//   //     // Print store header
//   //     await iminPrinter.printText("FLUTTER STORE");
//   //     await iminPrinter.printAndLineFeed();

//   //     // Print separator line
//   //     await iminPrinter.setAlignment(IminPrintAlign.left);
//   //     await iminPrinter.printText("--------------------------------");
//   //     await iminPrinter.printAndLineFeed();

//   //     // Print items
//   //     await iminPrinter.printText("Item 1.............\$10.00");
//   //     await iminPrinter.printAndLineFeed();
//   //     await iminPrinter.printText("Item 2.............\$15.50");
//   //     await iminPrinter.printAndLineFeed();

//   //     // Print total
//   //     await iminPrinter.printText("--------------------------------");
//   //     await iminPrinter.printAndLineFeed();
//   //     // await iminPrinter.setTextStyle();
//   //     await iminPrinter.printText("TOTAL:.............\$25.50");
//   //     await iminPrinter.printAndLineFeed();

//   //     // Print QR code
//   //     await iminPrinter.setAlignment(IminPrintAlign.center);
//   //     await iminPrinter.printQrCode(
//   //       "https://example.com/receipt/123",
//   //     );
//   //     await iminPrinter.printAndLineFeed();

//   //     // Feed paper and cut (if cutter available)
//   //     await iminPrinter.partialCut();

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Receipt printed successfully!')),
//   //     );
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Print failed: $e')),
//   //     );
//   //   }
//   // }

//   // Future<void> printBarcode() async {
//   //   try {
//   //     await iminPrinter.setAlignment(IminPrintAlign.center);
//   //     await iminPrinter.printBarCode(
//   //       IminBarcodeType.upcA,
//   //       "123456789012",
//   //       // IminBarcodeTextPos.textBelow,
//   //       // 100,
//   //       // 2,
//   //     );
//   //     await iminPrinter.printAndLineFeed();
//   //     await iminPrinter.partialCut();

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Barcode printed successfully!')),
//   //     );
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Barcode print failed: $e')),
//   //     );
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Imin M2-203 Flutter App'),
//         backgroundColor: Colors.blue[800],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Icon(Icons.print, size: 48, color: Colors.blue[800]),
//                   SizedBox(height: 8),
//                   Text(
//                     'Imin M2-203 Printer Functions',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   Text('Control the built-in thermal printer'),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           // ElevatedButton.icon(
//           //   onPressed: printReceipt,
//           //   icon: Icon(Icons.receipt),
//           //   label: Text('Print Sample Receipt'),
//           //   style: ElevatedButton.styleFrom(
//           //     padding: EdgeInsets.symmetric(vertical: 16),
//           //     textStyle: TextStyle(fontSize: 16),
//           //   ),
//           // ),
//           // SizedBox(height: 12),
//           // ElevatedButton.icon(
//           //   onPressed: printBarcode,
//           //   icon: Icon(Icons.qr_code),
//           //   label: Text('Print Barcode'),
//           //   style: ElevatedButton.styleFrom(
//           //     padding: EdgeInsets.symmetric(vertical: 16),
//           //     textStyle: TextStyle(fontSize: 16),
//           //   ),
//           // ),
//           // SizedBox(height: 12),
//           // OutlinedButton.icon(
//           //   onPressed: () async {
//           //     try {
//           //       await iminPrinter.openCashBox();
//           //       ScaffoldMessenger.of(context).showSnackBar(
//           //         SnackBar(content: Text('Cash drawer opened!')),
//           //       );
//           //     } catch (e) {
//           //       ScaffoldMessenger.of(context).showSnackBar(
//           //         SnackBar(content: Text('Cash drawer not available')),
//           //       );
//           //     }
//           //   },
//           // icon: Icon(Icons.money),
//           // label: Text('Open Cash Drawer'),
//           // style: OutlinedButton.styleFrom(
//           //   padding: EdgeInsets.symmetric(vertical: 16),
//           //   textStyle: TextStyle(fontSize: 16),
//           // ),
//           // ),
//           SizedBox(height: 20),
//           // Expanded(
//           //   child: Card(
//           //     child: Padding(
//           //       padding: EdgeInsets.all(16.0),
//           //       child: Column(
//           //         crossAxisAlignment: CrossAxisAlignment.start,
//           //         children: [
//           //           Text(
//           //             'Device Features:',
//           //             style:
//           //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           //           ),
//           //           SizedBox(height: 8),
//           //           Text('• 58mm Thermal Printer'),
//           //           Text('• QR Code & Barcode Support'),
//           //           Text('• Cash Drawer Control'),
//           //           Text('• Android 8.1 + iMin OS'),
//           //           Text('• 5.5" Touchscreen Display'),
//           //           Text('• 4G LTE, WiFi, Bluetooth'),
//           //         ],
//           //       ),
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }
