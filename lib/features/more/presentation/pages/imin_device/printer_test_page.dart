import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:salesforce/features/more/presentation/pages/imin_device/imin_printer_service.dart';

class PrinterTestScreen extends StatefulWidget {
  const PrinterTestScreen({super.key});
  static const String routeName = "PrinterTestScreen";

  @override
  _PrinterTestScreenState createState() => _PrinterTestScreenState();
}

class _PrinterTestScreenState extends State<PrinterTestScreen> {
  String _status = 'Not initialized';
  final TextEditingController _textController = TextEditingController();
  // final IminPrinter _printer = IminPrinter();
  @override
  void initState() {
    super.initState();
    _initializePrinter();
  }

  /// Initialize printer on app start
  Future<void> _initializePrinter() async {
    try {
      await PrinterService.initPrinter();
      setState(() {
        _status = 'Printer initialized successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to initialize: $e';
      });
    }
  }

  /// Check printer status
  Future<void> _checkStatus() async {
    try {
      final status = await PrinterService.getPrinterStatus();
      setState(() {
        _status = 'Status: $status';
      });
    } catch (e) {
      setState(() {
        _status = 'Status error: $e';
      });
    }
  }

  /// Print text
  Future<void> _printText() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter text to print')));
      return;
    }

    try {
      await PrinterService.printText(_textController.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Text printed successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Print failed: $e')));
    }
  }

  /// Print receipt example - FIXED: Handle empty string properly
  Future<void> _printReceipt() async {
    try {
      await PrinterService.printText('================================');
      await PrinterService.printText('         RECEIPT');
      await PrinterService.printText('================================');
      await PrinterService.printText('Item 1.................\$10.00');
      await PrinterService.printText('Item 2.................\$15.50');
      await PrinterService.printText('Tax....................\$2.55');
      await PrinterService.printText('--------------------------------');
      await PrinterService.printText('Total.................\$28.05');
      await PrinterService.printText('================================');
      await PrinterService.printText('Thank you for your purchase!');
      // FIXED: Use space instead of empty string
      await PrinterService.printText(' ');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Receipt printed successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Receipt print failed: $e')));
    }
  }

  /// Open cash box
  Future<void> _openCashBox() async {
    try {
      await PrinterService.openCashBox();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cash box opened')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open cash box: $e')));
    }
  }

  /// Get device serial number
  Future<void> _getSerialNumber() async {
    try {
      final sn = await PrinterService.getSerialNumber();
      setState(() {
        _status = 'Serial Number: $sn';
      });
    } catch (e) {
      setState(() {
        _status = 'SN error: $e';
      });
    }
  }

  /// Print test pattern (improved bitmap creation)
  Future<void> _printTestPattern() async {
    try {
      final patternBytes = _createTestPatternBytes();
      await PrinterService.printBitmap(patternBytes);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Test pattern printed')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pattern print failed: $e')));
    }
  }

  /// Create test pattern bitmap bytes - IMPROVED
  Uint8List _createTestPatternBytes() {
    // Create a smaller image for better printer compatibility
    final image = img.Image(width: 200, height: 100);

    // White background
    img.fill(image, color: img.ColorRgb8(255, 255, 255));

    // Create test pattern with better contrast
    // Horizontal lines
    for (int y = 10; y < 90; y += 20) {
      img.drawLine(
        image,
        x1: 10,
        y1: y,
        x2: 190,
        y2: y,
        color: img.ColorRgb8(0, 0, 0),
        thickness: 2,
      );
    }

    // Vertical lines
    for (int x = 20; x < 180; x += 30) {
      img.drawLine(
        image,
        x1: x,
        y1: 10,
        x2: x,
        y2: 90,
        color: img.ColorRgb8(0, 0, 0),
        thickness: 2,
      );
    }

    // Add some text
    // Note: This requires a font file, so let's keep it simple with shapes

    // Create checkerboard pattern in corner
    for (int y = 20; y < 50; y += 5) {
      for (int x = 20; x < 50; x += 5) {
        if ((x + y) % 10 == 0) {
          img.fillRect(
            image,
            x1: x,
            y1: y,
            x2: x + 4,
            y2: y + 4,
            color: img.ColorRgb8(0, 0, 0),
          );
        }
      }
    }

    // Convert to PNG bytes
    return Uint8List.fromList(img.encodePng(image));
  }

  /// Test all printer functions sequentially
  Future<void> _runFullTest() async {
    setState(() {
      _status = 'Running full test...';
    });

    try {
      // 1. Initialize
      await PrinterService.initPrinter();
      setState(() {
        _status = 'Test 1/6: Initialized ✓';
      });
      await Future.delayed(Duration(milliseconds: 500));

      // 2. Check status
      final status = await PrinterService.getPrinterStatus();
      setState(() {
        _status = 'Test 2/6: Status = $status ✓';
      });
      await Future.delayed(Duration(milliseconds: 500));

      // 3. Print text
      await PrinterService.printText('=== PRINTER TEST ===');
      setState(() {
        _status = 'Test 3/6: Text printed ✓';
      });
      await Future.delayed(Duration(milliseconds: 500));

      // 4. Get serial number
      final sn = await PrinterService.getSerialNumber();
      setState(() {
        _status = 'Test 4/6: SN = $sn ✓';
      });
      await Future.delayed(Duration(milliseconds: 500));

      // 5. Print test pattern
      await _printTestPattern();
      setState(() {
        _status = 'Test 5/6: Pattern printed ✓';
      });
      await Future.delayed(Duration(milliseconds: 500));

      // 6. Final text
      await PrinterService.printText('Test completed successfully!');
      await PrinterService.printText(' ');

      setState(() {
        _status = 'Test 6/6: All tests completed ✅';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Full test completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Test failed: $e ❌';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imin Printer Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status display
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Printer Status:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(_status, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Text input
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Text to print',
                hintText: 'Enter text here...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _textController.clear(),
                ),
              ),
              maxLines: 3,
            ),

            SizedBox(height: 20),

            // Quick test button
            ElevatedButton.icon(
              onPressed: _runFullTest,
              icon: Icon(Icons.play_arrow),
              label: Text('Run Full Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 16),

            // Individual test buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _initializePrinter,
                    child: Text('Initialize'),
                  ),
                  ElevatedButton(
                    onPressed: _checkStatus,
                    child: Text('Check Status'),
                  ),
                  ElevatedButton(
                    onPressed: _printText,
                    child: Text('Print Text'),
                  ),
                  ElevatedButton(
                    onPressed: _printReceipt,
                    child: Text('Print Receipt'),
                  ),
                  ElevatedButton(
                    onPressed: _getSerialNumber,
                    child: Text('Get Serial#'),
                  ),
                  ElevatedButton(
                    onPressed: _printTestPattern,
                    child: Text('Print Pattern'),
                  ),
                  ElevatedButton(
                    onPressed: _openCashBox,
                    child: Text('Open Cash Box'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
