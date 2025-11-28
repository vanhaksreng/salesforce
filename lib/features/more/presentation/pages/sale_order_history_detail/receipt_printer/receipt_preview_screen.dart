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

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late List<int> columnWidths;
  late int totalWidth;

  // Printer width - will be set during initialization
  int printerWidth = 576; // Default to 80mm (576 pixels)

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

  void _configurePrinterSize() {
    if (printerWidth == 384) {
      // 58mm printer (32 chars per line at fontSize 20)
      columnWidths = [2, 6, 4, 5, 4, 5]; // [#, Item, Qty, Price, Disc, Total]
      totalWidth = 32;
    } else {
      // 80mm printer (48 chars per line at fontSize 20)
      columnWidths = [1, 4, 1, 2, 2, 2]; // Sums to 12
      totalWidth = 49;
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
          debugPrint('✅ Logo loaded from URL');
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
        debugPrint(' Logo loaded from base64');
      }

      // Convert ui.Image to Uint8List (PNG format)
      if (logoImage != null) {
        final byteData = await logoImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null) {
          final imageBytes = byteData.buffer.asUint8List();
          debugPrint(' Logo converted to bytes: ${imageBytes.length} bytes');
          return imageBytes;
        }
      }

      debugPrint(' Failed to convert logo to bytes');
      return null;
    } catch (e, stackTrace) {
      debugPrint(' Failed to load logo: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> _buildSampleReceipt() async {
    try {
      _builder.clear();
      final logoBytes = await logoCompany();
      _builder.addImage(logoBytes!, width: 200);

      _builder.addText(
        widget.companyInfo?.name ?? "",
        fontSize: 28,
        bold: true,
        align: AlignStyle.center,
      );
      _builder.addText(
        widget.companyInfo?.address ?? "",
        fontSize: 18,
        align: AlignStyle.center,
      );

      _builder.addText(
        widget.companyInfo?.phoneNo ?? "",
        fontSize: 18,
        align: AlignStyle.center,
      );

      // ══════════════════════════════════════════════════════════════
      // INVOICE INFO SECTION
      // ══════════════════════════════════════════════════════════════
      PosSalesHeader? header = widget.detail?.header;

      _builder.addText(
        "Invoice #: ${header?.no ?? 'N/A'}",
        fontSize: 20,
        align: AlignStyle.left,
      );
      _builder.addText(
        "Date: ${header?.orderDate ?? DateTime.now().toString().split(' ')[0]}",
        fontSize: 20,
        align: AlignStyle.left,
      );
      _builder.addText(
        "Customer: ${header?.customerName ?? ""}",
        fontSize: 20,
        align: AlignStyle.left,
      );
      _builder.addText(
        "=" * (totalWidth - 1),
        fontSize: 20,
        maxCharPerLine: 48,
        align: AlignStyle.center,
      );

      // ══════════════════════════════════════════════════════════════
      // ITEMS TABLE HEADER
      // ══════════════════════════════════════════════════════════════

      _builder.addRow([
        PosColumn(text: '#', width: columnWidths[0], bold: true),
        PosColumn(text: 'Item', width: columnWidths[1], bold: true),
        PosColumn(text: 'Qty', width: columnWidths[2], bold: true),
        PosColumn(text: 'Price', width: columnWidths[3], bold: true),
        PosColumn(text: 'Disc', width: columnWidths[4], bold: true),
        PosColumn(text: 'Total', width: columnWidths[5], bold: true),
      ], fontSize: 20);

      _builder.addText(
        "=" * (totalWidth - 1),
        fontSize: 20,
        maxCharPerLine: 48,
        align: AlignStyle.center,
      );

      // ══════════════════════════════════════════════════════════════
      // ITEMS LIST
      // ══════════════════════════════════════════════════════════════
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
        ], fontSize: 18);
      }

      // ══════════════════════════════════════════════════════════════
      // TOTALS SECTION
      // ══════════════════════════════════════════════════════════════

      _builder.addText(
        "=" * (totalWidth - 1),
        fontSize: 20,
        maxCharPerLine: 48,
        align: AlignStyle.center,
      );

      // _builder.addText(
      //   "Subtotal: ${Helpers.formatNumber(header?.amount ?? 0, option: FormatType.amount)}",
      //   fontSize: 20,
      //   bold: true,
      //   maxCharPerLine: 48,
      //   align: AlignStyle.right,
      // );
      _builder.addText(
        "TOTAL AMOUNT: ${Helpers.formatNumber(header?.amount, option: FormatType.amount)}",
        fontSize: 20,
        bold: true,
        maxCharPerLine: 48,
        align: AlignStyle.right,
      );

      _builder.feedPaper(1);
      _builder.addText(
        'Thank you for your business!',
        fontSize: 22,
        bold: true,
        align: AlignStyle.center,
      );
      _builder.addText(
        'Please come again',
        fontSize: 18,
        align: AlignStyle.center,
      );
      _builder.feedPaper(3);
      _builder.cutPaper();

      // IMPORTANT: Update state to show the receipt
      if (mounted) {
        setState(() {
          isReceiptBuilt = true;
          buildError = null;
        });
      }
    } catch (e, stackTrace) {
      debugPrint(' Error in _buildSampleReceipt: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          isReceiptBuilt = false;
          buildError = e.toString();
        });
      }

      rethrow; // Re-throw to be caught by _initializeReceipt
    }
  }

  Future<void> _printReceipt() async {
    if (!isConnected()) {
      Helpers.showMessage(
        status: MessageStatus.errors,
        msg: "No printer connected! Please connect in Administration.",
      );
      return;
    }

    setState(() => isPrinting = true);

    final l = LoadingOverlay.of(context);
    try {
      if (mounted) {
        l.show();
      }

      debugPrint(
        '🖨️ Starting print job with ${_builder.commands.length} commands...',
      );

      for (int i = 0; i < _builder.commands.length; i++) {
        final cmd = _builder.commands[i];

        try {
          switch (cmd.type) {
            case ReceiptCommandType.row:
              final columnsList = cmd.params["columns"] as List<dynamic>;
              final columns = columnsList
                  .map((col) => col as Map<String, dynamic>)
                  .toList();

              await ThermalPrinter.printRow(
                columns: columns,
                fontSize: cmd.params["fontSize"] ?? 24,
              );
              break;

            case ReceiptCommandType.text:
              await ThermalPrinter.printText(
                cmd.params["text"],
                fontSize: cmd.params["fontSize"] ?? 24,
                bold: cmd.params["bold"] ?? false,
                maxCharPerLine: cmd.params["maxCharsPerLine"] ?? 48,
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
              await Future.delayed(const Duration(milliseconds: 30));
              break;

            case ReceiptCommandType.cutPaper:
              await ThermalPrinter.cutPaper();
              break;
          }
        } catch (e) {
          debugPrint(' Error executing command $i (${cmd.type}): $e');
        }
      }

      if (mounted) {
        l.hide();
        Helpers.showMessage(
          status: MessageStatus.success,
          msg: "Receipt printed successfully!",
        );
      }
    } catch (e) {
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
        title: const Text('Receipt Preview'),
        actions: [
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
          ? FloatingActionButton.extended(
              onPressed: isPrinting ? null : _printReceipt,
              backgroundColor: isConnected() ? null : Colors.grey,
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

  Widget _buildBody() {
    if (buildError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
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
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
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
