import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:salesforce/features/more/presentation/pages/imin_device/imin_printer_service.dart';

class PrinterTestScreen extends StatefulWidget {
  const PrinterTestScreen({super.key});
  static const String routeName = "PrinterTestScreen";

  @override
  PrinterTestScreenState createState() => PrinterTestScreenState();
}

class PrinterTestScreenState extends State<PrinterTestScreen> {
  String _status = 'Not initialized';
  String _deviceInfo = '';
  bool _isLoading = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePrinter();
    _loadDeviceInfo();
  }

  /// Initialize printer on app start
  Future<void> _initializePrinter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await IminPrinterService.initialize();
      setState(() {
        _status = 'Printer initialized successfully ✓';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to initialize: $e';
        _isLoading = false;
      });
    }
  }

  /// Load device information
  Future<void> _loadDeviceInfo() async {
    try {
      final info = await IminPrinterService.getDeviceInfo();
      setState(() {
        _deviceInfo =
            '''
Device Model: ${info['deviceModel']}
Android: ${info['androidVersion']} (SDK ${info['sdkInt']})
Connection: ${info['connectionType']}
Initialized: ${info['printerInitialized']}
''';
      });
    } catch (e) {
      setState(() {
        _deviceInfo = 'Failed to load device info: $e';
      });
    }
  }

  /// Check printer status
  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await IminPrinterService.getStatus();
      final statusCode = result['status'] as int;
      final message = result['message'] as String;
      final attempts = result['attempts'] as int;

      setState(() {
        _status =
            '''
Status Code: $statusCode
Message: $message
Attempts: $attempts
Ready: ${statusCode == 0 ? 'YES ✓' : 'NO ✗'}
''';
        _isLoading = false;
      });

      _showSnackBar(message, statusCode == 0 ? Colors.green : Colors.orange);
    } catch (e) {
      setState(() {
        _status = 'Status error: $e';
        _isLoading = false;
      });
      _showSnackBar('Status check failed: $e', Colors.red);
    }
  }

  /// Print text
  Future<void> _printText() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('Please enter text to print', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await IminPrinterService.printText(_textController.text);
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Text printed successfully', Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Print failed: $e', Colors.red);
    }
  }

  /// Print receipt example
  Future<void> _printReceipt() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await IminPrinterService.printText('================================');
      await IminPrinterService.printText('         RECEIPT');
      await IminPrinterService.printText('================================');
      await IminPrinterService.printText(
        'Date: ${DateTime.now().toString().substring(0, 19)}',
      );
      await IminPrinterService.printText('Order #: 12345');
      await IminPrinterService.printText('--------------------------------');
      await IminPrinterService.printText('Item 1.................\$10.00');
      await IminPrinterService.printText('Item 2.................\$15.50');
      await IminPrinterService.printText('Item 3.................\$8.25');
      await IminPrinterService.printText('--------------------------------');
      await IminPrinterService.printText('Subtotal...............\$33.75');
      await IminPrinterService.printText('Tax....................\$2.70');
      await IminPrinterService.printText('================================');
      await IminPrinterService.printText('Total.................\$36.45');
      await IminPrinterService.printText('================================');
      await IminPrinterService.printText('Thank you for your purchase!');
      await IminPrinterService.printText(' ');
      await IminPrinterService.printText(' ');
      await IminPrinterService.printText(' ');

      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Receipt printed successfully', Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Receipt print failed: $e', Colors.red);
    }
  }

  /// Open cash box
  Future<void> _openCashBox() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await IminPrinterService.openCashBox();
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Cash box opened', Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Failed to open cash box: $e', Colors.red);
    }
  }

  /// Get device serial number
  Future<void> _getSerialNumber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sn = await IminPrinterService.getSerialNumber();
      setState(() {
        _status = 'Serial Number: $sn';
        _isLoading = false;
      });
      _showSnackBar('Serial Number: $sn', Colors.blue);
    } catch (e) {
      setState(() {
        _status = 'SN error: $e';
        _isLoading = false;
      });
      _showSnackBar('Failed to get SN: $e', Colors.red);
    }
  }

  /// Reset printer
  Future<void> _resetPrinter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await IminPrinterService.reset();
      setState(() {
        _status = 'Printer reset successfully';
        _isLoading = false;
      });
      _showSnackBar('Printer reset successfully', Colors.green);
    } catch (e) {
      setState(() {
        _status = 'Reset failed: $e';
        _isLoading = false;
      });
      _showSnackBar('Reset failed: $e', Colors.red);
    }
  }

  /// Test print (using built-in test)
  Future<void> _testPrint() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await IminPrinterService.testPrint();
      setState(() {
        _status = 'Test print completed';
        _isLoading = false;
      });
      _showSnackBar('Test print completed', Colors.green);
    } catch (e) {
      setState(() {
        _status = 'Test print failed: $e';
        _isLoading = false;
      });
      _showSnackBar('Test print failed: $e', Colors.red);
    }
  }

  /// Print test pattern
  Future<void> _printTestPattern() async {
    setState(() {
      _isLoading = true;
    });

    // try {
    //   final patternBytes = _createTestPatternBytes();
    //   await IminPrinterService.(patternBytes);

    //   setState(() {
    //     _isLoading = false;
    //   });
    //   _showSnackBar('Test pattern printed', Colors.green);
    // } catch (e) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   _showSnackBar('Pattern print failed: $e', Colors.red);
    // }
  }

  /// Create test pattern bitmap bytes
  Uint8List _createTestPatternBytes() {
    final image = img.Image(width: 384, height: 200); // Standard receipt width

    // White background
    img.fill(image, color: img.ColorRgb8(255, 255, 255));

    // Black border
    img.drawRect(
      image,
      x1: 5,
      y1: 5,
      x2: 379,
      y2: 195,
      color: img.ColorRgb8(0, 0, 0),
      thickness: 3,
    );

    // Horizontal lines
    for (int y = 30; y < 180; y += 20) {
      img.drawLine(
        image,
        x1: 20,
        y1: y,
        x2: 364,
        y2: y,
        color: img.ColorRgb8(0, 0, 0),
        thickness: 2,
      );
    }

    // Vertical lines
    for (int x = 40; x < 360; x += 40) {
      img.drawLine(
        image,
        x1: x,
        y1: 20,
        x2: x,
        y2: 180,
        color: img.ColorRgb8(0, 0, 0),
        thickness: 2,
      );
    }

    // Checkerboard pattern
    for (int y = 50; y < 150; y += 10) {
      for (int x = 100; x < 280; x += 10) {
        if ((x + y) % 20 == 0) {
          img.fillRect(
            image,
            x1: x,
            y1: y,
            x2: x + 8,
            y2: y + 8,
            color: img.ColorRgb8(0, 0, 0),
          );
        }
      }
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  /// Run full test sequence
  Future<void> _runFullTest() async {
    setState(() {
      _status = 'Running full test...';
      _isLoading = true;
    });

    try {
      // 1. Initialize
      await IminPrinterService.initialize();
      setState(() => _status = 'Test 1/8: Initialized ✓');
      await Future.delayed(Duration(milliseconds: 800));

      // 2. Get device info
      await _loadDeviceInfo();
      setState(() => _status = 'Test 2/8: Device info loaded ✓');
      await Future.delayed(Duration(milliseconds: 800));

      // 3. Check status
      final status = await IminPrinterService.getStatus();
      setState(() => _status = 'Test 3/8: Status = ${status["message"]} ✓');
      await Future.delayed(Duration(milliseconds: 800));

      // 4. Print text
      await IminPrinterService.printText('=== FULL PRINTER TEST ===');
      setState(() => _status = 'Test 4/8: Text printed ✓');
      await Future.delayed(Duration(milliseconds: 800));

      // 5. Get serial number
      final sn = await IminPrinterService.getSerialNumber();
      await IminPrinterService.printText('Serial: $sn');
      setState(() => _status = 'Test 5/8: SN printed ✓');
      await Future.delayed(Duration(milliseconds: 800));

      // 6. Print test receipt
      await IminPrinterService.testPrint();
      setState(() => _status = 'Test 6/8: Test receipt printed ✓');
      await Future.delayed(Duration(milliseconds: 800));

      // 7. Print pattern
      final patternBytes = _createTestPatternBytes();
      // await IminPrinterService.printBitmap(patternBytes);
      setState(() => _status = 'Test 7/8: Pattern printed ✓');
      await Future.delayed(Duration(milliseconds: 800));

      // 8. Final message
      await IminPrinterService.printText('================================');
      await IminPrinterService.printText('All tests completed successfully!');
      await IminPrinterService.printText('================================');
      await IminPrinterService.printText(' ');
      await IminPrinterService.printText(' ');

      setState(() {
        _status = 'Test 8/8: All tests completed ✅';
        _isLoading = false;
      });

      _showSnackBar('Full test completed successfully!', Colors.green);
    } catch (e) {
      setState(() {
        _status = 'Test failed: $e ❌';
        _isLoading = false;
      });
      _showSnackBar('Test failed: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iMin Printer Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _initializePrinter();
              _loadDeviceInfo();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Device Info Card
                  if (_deviceInfo.isNotEmpty)
                    Card(
                      elevation: 4,
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Device Information',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              _deviceInfo,
                              style: TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 12),

                  // Status Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.print, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Printer Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(_status, style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

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
                    maxLines: 2,
                  ),

                  SizedBox(height: 16),

                  // Quick test button
                  ElevatedButton.icon(
                    onPressed: _runFullTest,
                    icon: Icon(Icons.play_arrow),
                    label: Text('RUN FULL TEST'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Individual test buttons
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        _buildTestButton(
                          'Initialize',
                          Icons.power_settings_new,
                          _initializePrinter,
                          Colors.blue,
                        ),
                        _buildTestButton(
                          'Check Status',
                          Icons.info,
                          _checkStatus,
                          Colors.orange,
                        ),
                        _buildTestButton(
                          'Print Text',
                          Icons.text_fields,
                          _printText,
                          Colors.purple,
                        ),
                        _buildTestButton(
                          'Print Receipt',
                          Icons.receipt,
                          _printReceipt,
                          Colors.teal,
                        ),
                        _buildTestButton(
                          'Get Serial#',
                          Icons.numbers,
                          _getSerialNumber,
                          Colors.indigo,
                        ),
                        _buildTestButton(
                          'Test Print',
                          Icons.print,
                          _testPrint,
                          Colors.green,
                        ),
                        _buildTestButton(
                          'Print Pattern',
                          Icons.grid_on,
                          _printTestPattern,
                          Colors.deepPurple,
                        ),
                        _buildTestButton(
                          'Open Cash Box',
                          Icons.attach_money,
                          _openCashBox,
                          Colors.amber,
                        ),
                        _buildTestButton(
                          'Reset Printer',
                          Icons.refresh,
                          _resetPrinter,
                          Colors.red,
                        ),
                        _buildTestButton(
                          'Device Info',
                          Icons.devices,
                          _loadDeviceInfo,
                          Colors.cyan,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTestButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
