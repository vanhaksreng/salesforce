import 'package:flutter/material.dart';
import 'package:salesforce/features/more/presentation/pages/imin_device/imin_printer_service.dart';

class ReceiptColumnConfig {
  // Standard layout: [1, 3, 2, 2, 2, 2] = 12 total
  static const List<int> standardColumns = [1, 3, 2, 2, 2, 2];

  // For header/items: [1, 4, 2, 2, 3] = 12 total
  static const List<int> itemColumns = [1, 4, 2, 2, 3];

  // Simple 3-column: [4, 4, 4] = 12 total
  static const List<int> threeColumns = [4, 4, 4];

  // Simple 2-column: [6, 6] = 12 total
  static const List<int> twoColumns = [6, 6];
}

class PrinterExample {
  static Future<void> printReceiptHeader() async {
    // Column widths: [1, 3, 2, 2, 2, 2] = 12 total
    final columnWidths = [1, 3, 2, 2, 2, 2];

    // Khmer Header
    await IminPrinterService.printRow([
      {'text': 'ល.រ', 'width': columnWidths[0], 'align': 'left'},
      {'text': 'ឈ្មោះទំនិញ', 'width': columnWidths[1], 'align': 'center'},
      {'text': 'ចំនួន', 'width': columnWidths[2], 'align': 'center'},
      {'text': 'តម្លៃ', 'width': columnWidths[3], 'align': 'right'},
      {'text': 'បញ្ចុះ', 'width': columnWidths[4], 'align': 'right'},
      {'text': 'សរុប', 'width': columnWidths[5], 'align': 'right'},
    ], fontSize: 16);

    // English Header
    await IminPrinterService.printRow([
      {'text': 'No', 'width': columnWidths[0], 'align': 'left'},
      {'text': 'Item', 'width': columnWidths[1], 'align': 'center'},
      {'text': 'Qty', 'width': columnWidths[2], 'align': 'center'},
      {'text': 'Price', 'width': columnWidths[3], 'align': 'right'},
      {'text': 'Disc', 'width': columnWidths[4], 'align': 'right'},
      {'text': 'Total', 'width': columnWidths[5], 'align': 'right'},
    ], fontSize: 14);
    await IminPrinterService.feedPaper(lines: 2);
    await IminPrinterService.cutPaper();
  }

  static Future<void> printReceiptItems() async {
    final columnWidths = [1, 3, 2, 2, 2, 2];

    // Sample items
    final items = [
      {
        'no': '1',
        'name': 'កាហ្វេ Coffee',
        'qty': '2',
        'price': '\$2.50',
        'disc': '10%',
        'total': '\$4.50',
      },
      {
        'no': '2',
        'name': 'ទឹកក្រូច Orange Juice',
        'qty': '1',
        'price': '\$1.50',
        'disc': '0%',
        'total': '\$1.50',
      },
    ];

    for (var item in items) {
      await IminPrinterService.printRow([
        {'text': item['no']!, 'width': columnWidths[0], 'align': 'left'},
        {'text': item['name']!, 'width': columnWidths[1], 'align': 'left'},
        {'text': item['qty']!, 'width': columnWidths[2], 'align': 'center'},
        {'text': item['price']!, 'width': columnWidths[3], 'align': 'right'},
        {'text': item['disc']!, 'width': columnWidths[4], 'align': 'right'},
        {'text': item['total']!, 'width': columnWidths[5], 'align': 'right'},
      ], fontSize: 14);
    }
  }

  static Future<void> printTotals() async {
    // Use 2-column layout for totals
    final columnWidths = [6, 6]; // Total = 12

    await IminPrinterService.printRow([
      {'text': 'Subtotal:', 'width': columnWidths[0], 'align': 'left'},
      {'text': '\$6.00', 'width': columnWidths[1], 'align': 'right'},
    ], fontSize: 18);

    await IminPrinterService.printRow([
      {'text': 'Tax (10%):', 'width': columnWidths[0], 'align': 'left'},
      {'text': '\$0.60', 'width': columnWidths[1], 'align': 'right'},
    ], fontSize: 18);

    await IminPrinterService.printRow([
      {'text': 'សរុបរួម Total:', 'width': columnWidths[0], 'align': 'left'},
      {'text': '\$6.60', 'width': columnWidths[1], 'align': 'right'},
    ], fontSize: 20); // Larger for emphasis
  }

  static Future<void> printFullReceipt() async {
    await IminPrinterService.initialize();

    // Store info (centered, full width)
    await IminPrinterService.printRow([
      {'text': 'ហាងកាហ្វេ MY CAFE', 'width': 12, 'align': 'center'},
    ], fontSize: 22);

    await IminPrinterService.printRow([
      {'text': 'St. 123, Phnom Penh', 'width': 12, 'align': 'center'},
    ], fontSize: 16);

    await IminPrinterService.printSeparator(width: 32);

    // Headers
    await printReceiptHeader();
    await IminPrinterService.printSeparator(width: 32);

    // Items
    await printReceiptItems();
    await IminPrinterService.printSeparator(width: 32);

    // Totals
    await printTotals();

    // Thank you message
    await IminPrinterService.printRow([
      {'text': 'អរគុណ! Thank You!', 'width': 12, 'align': 'center'},
    ], fontSize: 18);

    await IminPrinterService.feedPaper(lines: 2);
    await IminPrinterService.cutPaper();
  }
}

