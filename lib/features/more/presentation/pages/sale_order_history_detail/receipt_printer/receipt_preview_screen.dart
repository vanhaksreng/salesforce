import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_builder.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_preview.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  const ReceiptPreviewScreen({super.key, this.detail, this.companyInfo});
  final SaleDetail? detail;
  final CompanyInformation? companyInfo;

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen>
    with SingleTickerProviderStateMixin {
  final ReceiptBuilder _builder = ReceiptBuilder();
  List<PrinterDevice> printers = [];
  PrinterDevice? selectedPrinter;
  bool isConnected = false;
  bool isSearching = false;
  bool isPrinting = false;
  bool isReceiptBuilt = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initializeReceipt();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    if (isConnected) {
      ThermalPrinter.disconnect();
    }
    super.dispose();
  }

  Future<void> _initializeReceipt() async {
    await _buildSampleReceipt();
    await searchPrinters();
  }

  Future<void> searchPrinters() async {
    setState(() {
      isSearching = true;
      printers.clear();
    });

    try {
      final foundPrinters = await ThermalPrinter.discoverPrinters(
        type: ConnectionType.bluetooth,
      );
      print("===========all${foundPrinters.map((e) => e.name)}");

      setState(() {
        printers = foundPrinters;
        isSearching = false;
      });

      if (printers.isEmpty) {
        _showSnackBar('No printers found', Colors.orange, Icons.search_off);
      } else {
        _showSnackBar(
          'Found ${printers.length} printer(s)',
          Colors.green,
          Icons.devices,
        );
        await connectToPrinter();
      }
    } catch (e) {
      setState(() => isSearching = false);
      _showSnackBar('Search failed: ${e.toString()}', Colors.red, Icons.error);
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> connectToPrinter() async {
    if (printers.isEmpty) {
      _showSnackBar('No printers available', Colors.red, Icons.error);
      return;
    }

    try {
      final printer = printers.firstWhere(
        (e) => e.name.contains("XP-P323B-E1FE"),
        orElse: () => printers.first,
      );

      _showSnackBar(
        'Connecting to ${printer.name}...',
        Colors.blue,
        Icons.bluetooth_searching,
      );

      final connected = await ThermalPrinter.connect(printer);

      setState(() {
        isConnected = connected;
        if (connected) selectedPrinter = printer;
      });

      if (connected) {
        _showSnackBar(
          'Connected to ${printer.name}',
          Colors.green,
          Icons.check_circle,
        );
      } else {
        _showSnackBar('Connection failed', Colors.red, Icons.error);
      }
    } catch (e) {
      print('Connection error: $e');
      _showSnackBar('Connection error: $e', Colors.red, Icons.error);
    }
  }

  Future<void> _buildSampleReceipt() async {
    const int valueLine = 43;
    _builder.clear();

    await _buildLogo();

    _builder.addText(
      widget.companyInfo?.name ?? "Company Name",
      fontSize: 24,
      bold: true,
      align: AlignStyle.center,
    );
    _builder.addText(
      widget.companyInfo?.address ?? "Company Address",
      fontSize: 20,
      align: AlignStyle.center,
    );
    _builder.addText(
      "Email: ${widget.companyInfo?.email ?? 'info@company.com'}",
      fontSize: 20,
      align: AlignStyle.center,
    );
    _builder.addText("-" * valueLine, fontSize: 20, align: AlignStyle.center);
    _builder.feedPaper(1);

    PosSalesHeader? header = widget.detail?.header;
    _builder.addText(
      "Customer: ${header?.customerName ?? 'Walk-in Customer'}",
      fontSize: 20,
      align: AlignStyle.left,
    );
    _builder.addText(
      "Date: ${header?.orderDate ?? DateTime.now().toString().split(' ')[0]}",
      fontSize: 20,
      align: AlignStyle.left,
    );
    _builder.addText(
      "Invoice No: ${header?.no ?? 'N/A'}",
      fontSize: 20,
      align: AlignStyle.left,
    );

    _builder.addText("-" * valueLine, fontSize: 20, align: AlignStyle.center);
    _builder.addText(
      _buildHeaderLine(),
      fontSize: 20,
      bold: true,
      maxCharPerLine: 50,
      align: AlignStyle.left,
    );
    _builder.addText("-" * valueLine, fontSize: 20, align: AlignStyle.center);

    List<PosSalesLine> lines = widget.detail?.lines ?? [];
    double total = 0.0;

    for (var i = 0; i < lines.length; i++) {
      final item = lines[i];
      final amount = double.tryParse(item.amount?.toString() ?? '0') ?? 0.0;
      total += amount;

      _builder.addText(
        _buildItemLine(
          index: i + 1,
          description: item.description ?? "Item",
          qty: Helpers.toStrings(item.quantity),
          price: Helpers.toStrings(item.unitPrice),
          discount: Helpers.toStrings(item.discountAmount ?? "0"),
          amount: Helpers.toStrings(item.amount),
        ),
        fontSize: 20,
        maxCharPerLine: 250,
        align: AlignStyle.left,
      );
    }

    _builder.addText("-" * valueLine, fontSize: 20, align: AlignStyle.center);
    _builder.addText(
      'TOTAL:            \$${total.toStringAsFixed(2)}',
      fontSize: 24,
      bold: true,
      align: AlignStyle.right,
    );
    _builder.feedPaper(2);

    _builder.addText(
      'Thank you for your business!',
      fontSize: 24,
      bold: true,
      align: AlignStyle.center,
    );
    _builder.feedPaper(3);
    _builder.cutPaper();

    setState(() => isReceiptBuilt = true);
  }

  final columnWidths = [2, 12, 7, 7, 7, 8];

  String _buildItemLine({
    required int index,
    required String description,
    required String qty,
    required String price,
    required String discount,
    required String amount,
  }) {
    return [
      _padCol(index.toString(), columnWidths[0]),
      _padCol(description, columnWidths[1]),
      _padCol(
        Helpers.formatNumber(qty, option: FormatType.amount),
        columnWidths[2],
        right: true,
      ),
      _padCol(
        Helpers.formatNumber(price, option: FormatType.amount),
        columnWidths[3],
        right: true,
      ),
      _padCol(
        Helpers.formatNumber(discount, option: FormatType.amount),
        columnWidths[4],
        right: true,
      ),
      _padCol(
        Helpers.formatNumber(amount, option: FormatType.amount),
        columnWidths[5],
        right: true,
      ),
    ].join();
  }

  String _padCol(String text, int width, {bool right = false}) {
    if (text.length >= width) return text.substring(0, width);
    final padding = width - text.length;
    return right ? " " * padding + text : text + " " * padding;
  }

  String _buildHeaderLine() {
    return [
      _col("#", 2),
      _col("Description", 12),
      _col("Qty", 7, right: true),
      _col("Price", 7, right: true),
      _col("Disc", 7, right: true),
      _col("Amount", 8, right: true),
    ].join();
  }

  String _col(String text, int width, {bool right = false}) {
    if (text.length >= width) return text.substring(0, width);
    final padding = width - text.length;
    return right ? " " * padding + text : text + " " * padding;
  }

  Future<void> _buildLogo() async {
    if (widget.companyInfo?.logo128 == null ||
        widget.companyInfo!.logo128!.isEmpty)
      return;

    try {
      Uint8List bytes;

      if ((widget.companyInfo?.logo128 ?? "").startsWith('http')) {
        final response = await http.get(
          Uri.parse(widget.companyInfo?.logo128 ?? ""),
        );
        if (response.statusCode == 200) {
          bytes = response.bodyBytes;
        } else {
          throw Exception("HTTP ${response.statusCode}");
        }
      } else {
        bytes = base64Decode(widget.companyInfo?.logo128 ?? "");
      }

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final logoImage = frame.image;

      final byteData = await logoImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        _builder.addImage(byteData.buffer.asUint8List(), width: 250);
      }
    } catch (e) {
      debugPrint("Failed to load logo: $e");
    }
  }

  Future<void> _printReceiptOld() async {
    // if (!isConnected) {
    //   _showSnackBar(
    //     'Printer not connected. Searching...',
    //     Colors.orange,
    //     Icons.warning,
    //   );
    //   await searchPrinters();
    //   if (!isConnected) {
    //     _showSnackBar('Failed to connect', Colors.red, Icons.error);
    //     return;
    //   }
    // }
    await ThermalPrinter.printText(
      "hello Android. ស្វាគមន៍​មកកាន់ ភាសាខ្មែរ(KhmerLang)!៖ ពិនិត្យអក្ខរាវិរុទ្ធ ចម្ងាយពាក្យខ្មែរ អក្សរខ្មែរ ទៅ រ៉ូម៉ាំង អក្សរខ្មែរ ទៅ សូរ ពាក្យពពក។",
      bold: true,
      maxCharPerLine: 32,
    );
    await ThermalPrinter.printText(
      "hello Android Sueputhearatat",
      bold: true,
      maxCharPerLine: 32,
    );
    await ThermalPrinter.feedPaper(2);

    await ThermalPrinter.cutPaper();
  }

  Future<void> _printReceipt() async {
    if (!isConnected) {
      _showSnackBar(
        'Printer not connected. Searching...',
        Colors.orange,
        Icons.warning,
      );
      await searchPrinters();
      if (!isConnected) {
        _showSnackBar('Failed to connect', Colors.red, Icons.error);
        return;
      }
    }

    setState(() => isPrinting = true);

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(strokeWidth: 4),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Printing Receipt...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      for (final ReceiptCommand cmd in _builder.commands) {
        switch (cmd.type) {
          case ReceiptCommandType.text:
            await ThermalPrinter.printText(
              cmd.params["text"],
              fontSize: cmd.params["fontSize"] ?? 24,
              bold: cmd.params["bold"] ?? false,
              maxCharPerLine: cmd.params["maxCharsPerLine"] ?? 32,
              align: cmd.params["align"],
            );
            break;
          case ReceiptCommandType.image:
            await ThermalPrinter.printImage(
              cmd.params["imageBytes"],
              width: cmd.params["width"] ?? 384,
            );
            break;
          case ReceiptCommandType.feedPaper:
            await ThermalPrinter.feedPaper(cmd.params["lines"]);
            break;
          case ReceiptCommandType.cutPaper:
            await ThermalPrinter.cutPaper();
            break;
        }
      }

      if (mounted) Navigator.pop(context);
      _showSnackBar(
        'Receipt printed successfully!',
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Print failed: $e', Colors.red, Icons.error);
    } finally {
      setState(() => isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Receipt Preview'),
        actions: [
          if (isSearching)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          if (!isSearching)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Transform.scale(
                      scale: isConnected ? _pulseAnimation.value : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isConnected
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isConnected
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth_disabled,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isConnected ? 'Connected' : 'Disconnected',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isSearching ? null : searchPrinters,
            tooltip: 'Reconnect Printer',
          ),
        ],
      ),
      body: isReceiptBuilt
          ? Column(
              children: [
                if (selectedPrinter != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isConnected
                            ? [Colors.green.shade50, Colors.green.shade100]
                            : [Colors.red.shade50, Colors.red.shade100],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isConnected
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.print,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        selectedPrinter!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(selectedPrinter!.address),
                      trailing: Icon(
                        isConnected ? Icons.check_circle : Icons.error,
                        color: isConnected ? Colors.green : Colors.red,
                        size: 32,
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ReceiptPreview(commands: _builder.commands),
                  ),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Building receipt...'),
                ],
              ),
            ),
      floatingActionButton: isReceiptBuilt
          ? FloatingActionButton.extended(
              onPressed: isPrinting ? null : _printReceipt,
              backgroundColor: isConnected ? null : Colors.grey,
              icon: isPrinting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.print),
              label: Text(isPrinting ? 'Printing...' : 'Print Receipt'),
            )
          : null,
    );
  }
}
