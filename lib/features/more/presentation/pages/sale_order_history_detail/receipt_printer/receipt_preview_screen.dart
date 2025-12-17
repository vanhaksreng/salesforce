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
  int printerWidth = 576; // 80mm printer
  int textLength = 32; // 80mm printer

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

  int lengText() {
    if (printerWidth == 384) {
      return 32;
    }
    return 48;
  }

  Future<void> _warmUpPrinterIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (isConnected() && !_isPrinterWarmedUp) {
      try {
        await ThermalPrinter.setPrinterWidth(Helpers.toInt(printerWidth));

        await ThermalPrinter.warmUpPrinter();
        await Future.delayed(const Duration(milliseconds: 100));

        await ThermalPrinter.configureOOMAS();
        await Future.delayed(const Duration(milliseconds: 100));

        _isPrinterWarmedUp = true;
      } catch (e) {
        debugPrint(' Warmup failed: $e');
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
    } catch (e) {
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

  void _configurePrinterSize() async {
    printerWidth = Helpers.toInt(_bluetoothService.connectedDevice?.paperSize);
    if (printerWidth == 384) {
      // 58mm printer configuration
      debugPrint(' Configuring for 58mm paper (384 pixels)');
      columnWidths = [1, 3, 2, 2, 2, 2];
    } else {
      // 80mm printer configuration
      debugPrint(' Configuring for 80mm paper (576 pixels)');
      columnWidths = [1, 3, 2, 2, 2, 2]; // Standard layout - totals to 12
    }
    lengText();
  }

  Future<Uint8List?> logoCompany({int? targetWidth, int? targetHeight}) async {
    final companyInfo = widget.companyInfo;

    if (companyInfo == null ||
        companyInfo.logo128 == null ||
        companyInfo.logo128!.isEmpty) {
      return null;
    }

    try {
      ui.Image? logoImage;

      if (companyInfo.logo128!.startsWith('http') ||
          companyInfo.logo128!.startsWith('https')) {
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
          final codec = await ui.instantiateImageCodec(
            response.bodyBytes,
            targetWidth: targetWidth,
            targetHeight: targetHeight,
          );
          final frame = await codec.getNextFrame();
          logoImage = frame.image;
        } else {
          throw Exception('Failed to download logo: ${response.statusCode}');
        }
      } else {
        String base64String = companyInfo.logo128!;

        // Remove data URI prefix if present (e.g., "data:image/png;base64,")
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        final bytes = base64Decode(base64String);
        final codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        );
        final frame = await codec.getNextFrame();
        logoImage = frame.image;
      }

      final byteData = await logoImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final imageBytes = byteData.buffer.asUint8List();

        return imageBytes;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _buildSampleReceipt() async {
    try {
      _builder.clear();
      Uint8List? imageBytes = await logoCompany(
        targetWidth: 120,
        targetHeight: 120,
      );
      if (imageBytes != null) {
        _builder.printImage(imageBytes, width: 120);
      }

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
      _builder.addText(
        maxCharPerLine: lengText(),
        "Phone: ${widget.companyInfo?.phoneNo ?? ""}",
        fontSize: printerWidth == 384 ? 12 : 18, // Smaller for 58mm
        align: AlignStyle.center,
      );

      _builder.feedPaper(1);

      SalesHeader? header = widget.detail?.header;

      _builder.addText(
        maxCharPerLine: lengText(),
        "Invoice   : ${header?.no ?? 'N/A'}",
        fontSize: printerWidth == 384 ? 12 : 18,
        align: AlignStyle.left,
      );

      _builder.addText(
        maxCharPerLine: lengText(),
        "Date      : ${header?.orderDate ?? DateTime.now().toString().split(' ')[0]}",
        fontSize: printerWidth == 384 ? 12 : 18,
        align: AlignStyle.left,
      );

      _builder.addText(
        maxCharPerLine: lengText(),
        "Customer  : ${header?.customerName ?? ""}",
        fontSize: printerWidth == 384 ? 12 : 18,
        align: AlignStyle.left,
      );

      _builder.addText(
        maxCharPerLine: lengText(),
        "-" * (lengText() - 1),
        align: AlignStyle.center,
      );

      // ====================================================================
      // TABLE HEADER - Adjusted column widths
      // ====================================================================

      _builder.addRow(
        [
          PosColumn(text: 'ល.រ', width: columnWidths[0], bold: false),
          PosColumn(text: 'ឈ្មោះទំនិញ', width: columnWidths[1], bold: false),
          PosColumn(
            text: 'ចំនួន',
            width: columnWidths[2],
            bold: false,
            align: AlignStyle.center,
          ),
          PosColumn(
            text: 'តម្លៃ',
            width: columnWidths[3],
            bold: false,
            align: AlignStyle.center,
          ),
          PosColumn(
            text: 'ចុះតម្លៃ',
            width: columnWidths[4],
            bold: false,
            align: AlignStyle.center,
          ),
          PosColumn(
            text: 'សរុប',
            width: columnWidths[5],
            bold: false,
            align: AlignStyle.center,
          ),
        ],
        fontSize: printerWidth == 384 ? 14 : 18,
        autoAdjust: true,
      ); // Smaller font for 58mm

      _builder.addRow([
        PosColumn(text: 'No.', width: columnWidths[0], bold: true),
        PosColumn(text: 'Item', width: columnWidths[1], bold: true),
        PosColumn(
          text: 'Qty',
          width: columnWidths[2],
          bold: true,
          align: AlignStyle.center,
        ),
        PosColumn(
          text: 'Price',
          width: columnWidths[3],
          bold: true,
          align: AlignStyle.center,
        ),
        PosColumn(
          text: 'Disc',
          width: columnWidths[4],
          bold: true,
          align: AlignStyle.center,
        ),
        PosColumn(
          text: 'Total',
          width: columnWidths[5],
          bold: true,
          align: AlignStyle.center,
        ),
      ], fontSize: printerWidth == 384 ? 12 : 14); // Smaller font for 58mm

      // Another separator
      _builder.addText(
        maxCharPerLine: lengText(),
        "-" * (lengText() - 1),
        align: AlignStyle.center,
      );

      List<SalesLine> lines = widget.detail?.lines ?? [];
      for (var i = 0; i < lines.length; i++) {
        final item = lines[i];
        _builder.addRow([
          PosColumn(text: '${i + 1}', width: columnWidths[0], bold: false),
          PosColumn(
            bold: false,
            text: item.description ?? "",
            width: columnWidths[1],
            align: AlignStyle.left,
          ),
          PosColumn(
            text: Helpers.formatNumber(
              item.quantity,
              option: FormatType.quantity,
            ),
            align: AlignStyle.center,
            bold: false,
            width: columnWidths[2],
          ),
          PosColumn(
            text: Helpers.formatNumber(
              item.unitPrice,
              option: FormatType.amount,
              display: false,
            ),
            align: AlignStyle.center,
            width: columnWidths[3],
            bold: false,
          ),

          PosColumn(
            text: discountValue(
              disAmount: item.discountAmount,
              disPer: item.discountPercentage,
            ),

            align: AlignStyle.center,
            width: columnWidths[4],
            bold: false,
          ),
          PosColumn(
            text: Helpers.formatNumber(
              item.amount,
              option: FormatType.amount,
              display: false,
            ),
            align: AlignStyle.center,
            width: columnWidths[5],
            bold: false,
          ),
        ], fontSize: printerWidth == 384 ? 12 : 16); // Smaller for 58mm
        _builder.addText(
          "-" * (lengText() - 1),
          maxCharPerLine: 48,
          align: AlignStyle.center,
        );
      }

      _builder.addText(
        "TOTAL AMOUNT: ${Helpers.formatNumber(header?.amount, option: FormatType.amount)}",
        fontSize: printerWidth == 384 ? 16 : 20, // Adjusted for 58mm
        bold: true,
        align: AlignStyle.right,
      );

      _builder.feedPaper(1);

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

  discountValue({double? disAmount, double? disPer}) {
    return (disAmount != null && disAmount != 0.0)
        ? Helpers.formatNumber(disAmount, option: FormatType.amount)
        : (disPer != null && disPer != 0)
        ? Helpers.formatNumber(disPer, option: FormatType.percentage)
        : " ";
  }

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

      await _builder.executeBatch(ThermalPrinter);

      if (mounted) {
        l.hide();
        Helpers.showMessage(
          status: MessageStatus.success,
          msg:
              "Receipt printed successfully on ${printerWidth == 384 ? "58mm" : "80mm"} paper! 🎉",
        );
      }
    } catch (e, stackTrace) {
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
            child: Center(
              child: ReceiptPreview(
                commands: _builder.commands,
                paperWidth: printerWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