// Test different column configurations
class ColumnWidthTests {
  static Future<void> testEqualColumns() async {
    // 4 equal columns
    final widths = [3, 3, 3, 3]; // Total = 12

    await IminPrinterService.printRow([
      {'text': 'Col1', 'width': widths[0], 'align': 'center'},
      {'text': 'Col2', 'width': widths[1], 'align': 'center'},
      {'text': 'Col3', 'width': widths[2], 'align': 'center'},
      {'text': 'Col4', 'width': widths[3], 'align': 'center'},
    ], fontSize: 16);
  }

  static Future<void> testCustomColumns() async {
    // Custom widths for specific layout
    final widths = [2, 5, 3, 2]; // Total = 12

    await IminPrinterService.printRow([
      {'text': 'No', 'width': widths[0], 'align': 'left'},
      {'text': 'Description', 'width': widths[1], 'align': 'left'},
      {'text': 'Amount', 'width': widths[2], 'align': 'right'},
      {'text': '%', 'width': widths[3], 'align': 'right'},
    ], fontSize: 16);
  }

  static Future<void> testFontSizes() async {
    final widths = [6, 6];

    // Test fontSize 14
    await IminPrinterService.printRow([
      {'text': 'តូច Small', 'width': widths[0], 'align': 'left'},
      {'text': 'Size 14', 'width': widths[1], 'align': 'right'},
    ], fontSize: 14);

    // Test fontSize 16
    await IminPrinterService.printRow([
      {'text': 'មធ្យម Medium', 'width': widths[0], 'align': 'left'},
      {'text': 'Size 16', 'width': widths[1], 'align': 'right'},
    ], fontSize: 16);

    // Test fontSize 18
    await IminPrinterService.printRow([
      {'text': 'ធម្មតា Normal', 'width': widths[0], 'align': 'left'},
      {'text': 'Size 18', 'width': widths[1], 'align': 'right'},
    ], fontSize: 18);

    // Test fontSize 20
    await IminPrinterService.printRow([
      {'text': 'ធំ Large', 'width': widths[0], 'align': 'left'},
      {'text': 'Size 20', 'width': widths[1], 'align': 'right'},
    ], fontSize: 20);
  }
}

class IminM203App extends StatefulWidget {
  @override
  _IminM203AppState createState() => _IminM203AppState();
}

class _IminM203AppState extends State<IminM203App> {
  @override
  void initState() {
    super.initState();
  }

  // Future<void> initPrinter() async {
  //   String? initResult = await IminPrinterService.initializeSDK();
  //   if (initResult != null) {
  //     print("SDK initialized: $initResult");

  //     // Print some text
  //     String? printResult = await IminPrinterService.printText("Hello World!");
  //     if (printResult != null) {
  //       print("Print result: $printResult");
  //     }
  //   }
  // }

  void printRestaurantReceipt() async {
    try {
      await IminPrinterService.initialize();

      // Header
      await IminPrinterService.printText(
        'ភោជនីយដ្ឋាន ABC',
        fontSize: 32,
        bold: true,
        align: 'center',
      );

      // await IminPrinterService.printText(
      //   'ABC Restaurant',
      //   fontSize: 24,
      //   align: 'center',
      // );

      // await IminPrinterService.printSeparator(width: 32);

      // // Info
      // await IminPrinterService.printText('Date: 2025-12-16');
      // await IminPrinterService.printText('Table: 5');
      // await IminPrinterService.printText('Order: #12345');

      await IminPrinterService.printSeparator(width: 32);
      await IminPrinterService.printRow([
        {'text': 'ល.រ', 'width': 1, 'align': 'left'},
        {'text': 'ឈ្មោះទំនិញ', 'width': 4, 'align': 'center'},
        {'text': 'តម្លៃ', 'width': 2, 'align': 'right'},
        {'text': 'Disc', 'width': 2, 'align': 'right'},
        {'text': 'សរុប', 'width': 2, 'align': 'right'},
      ]);
      // Items header
      await IminPrinterService.printRow([
        {'text': 'No', 'width': 1, 'align': 'left'},
        {'text': 'Qty', 'width': 4, 'align': 'center'},
        {'text': 'Price', 'width': 2, 'align': 'right'},
        {'text': 'Disc', 'width': 2, 'align': 'right'},
        {'text': 'Total', 'width': 2, 'align': 'right'},
      ]);

      await IminPrinterService.printSeparator(width: 32);

      // Items
      // await IminPrinterService.printRow([
      //   {'text': 'បបរគោ (Pho)', 'width': 3, 'align': 'left'},
      //   {'text': '2', 'width': 1, 'align': 'center'},
      //   {'text': '\$10.00', 'width': 2, 'align': 'right'},
      // ]);

      // await IminPrinterService.printRow([
      //   {'text': 'អាម៉ុក (Amok)', 'width': 3, 'align': 'left'},
      //   {'text': '1', 'width': 1, 'align': 'center'},
      //   {'text': '\$8.00', 'width': 2, 'align': 'right'},
      // ]);

      // await IminPrinterService.printRow([
      //   {'text': 'កាហ្វេ (Coffee)', 'width': 3, 'align': 'left'},
      //   {'text': '2', 'width': 1, 'align': 'center'},
      //   {'text': '\$4.00', 'width': 2, 'align': 'right'},
      // ]);

      // await IminPrinterService.printSeparator(width: 32);

      // // Totals
      // await IminPrinterService.printText('Subtotal: \$22.00', align: 'right');

      // await IminPrinterService.printText('Tax (10%): \$2.20', align: 'right');

      await IminPrinterService.printText(
        'TOTAL: \$24.20',
        fontSize: 28,
        bold: true,
        align: 'right',
      );

      await IminPrinterService.printSeparator(width: 48);

      // Footer
      await IminPrinterService.printText(
        'អរគុណ! Thank you!',
        fontSize: 26,
        align: 'center',
      );

      await IminPrinterService.feedPaper(lines: 3);
      await IminPrinterService.cutPaper();
    } catch (e) {
      // print('Error: $e');
    }
  }

