import 'dart:async';

import 'package:flutter/material.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/administration/device_printer_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_builder.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_preview.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
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

  PrinterDeviceDiscover? selectedPrinter;
  // bool isConnected = true;

  bool isPrinting = false;
  bool isReceiptBuilt = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Column width configuration - will be set based on printer width
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
    _initializeReceipt();
    // Set printer configuration based on size
    _configurePrinterSize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    if (isConnected()) {
      ThermalPrinter.disconnect();
    }
    super.dispose();
  }

  bool isConnected() {
    if (selectedPrinter == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> _initializeReceipt() async {
    DevicePrinter? device = await loadSelectedPrinter();
    await _buildSampleReceipt();

    if (device == null) {
      Helpers.showMessage(
        status: MessageStatus.errors,
        msg: "Device not found! ,Please check connection on Administation",
      );
      return;
    }

    selectedPrinter = PrinterDeviceDiscover(
      name: device.originDeviceName,
      address: device.macAddress,
      type: Helpers.stringToConnectionType(device.typeConnection),
    );

    await ThermalPrinter.connect(selectedPrinter!);
  }

  void _configurePrinterSize() {
    if (printerWidth == 384) {
      // 58mm printer (32 chars per line at fontSize 20)
      columnWidths = [2, 6, 4, 5, 4, 5]; // [#, Item, Qty, Price, Disc, Total]
      totalWidth = 32;
    } else {
      // 80mm printer (48 chars per line at fontSize 20)
      // FIX: The column widths must sum to 12 for the library validation.
      columnWidths = [1, 4, 1, 2, 2, 2]; // Sums to 12
      totalWidth = 51;
    }
  }

  Future<void> _buildSampleReceipt() async {
    try {
      _builder.clear();

      _builder.addText(
        widget.companyInfo?.name ?? "COMPANY NAME",
        fontSize: 28,
        bold: true,
        align: AlignStyle.center,
      );
      _builder.addText(
        widget.companyInfo?.address ?? "123 Business Street, City",
        fontSize: 18,
        align: AlignStyle.center,
      );

      _builder.addText(
        "Email: ${widget.companyInfo?.email ?? 'info@company.com'}",
        fontSize: 18,
        align: AlignStyle.center,
      );
      _builder.feedPaper(1);
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
        "Customer: ${header?.customerName ?? 'Walk-in Customer'}",
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
      double subtotal = 0.0;

      for (var i = 0; i < lines.length; i++) {
        final item = lines[i];
        final amount = double.tryParse(item.amount?.toString() ?? '0') ?? 0.0;
        final discount =
            double.tryParse(item.discountAmount?.toString() ?? '0') ?? 0.0;

        subtotal += amount;

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
            text: Helpers.toStrings(item.unitPrice),
            width: columnWidths[3],
            bold: false,
          ),
          PosColumn(
            text: Helpers.toStrings(discount),
            width: columnWidths[4],
            bold: false,
          ),
          PosColumn(
            text: Helpers.toStrings(amount),
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

      _builder.addText(
        "Subtotal: ${Helpers.formatNumber(subtotal, option: FormatType.amount)}",
        fontSize: 20,
        bold: true,
        maxCharPerLine: 48,
        align: AlignStyle.right,
      );
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

      setState(() => isReceiptBuilt = true);
    } catch (e, stackTrace) {
      debugPrint('Stack trace: $stackTrace');
      setState(() => isReceiptBuilt = false);
    }
  }

  Future<void> _printReceipt() async {
    setState(() => isPrinting = true);
    if (!isConnected()) {
      Helpers.showMessage(
        status: MessageStatus.errors,
        msg: "Device not found! ,Please check connection on Administation",
      );
      setState(() => isPrinting = false);
      return;
    }
    final l = LoadingOverlay.of(context);
    try {
      if (mounted) {
        l.show();
      }

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
          debugPrint('Error executing command $i (${cmd.type}): $e');
        }
      }
      l.hide();
      return;
    } catch (e) {
      l.hide();
      return;
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
                            isConnected()
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            selectedPrinter != null
                                ? 'Connected'
                                : 'Disconnected',
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
        ],
      ),
      body: isReceiptBuilt
          ? Column(
              children: [
                // Printer info card
                if (selectedPrinter != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isConnected()
                            ? [Colors.green.shade50, Colors.green.shade100]
                            : [Colors.red.shade50, Colors.red.shade100],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isConnected()
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isConnected() ? Colors.green : Colors.red,
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
                        isConnected() ? Icons.check_circle : Icons.error,
                        color: isConnected() ? Colors.green : Colors.red,
                        size: 32,
                      ),
                    ),
                  ),

                // Receipt preview
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
}
