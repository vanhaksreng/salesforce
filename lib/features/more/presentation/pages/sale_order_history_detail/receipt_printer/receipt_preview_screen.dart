// ====================================================================
// FILE 3: receipt_preview_screen.dart
// UPDATED WITH 58MM PAPER WIDTH SUPPORT
// ====================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/administration/bletooth_printer_service.dart';
import 'package:salesforce/features/more/presentation/pages/administration/device_printer_mixin.dart';
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
    with SingleTickerProviderStateMixin, DevicePrinterMixin {
  final ReceiptBuilder _builder = ReceiptBuilder();
  final _bluetoothService = BluetoothPrinterService();

  bool isPrinting = false;
  bool isReceiptBuilt = false;
  String? buildError;
  bool _isPrinterWarmedUp = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late List<int> columnWidths;
  late int totalWidth;

  // ====================================================================
  // ✅ PAPER WIDTH CONFIGURATION - CHANGE THIS FOR YOUR PRINTER
  // ====================================================================
  // Option 1: Set to 58mm (384 pixels)
  // int printerWidth = 384; // 58mm printer

  // Option 2: Set to 80mm (576 pixels)
  int printerWidth = 576; // 80mm printer
  int textLength = 32; // 80mm printer
  // ====================================================================

  int lengText() {
    if (printerWidth == 384) {
      return 32;
    }
    return 48;
  }

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

    _configurePrinterSize();
    _initializeReceipt();
    _warmUpPrinterIfNeeded();
  }

  Future<void> _warmUpPrinterIfNeeded() async {
    // Wait a bit for connection to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    if (isConnected() && !_isPrinterWarmedUp) {
      try {
        debugPrint('🔥 Warming up printer...');

        // ✅ SET PRINTER WIDTH FIRST (CRITICAL!)
        await ThermalPrinter.setPrinterWidth(printerWidth);
        debugPrint(
          '📏 Printer width set to $printerWidth (${printerWidth == 384 ? "58mm" : "80mm"})',
        );

        await ThermalPrinter.warmUpPrinter();
        await Future.delayed(const Duration(milliseconds: 100));

        await ThermalPrinter.configureOOMAS();
        await Future.delayed(const Duration(milliseconds: 100));

        _isPrinterWarmedUp = true;
        debugPrint(
          '✅ Printer warmed up and configured for ${printerWidth == 384 ? "58mm" : "80mm"} paper',
        );
      } catch (e) {
        debugPrint('⚠️ Warmup failed: $e');
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool isConnected() => _bluetoothService.isConnected;

  Future<void> _initializeReceipt() async {
    try {
      await _buildSampleReceipt();

      if (!_bluetoothService.isConnected) {
        if (mounted) {
          Helpers.showMessage(
            status: MessageStatus.warning,
            msg: "No printer connected. You can preview but cannot print.",
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Initialize error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          buildError = e.toString();
          isReceiptBuilt = false;
        });

        Helpers.showMessage(
          status: MessageStatus.errors,
          msg: "Failed to build receipt: $e",
        );
      }
    }
  }

  // ====================================================================
  // ✅ UPDATED: Configure printer size based on paper width
  // ====================================================================
  void _configurePrinterSize() {
    if (printerWidth == 384) {
      // 58mm printer configuration
      debugPrint('📏 Configuring for 58mm paper (384 pixels)');
      columnWidths = [1, 3, 2, 2, 2, 2];
      totalWidth = 32; // ~32 chars per line at fontSize 20
    } else {
      // 80mm printer configuration
      debugPrint('📏 Configuring for 80mm paper (576 pixels)');
      columnWidths = [1, 4, 1, 2, 2, 2]; // Standard layout - totals to 12
      totalWidth = 48; // ~48 chars per line at fontSize 20
    }
  }

  Future<Uint8List?> logoCompany() async {
    final companyInfo = widget.companyInfo;
    // Null safety checks
    if (companyInfo == null ||
        companyInfo.logo128 == null ||
        companyInfo.logo128!.isEmpty) {
      debugPrint('⚠️ No logo available');
      return null;
    }

    try {
      ui.Image? logoImage;

      // Check if logo is a URL or base64 string
      if (companyInfo.logo128!.startsWith('http')) {
        debugPrint('📥 Loading logo from URL: ${companyInfo.logo128}');

        // Load from URL
        final response = await http
            .get(
              Uri.parse(companyInfo.logo128!),
              headers: {'Accept': 'image/*'},
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Logo download timeout');
              },
            );

        if (response.statusCode == 200) {
          final codec = await ui.instantiateImageCodec(response.bodyBytes);
          final frame = await codec.getNextFrame();
          logoImage = frame.image;
          debugPrint(' Logo loaded from URL');
        } else {
          throw Exception('Failed to download logo: ${response.statusCode}');
        }
      } else {
        debugPrint('📥 Loading logo from base64 string');

        // Load from base64
        String base64String = companyInfo.logo128!;

        // Remove data URI prefix if present (e.g., "data:image/png;base64,")
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        final bytes = base64Decode(base64String);
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        logoImage = frame.image;
        debugPrint('✅ Logo loaded from base64');
      }

      // Convert ui.Image to Uint8List (PNG format)
      if (logoImage != null) {
        final byteData = await logoImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null) {
          final imageBytes = byteData.buffer.asUint8List();
          debugPrint('✅ Logo converted to bytes: ${imageBytes.length} bytes');
          return imageBytes;
        }
      }

      debugPrint('⚠️ Failed to convert logo to bytes');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to load logo: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  // ====================================================================
  //  UPDATED: Build receipt with 58mm support
  // ====================================================================
  Future<void> _buildSampleReceipt() async {
    try {
      _builder.clear();
      Uint8List? imageBytes = await logoCompany();
      _builder.printImage(imageBytes!);

      _builder.addText(
        maxCharPerLine: lengText(),
        widget.companyInfo?.name ?? "",
        fontSize: printerWidth == 384 ? 14 : 28, // Smaller for 58mm
        bold: true,
        align: AlignStyle.center,
      );

      _builder.addText(
        maxCharPerLine: lengText(),
        widget.companyInfo?.address ?? "",
        fontSize: printerWidth == 384 ? 12 : 18, // Smaller for 58mm
        align: AlignStyle.center,
      );

      PosSalesHeader? header = widget.detail?.header;

      _builder.addText(
        maxCharPerLine: lengText(),
        "Invoice #: ${header?.no ?? 'N/A'}",
        fontSize: printerWidth == 384 ? 12 : 18,
        align: AlignStyle.left,
      );

      _builder.addText(
        maxCharPerLine: lengText(),
        "Date: ${header?.orderDate ?? DateTime.now().toString().split(' ')[0]}",
        fontSize: printerWidth == 384 ? 12 : 18,
        align: AlignStyle.left,
      );

      _builder.addText(
        maxCharPerLine: lengText(),
        "Customer: ${header?.customerName ?? ""}",
        fontSize: printerWidth == 384 ? 12 : 18,
        align: AlignStyle.left,
      );

      // ====================================================================
      // SEPARATOR - Adjusted width for paper size
      // ====================================================================
      _builder.addText(
        maxCharPerLine: lengText(),
        "-" * (totalWidth - 1),
        fontSize: printerWidth == 384 ? 12 : 18,
        align: AlignStyle.center,
      );

      // ====================================================================
      // TABLE HEADER - Adjusted column widths
      // ====================================================================
      _builder.addRow([
        PosColumn(text: '#', width: columnWidths[0], bold: true),
        PosColumn(text: 'Item', width: columnWidths[1], bold: true),
        PosColumn(text: 'Qty', width: columnWidths[2], bold: true),
        PosColumn(text: 'Price', width: columnWidths[3], bold: true),
        PosColumn(text: 'Disc', width: columnWidths[4], bold: true),
        PosColumn(text: 'Total', width: columnWidths[5], bold: true),
      ], fontSize: printerWidth == 384 ? 8 : 18); // Smaller font for 58mm

      // Another separator
      _builder.addText(
        maxCharPerLine: lengText(),
        "-" * (totalWidth - 1),
        fontSize: printerWidth == 384 ? 12 : 18,

        align: AlignStyle.center,
      );

      // ====================================================================
      // ITEMS - Adjusted font size for 58mm
      // ====================================================================
      List<PosSalesLine> lines = widget.detail?.lines ?? [];
      for (var i = 0; i < lines.length; i++) {
        final item = lines[i];
        _builder.addRow([
          PosColumn(text: '${i + 1}', width: columnWidths[0], bold: false),
          PosColumn(
            bold: false,
            text: item.description ?? 'Item',
            width: columnWidths[1],
            align: AlignStyle.left,
          ),
          PosColumn(
            text: Helpers.formatNumber(
              item.quantity,
              option: FormatType.quantity,
            ),
            bold: false,
            width: columnWidths[2],
          ),
          PosColumn(
            text: Helpers.formatNumber(
              item.unitPrice,
              option: FormatType.amount,
            ),
            width: columnWidths[3],
            bold: false,
          ),
          PosColumn(
            text: Helpers.formatNumber(
              item.discountAmount == 0.0 || item.discountAmount == null
                  ? "-"
                  : item.discountAmount,
              option: FormatType.amount,
              display: true,
            ),
            width: columnWidths[4],
            bold: false,
          ),
          PosColumn(
            text: Helpers.formatNumber(item.amount, option: FormatType.amount),
            width: columnWidths[5],
            bold: false,
          ),
        ], fontSize: printerWidth == 384 ? 14 : 16); // Smaller for 58mm
      }

      // Total separator
      _builder.addText(
        "-" * (totalWidth - 1),
        fontSize: printerWidth == 384 ? 12 : 18,
        maxCharPerLine: 48,
        align: AlignStyle.center,
      );

      // ====================================================================
      // TOTAL SECTION
      // ====================================================================
      _builder.addText(
        "TOTAL AMOUNT: ${Helpers.formatNumber(header?.amount, option: FormatType.amount)}",
        fontSize: printerWidth == 384 ? 16 : 20, // Adjusted for 58mm
        bold: true,
        align: AlignStyle.right,
      );

      _builder.feedPaper(1);

      // ====================================================================
      // FOOTER
      // ====================================================================
      _builder.addText(
        'Thank you for your business!',
        fontSize: printerWidth == 384 ? 18 : 20, // Adjusted for 58mm
        bold: true,
        align: AlignStyle.center,
      );

      _builder.addText(
        'Please come again',
        fontSize: printerWidth == 384 ? 16 : 18, // Adjusted for 58mm
        align: AlignStyle.center,
      );

      _builder.feedPaper(3);
      _builder.cutPaper();

      if (mounted) {
        setState(() {
          isReceiptBuilt = true;
          buildError = null;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error building receipt: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          isReceiptBuilt = false;
          buildError = e.toString();
        });
      }
      rethrow;
    }
  }

  // ====================================================================
  // ✅ UPDATED: Print function with width setting
  // ====================================================================
  Future<void> _printReceipt() async {
    if (!isConnected()) {
      Helpers.showMessage(
        status: MessageStatus.errors,
        msg: "No printer connected!",
      );
      return;
    }

    setState(() => isPrinting = true);

    final l = LoadingOverlay.of(context);
    try {
      if (mounted) l.show();

      if (!_isPrinterWarmedUp) {
        debugPrint('🔥 Warming up printer before first print...');

        await ThermalPrinter.setPrinterWidth(printerWidth);
        debugPrint(
          '📏 Printer width set to $printerWidth (${printerWidth == 384 ? "58mm" : "80mm"})',
        );

        await ThermalPrinter.warmUpPrinter();
        await Future.delayed(const Duration(milliseconds: 250));

        await ThermalPrinter.configureOOMAS();
        await Future.delayed(const Duration(milliseconds: 200));

        _isPrinterWarmedUp = true;
      }

      debugPrint(
        '🖨️ Starting BATCH print for ${printerWidth == 384 ? "58mm" : "80mm"} paper...',
      );

      // ✅ Use batch mode
      await _builder.executeBatch(ThermalPrinter);

      debugPrint('✅ Print completed successfully!');

      if (mounted) {
        l.hide();
        Helpers.showMessage(
          status: MessageStatus.success,
          msg:
              "Receipt printed successfully on ${printerWidth == 384 ? "58mm" : "80mm"} paper! 🎉",
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Print failed: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        l.hide();
        Helpers.showMessage(
          status: MessageStatus.errors,
          msg: "Print failed: $e",
        );
      }
    } finally {
      if (mounted) {
        setState(() => isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Receipt Preview (${printerWidth == 384 ? "58mm" : "80mm"})',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  printerWidth == 384 ? '58mm' : '80mm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Transform.scale(
                    scale: isConnected() ? _pulseAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isConnected() ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isConnected()
                            ? [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: .5),
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
                            isConnected()
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          StreamBuilder(
                            stream: _bluetoothService.connectionStream,
                            builder: (context, snapshot) {
                              final device = snapshot.data;
                              final isConnected = device != null;
                              return Text(
                                isConnected ? 'Connected' : 'Disconnected',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: isReceiptBuilt
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Optional: Add a button to test slow printing
                if (isConnected())
                  // Main print button
                  FloatingActionButton.extended(
                    heroTag: 'print',
                    onPressed: isPrinting ? null : _printReceipt,
                    backgroundColor: isConnected() ? null : Colors.grey,
                    icon: isPrinting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.print),
                    label: Text(isPrinting ? 'Printing...' : 'Print Receipt'),
                  ),
              ],
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (buildError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to build receipt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                buildError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  buildError = null;
                  isReceiptBuilt = false;
                });
                _initializeReceipt();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!isReceiptBuilt) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Building receipt...'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ReceiptPreview(commands: _builder.commands),
          ),
        ),
      ],
    );
  }
}