  // Future<void> printReceipt() async {
  //   try {
  //     // Set printer style
  //     await iminPrinter.setAlignment(IminPrintAlign.center);
  //     await iminPrinter.setTextSize(30);

  //     // Print store header
  //     await iminPrinter.printText("FLUTTER STORE");
  //     await iminPrinter.printAndLineFeed();

  //     // Print separator line
  //     await iminPrinter.setAlignment(IminPrintAlign.left);
  //     await iminPrinter.printText("--------------------------------");
  //     await iminPrinter.printAndLineFeed();

  //     // Print items
  //     await iminPrinter.printText("Item 1.............\$10.00");
  //     await iminPrinter.printAndLineFeed();
  //     await iminPrinter.printText("Item 2.............\$15.50");
  //     await iminPrinter.printAndLineFeed();

  //     // Print total
  //     await iminPrinter.printText("--------------------------------");
  //     await iminPrinter.printAndLineFeed();
  //     // await iminPrinter.setTextStyle();
  //     await iminPrinter.printText("TOTAL:.............\$25.50");
  //     await iminPrinter.printAndLineFeed();

  //     // Print QR code
  //     await iminPrinter.setAlignment(IminPrintAlign.center);
  //     await iminPrinter.printQrCode("https://example.com/receipt/123");
  //     await iminPrinter.printAndLineFeed();

  //     // Feed paper and cut (if cutter available)
  //     await iminPrinter.partialCut();

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Receipt printed successfully!')));
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Print failed: $e')));
  //   }
  // }

  // Future<void> printBarcode() async {
  //   try {
  //     await iminPrinter.setAlignment(IminPrintAlign.center);
  //     await iminPrinter.printBarCode(
  //       IminBarcodeType.upcA,
  //       "123456789012",
  //       // IminBarcodeTextPos.textBelow,
  //       // 100,
  //       // 2,
  //     );
  //     await iminPrinter.printAndLineFeed();
  //     await iminPrinter.partialCut();

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Barcode printed successfully!')));
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Barcode print failed: $e')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imin M2-203 Flutter App'),
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.print, size: 48, color: Colors.blue[800]),
                  SizedBox(height: 8),
                  Text(
                    'Imin M2-203 Printer Functions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Control the built-in thermal printer'),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: PrinterExample.printReceiptHeader,
            icon: Icon(Icons.receipt),
            label: Text('Print Sample Receipt'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 12),
          // ElevatedButton.icon(
          //   onPressed: printBarcode,
          //   icon: Icon(Icons.qr_code),
          //   label: Text('Print Barcode'),
          //   style: ElevatedButton.styleFrom(
          //     padding: EdgeInsets.symmetric(vertical: 16),
          //     textStyle: TextStyle(fontSize: 16),
          //   ),
          // ),
          SizedBox(height: 12),
          // OutlinedButton.icon(
          //   onPressed: () async {
          //     try {
          //       await iminPrinter.openCashBox();
          //       ScaffoldMessenger.of(
          //         context,
          //       ).showSnackBar(SnackBar(content: Text('Cash drawer opened!')));
          //     } catch (e) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(content: Text('Cash drawer not available')),
          //       );
          //     }
          //   },
          //   icon: Icon(Icons.money),
          //   label: Text('Open Cash Drawer'),
          //   style: OutlinedButton.styleFrom(
          //     padding: EdgeInsets.symmetric(vertical: 16),
          //     textStyle: TextStyle(fontSize: 16),
          //   ),
          // ),
          SizedBox(height: 20),
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Features:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• 58mm Thermal Printer'),
                    Text('• QR Code & Barcode Support'),
                    Text('• Cash Drawer Control'),
                    Text('• Android 8.1 + iMin OS'),
                    Text('• 5.5" Touchscreen Display'),
                    Text('• 4G LTE, WiFi, Bluetooth'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
