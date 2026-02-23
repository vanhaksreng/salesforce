import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/imin_device/imin_printer_service.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

import 'receipt_imin_preview.dart';

class ReceiptImin extends StatefulWidget {
  final CompanyInformation? companyInfo;
  final SaleDetail? detail;

  const ReceiptImin({super.key, this.companyInfo, this.detail});

  @override
  State<ReceiptImin> createState() => _ReceiptIminState();
}

class _ReceiptIminState extends State<ReceiptImin>
    with MessageMixin, TickerProviderStateMixin {
  final columnWidths = [1, 3, 2, 2, 2, 2];
  int printerWidth = 384;
  bool isReceiptBuilt = false;
  String? buildError;
  bool isPrinting = false;
  bool isLoadingPreview = false;
  Uint8List? logoBytes;
  String printingStatus = '';
  double printProgress = 0.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    initImin();
    _loadLogo();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> initImin() async {
    try {
      await IminPrinterService.initialize();
      final info = await IminPrinterService.getDeviceInfo();
      if (info['printerWidth'] != null) {
        setState(() {
          printerWidth = info['printerWidth'] as int;
        });
      }
    } catch (e) {
      debugPrint('Error initializing printer: $e');
    }
  }

  Future<void> _loadLogo() async {
    setState(() {
      isLoadingPreview = true;
    });

    try {
      if (widget.companyInfo?.logo128 != null &&
          widget.companyInfo!.logo128!.isNotEmpty) {
        setState(() {
          logoBytes = base64Decode(widget.companyInfo!.logo128!);
          isLoadingPreview = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error loading logo: $e');
      setState(() {
        logoBytes = null;
        isLoadingPreview = false;
      });
    }
  }

  int lengText() {
    return printerWidth = 32;
  }

  String discountValue({double? disAmount, double? disPer}) {
    return (disAmount != null && disAmount != 0.0)
        ? Helpers.formatNumber(disAmount, option: FormatType.amount)
        : (disPer != null && disPer != 0)
        ? Helpers.formatNumber(disPer, option: FormatType.percentage)
        : " ";
  }

  void _updateProgress(String status, double progress) {
    setState(() {
      printingStatus = status;
      printProgress = progress;
    });
  }

  Future<void> _buildAndPrintReceipt() async {
    if (isPrinting) return;

    setState(() {
      isPrinting = true;
      buildError = null;
      printProgress = 0.0;
      printingStatus = 'Starting...';
    });

    try {
      _updateProgress('Printing logo...', 0.1);

      if (logoBytes != null) {
        await IminPrinterService.printImage(logoBytes!, width: 120, align: 1);
      }

      _updateProgress('Printing company info...', 0.2);
      await IminPrinterService.printTextAsImage(
        widget.companyInfo?.name ?? "",
        fontSize: 16,
        bold: true,
        align: 'center',
        fontName: 'NotoSansKhmer',
      );

      await IminPrinterService.printTextAsImage(
        widget.companyInfo?.address ?? "",
        fontSize: 14,
        align: 'center',
        fontName: 'NotoSansKhmer',
      );

      await IminPrinterService.printTextAsImage(
        "Phone: ${widget.companyInfo?.phoneNo ?? ""}",
        fontSize: 14,
        align: 'center',
        fontName: 'NotoSansKhmer',
      );

      SalesHeader? header = widget.detail?.header;

      _updateProgress('Printing invoice details...', 0.3);
      await IminPrinterService.printTextAsImage(
        "Invoice   : ${header?.no ?? 'N/A'}",
        fontSize: 14,
        align: 'left',
        fontName: 'NotoSansKhmer',
      );
      await IminPrinterService.printTextAsImage(
        "Date      : ${header?.orderDate ?? DateTime.now().toString().split(' ')[0]}",
        fontSize: 14,
        align: 'left',
        fontName: 'NotoSansKhmer',
      );
      await IminPrinterService.printTextAsImage(
        "Customer  : ${header?.customerName ?? ""}",
        fontSize: 14,
        align: 'left',
        fontName: 'NotoSansKhmer',
      );

      await IminPrinterService.printSeparator(width: lengText());

      _updateProgress('Printing table...', 0.4);
      await IminPrinterService.printRow([
        {'text': 'ល.រ', 'width': columnWidths[0], 'align': 'left'},
        {'text': 'ឈ្មោះទំនិញ', 'width': columnWidths[1], 'align': 'left'},
        {'text': 'ចំនួន', 'width': columnWidths[2], 'align': 'center'},
        {'text': 'តម្លៃ', 'width': columnWidths[3], 'align': 'center'},
        {'text': 'ចុះតម្លៃ', 'width': columnWidths[4], 'align': 'center'},
        {'text': 'សរុប', 'width': columnWidths[5], 'align': 'center'},
      ], fontSize: 14);

      await IminPrinterService.printRow([
        {'text': 'No.', 'width': columnWidths[0], 'align': 'left'},
        {'text': 'Item', 'width': columnWidths[1], 'align': 'left'},
        {'text': 'Qty', 'width': columnWidths[2], 'align': 'center'},
        {'text': 'Price', 'width': columnWidths[3], 'align': 'center'},
        {'text': 'Disc', 'width': columnWidths[4], 'align': 'center'},
        {'text': 'Total', 'width': columnWidths[5], 'align': 'center'},
      ], fontSize: 14);

      await IminPrinterService.printSeparator(width: lengText());

      List<SalesLine> lines = widget.detail?.lines ?? [];
      for (var i = 0; i < lines.length; i++) {
        final item = lines[i];
        _updateProgress(
          'Printing item ${i + 1}/${lines.length}...',
          0.5 + (0.3 * (i / lines.length)),
        );

        await IminPrinterService.printRow([
          {'text': '${i + 1}', 'width': columnWidths[0], 'align': 'left'},
          {
            'text': item.description ?? "",
            'width': columnWidths[1],
            'align': 'left',
          },
          {
            'text': Helpers.formatNumber(
              item.quantity,
              option: FormatType.quantity,
            ),
            'width': columnWidths[2],
            'align': 'center',
          },
          {
            'text': Helpers.formatNumber(
              item.unitPrice,
              option: FormatType.amount,
              display: false,
            ),
            'width': columnWidths[3],
            'align': 'center',
          },
          {
            'text': discountValue(
              disAmount: item.discountAmount,
              disPer: item.discountPercentage,
            ),
            'width': columnWidths[4],
            'align': 'center',
          },
          {
            'text': Helpers.formatNumber(
              item.amount,
              option: FormatType.amount,
              display: false,
            ),
            'width': columnWidths[5],
            'align': 'center',
          },
        ], fontSize: 12);

        if (i < lines.length - 1) {
          await IminPrinterService.printText(
            "-" * (lengText() - 1),
            fontSize: 12,
            align: 'center',
          );
        }
      }

      await IminPrinterService.printSeparator(width: lengText());

      _updateProgress('Printing total...', 0.85);
      await IminPrinterService.printTextAsImage(
        "TOTAL AMOUNT: ${Helpers.formatNumber(header?.amount, option: FormatType.amount)}",
        fontSize: 16,
        bold: true,
        align: 'right',
        fontName: 'NotoSansKhmer',
      );

      await IminPrinterService.feedPaper(lines: 1);

      _updateProgress('Printing footer...', 0.9);
      await IminPrinterService.printTextAsImage(
        'Thank you for your business!',
        fontSize: 16,
        bold: true,
        align: 'center',
        fontName: 'NotoSansKhmer',
      );

      await IminPrinterService.printTextAsImage(
        'Please come again',
        fontSize: 14,
        align: 'center',
        fontName: 'NotoSansKhmer',
      );

      _updateProgress('Cutting paper...', 0.95);
      await IminPrinterService.feedPaper(lines: 2);
      await IminPrinterService.cutPaper();

      _updateProgress('Complete!', 1.0);

      if (mounted) {
        setState(() {
          isReceiptBuilt = true;
          isPrinting = false;
        });

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          showSuccessMessage(greeting("Receipt printed successfully!"));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error printing receipt: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          isReceiptBuilt = false;
          buildError = e.toString();
          isPrinting = false;
          printingStatus = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SalesHeader? header = widget.detail?.header;
    final List<SalesLine> lines = widget.detail?.lines ?? [];

    final receiptItems = lines.map((item) {
      return ReceiptItem(
        item: item.description ?? "",
        qty: Helpers.formatNumber(item.quantity, option: FormatType.quantity),
        price: Helpers.formatNumber(
          item.unitPrice,
          option: FormatType.amount,
          display: false,
        ),
        disc: discountValue(
          disAmount: item.discountAmount,
          disPer: item.discountPercentage,
        ),
        total: Helpers.formatNumber(
          item.amount,
          option: FormatType.amount,
          display: false,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoadingPreview || isPrinting ? null : _loadLogo,
            tooltip: 'Refresh Preview',
          ),
          IconButton(
            icon: isPrinting
                ? ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(Icons.print, color: Colors.white),
                  )
                : const Icon(Icons.print),
            onPressed: isPrinting ? null : _buildAndPrintReceipt,
            tooltip: 'Print Receipt',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator when printing
          if (isPrinting)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          value: printProgress,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              printingStatus,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: printProgress,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(printProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Preview section
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: isLoadingPreview
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.blue.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Loading preview...'),
                        ],
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: ReceiptPreviewWidget(
                          companyName: widget.companyInfo?.name,
                          companyAddress: widget.companyInfo?.address,
                          companyPhone: widget.companyInfo?.phoneNo,
                          invoiceNo: header?.no,
                          date:
                              header?.orderDate ??
                              DateTime.now().toString().split(' ')[0],
                          customerName: header?.customerName,
                          items: receiptItems,
                          totalAmount: Helpers.formatNumber(
                            header?.amount,
                            option: FormatType.amount,
                          ),
                          logoBytes: logoBytes,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: TextWidget(text: greeting("Print Receipt"), color: white),
        backgroundColor: primary,
        onPressed: () => _buildAndPrintReceipt(),
        icon: Icon(Icons.print),
      ),
    );
  }
}

extension IminPrinterServiceExtension on IminPrinterService {
  static Future<void> printText({
    required String text,
    int fontSize = 16,
    bool bold = false,
    String align = 'left',
    int maxCharsPerLine = 0,
  }) async {
    await IminPrinterService.printTextAsImage(
      text,
      fontSize: fontSize,
      bold: bold,
      align: align,
      fontName: 'NotoSansKhmer',
    );
  }
}
