import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_preview_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaleOrderHistoryDetailScreen extends StatefulWidget {
  const SaleOrderHistoryDetailScreen({
    super.key,
    required this.documentNo,
    required this.typeDoc,
  });

  final String documentNo;
  final String typeDoc;
  static const String routeName = "SaleOrderDetailHistoryScreen";

  @override
  State<SaleOrderHistoryDetailScreen> createState() =>
      _SaleOrderHistoryDetailScreenState();
}

class _SaleOrderHistoryDetailScreenState
    extends State<SaleOrderHistoryDetailScreen>
    with MessageMixin {
  final _cubit = SaleOrderHistoryDetailCubit();

  List<BluetoothInfo> devices = [];
  bool connected = false;
  String? connectedMac;
  String? connectingMac;
  String statusMessage = "";

  @override
  void initState() {
    super.initState();
    loadData();
    _initializePrinter();
  }

  Future<void> loadData() async {
    await _cubit.getSaleDetails(no: widget.documentNo);
    await _cubit.getComapyInfo();
  }

  String _getTitle() {
    switch (widget.typeDoc) {
      case 'Invoice':
        return 'Sale Invoice Detail';
      case 'Order':
        return 'Sale Order Detail';
      default:
        return 'Sale Credit Memo Detail';
    }
  }

  Future<void> _initializePrinter() async {
    try {
      await scanDevices();
      await checkExistingConnection();

      if (!connected && devices.isNotEmpty) {
        final storedMac = await _getStoredConnectedMac();
        if (storedMac != null && devices.any((d) => d.macAdress == storedMac)) {
          await connect(storedMac);
        }
      }
    } catch (e) {
      debugPrint("Initialization failed: $e");
      if (mounted) {
        setState(() => statusMessage = "Failed to initialize printer");
      }
    }
  }

  Future<void> scanDevices() async {
    try {
      final result = await PrintBluetoothThermal.pairedBluetooths;
      if (mounted) {
        setState(() => devices = result);
      }
    } catch (e) {
      debugPrint("Scan error: $e");
    }
  }

  Future<void> checkExistingConnection() async {
    try {
      final isConnected = await PrintBluetoothThermal.connectionStatus;
      if (isConnected) {
        final storedMac = await _getStoredConnectedMac();
        if (storedMac != null) {
          setState(() {
            connected = true;
            connectedMac = storedMac;
            statusMessage = "Already connected ";
          });
        }
      }
    } catch (e) {
      debugPrint("Check connection error: $e");
    }
  }

  Future<void> connect(String mac) async {
    if (connectingMac != null) return;

    setState(() {
      connectingMac = mac;
      statusMessage = "Connecting...";
    });

    try {
      if (connected) {
        await PrintBluetoothThermal.disconnect;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final success = await PrintBluetoothThermal.connect(
        macPrinterAddress: mac,
      ).timeout(const Duration(seconds: 10), onTimeout: () => false);

      if (!success) throw Exception("Connection failed");

      await Future.delayed(const Duration(milliseconds: 500));
      final stillConnected = await PrintBluetoothThermal.connectionStatus;
      if (!stillConnected) throw Exception("Lost connection");

      await _saveConnectedMac(mac);
      if (mounted) {
        setState(() {
          connected = true;
          connectedMac = mac;
          statusMessage = "Connected ";
        });
      }

      // test printer
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      await PrintBluetoothThermal.writeBytes(generator.reset());
    } catch (e) {
      if (mounted) {
        setState(() {
          connected = false;
          connectedMac = null;
          statusMessage = "Connection failed ";
        });
      }
    } finally {
      if (mounted) setState(() => connectingMac = null);
    }
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('connected_printer_mac');
      if (mounted) {
        setState(() {
          connected = false;
          connectedMac = null;
          statusMessage = "Disconnected";
        });
      }
    } catch (e) {
      debugPrint("Disconnect error: $e");
    }
  }

  Future<void> _saveConnectedMac(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('connected_printer_mac', mac);
  }

  Future<String?> _getStoredConnectedMac() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('connected_printer_mac');
  }

  Future<void> showPrintPreview({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    final l = LoadingOverlay.of(context);

    if (detail == null || companyInfo == null) {
      showErrorMessage("No data available to print");

      return;
    }

    try {
      l.show();
      final receiptImage = await _createReceiptImage(
        detail: detail,
        companyInfo: companyInfo,
      );

      final pngBytes = img.encodePng(receiptImage);

      if (!mounted) return;

      l.hide();

      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: white),
                    const SizedBox(width: 8),
                    const Text(
                      'Receipt Preview',
                      style: TextStyle(
                        color: white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Preview Image (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(scaleFontSize(appSpace)),
                  child: Image.memory(pngBytes, fit: BoxFit.contain),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: BtnWidget(
                        onPressed: () => Navigator.of(context).pop(),
                        title: greeting("Cancel"),
                        bgColor: red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BtnWidget(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await printReceipt(
                            detail: detail,
                            companyInfo: companyInfo,
                          );
                        },
                        icon: Icon(Icons.print, color: white),
                        title: greeting("Print"),
                        bgColor: success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading
      showErrorMessage("Failed to generate preview: $e");
    }
  }

  Future<void> printReceipt({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    // Navigator.push(
    //   context,
    //   // MaterialPageRoute(builder: (context) => ReceiptPrinterApp()),
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         ReceiptPreviewScreen(companyInfo: companyInfo, detail: detail),
    //   ),
    // );
    return;
    try {
      debugPrint(" Starting print job...");

      bool isConnected = await PrintBluetoothThermal.connectionStatus;

      if (!isConnected) {
        debugPrint(" Printer not connected");
        showErrorMessage("Printer not connected!");

        if (connectedMac != null) {
          debugPrint(" Attempting to reconnect...");
          await connect(connectedMac!);
          isConnected = await PrintBluetoothThermal.connectionStatus;
          if (!isConnected) return;
        } else {
          return;
        }
      }

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      List<int> bytes = [];
      bytes += generator.reset();
      debugPrint("Creating receipt image...");
      final receiptImage = await _createReceiptImage(
        detail: detail,
        companyInfo: companyInfo,
      );

      debugPrint(" Converting to printer bytes...");
      bytes += generator.imageRaster(receiptImage);
      bytes += generator.cut();

      debugPrint(" Sending ${bytes.length} bytes to printer...");
      await PrintBluetoothThermal.writeBytes(bytes);

      showSuccessMessage("Sending to Printer!");
    } catch (e) {
      debugPrint("Print error: $e");
      showErrorMessage("Print failed: $e");
    }
  }

  Future<img.Image> _createReceiptImage({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    const width = 576;

    final textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontFamily: 'NotoSansKhmer',
    );
    final boldStyle = textStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 22,
    );
    final headerStyle = textStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 26,
    );

    // Helper to measure text height
    double measureText(String text, TextStyle style, {double maxWidth = 536}) {
      final span = TextSpan(text: text, style: style);
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        maxLines: 10,
      );
      painter.layout(maxWidth: maxWidth);
      return painter.height;
    }

    // Helper to wrap text
    List<String> wrapText(String text, TextStyle style, double maxWidth) {
      final words = text.split(' ');
      List<String> lines = [];
      String currentLine = '';

      final testPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );

      for (var word in words) {
        final testLine = currentLine.isEmpty ? word : '$currentLine $word';
        testPainter.text = TextSpan(text: testLine, style: style);
        testPainter.layout(maxWidth: maxWidth);

        if (testPainter.didExceedMaxLines || testPainter.width > maxWidth) {
          if (currentLine.isNotEmpty) lines.add(currentLine.trim());
          currentLine = word;
        } else {
          currentLine = testLine;
        }
      }

      if (currentLine.isNotEmpty) lines.add(currentLine.trim());
      return lines;
    }

    // Load logo first
    ui.Image? logoImage;
    if (companyInfo?.logo128 != null && companyInfo!.logo128!.isNotEmpty) {
      try {
        if (companyInfo.logo128!.startsWith('http')) {
          final response = await http.get(Uri.parse(companyInfo.logo128!));
          if (response.statusCode == 200) {
            final codec = await ui.instantiateImageCodec(response.bodyBytes);
            final frame = await codec.getNextFrame();
            logoImage = frame.image;
          }
        } else {
          final bytes = base64Decode(companyInfo.logo128!);
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          logoImage = frame.image;
        }
      } catch (e) {
        debugPrint(" Failed to load logo: $e");
      }
    }

    double y = 10;
    if (logoImage != null) {
      y += (logoImage.height / (logoImage.width / 200)) + 10;
    }

    y +=
        measureText(
          companyInfo?.name ?? "Company",
          headerStyle.copyWith(fontSize: 30),
        ) +
        2;
    y += measureText(companyInfo?.address ?? "Address", textStyle) + 2;
    y += measureText("Email: ${companyInfo?.email ?? ''}", textStyle) + 5;
    y += measureText("═" * 37, textStyle) + 3;
    y +=
        measureText(
          "Customer: ${detail?.header.customerName ?? ''}",
          textStyle,
        ) +
        2;
    y +=
        measureText(
          "Date: ${detail?.header.documentDate ?? DateTime.now()}",
          textStyle,
        ) +
        2;
    y += measureText("Invoice No: ${detail?.header.no ?? ''}", textStyle) + 5;
    y += measureText("─" * 37, textStyle) + 2;
    y += 26;
    y += measureText("─" * 37, textStyle) + 2;

    for (var line in detail?.lines ?? []) {
      final desc = line.description ?? "-";
      final wrappedLines = wrapText(desc, textStyle, 180);
      y += 26;
      if (wrappedLines.length > 1) y += (wrappedLines.length - 1) * 24;
    }

    y += 5;
    y += measureText("─" * 37, textStyle) + 2;
    y += 26;
    if (detail?.header.priceIncludeVat != null) y += 26;
    y += 5;
    y += measureText("═" * 37, textStyle) + 2;
    y += 30;
    y += measureText("═" * 37, textStyle) + 5;
    y += measureText("សូមអរគុណ! Thank you for shopping!", boldStyle) + 2;
    y +=
        measureText(
          "We look forward to serving you again! ❤️",
          textStyle.copyWith(fontSize: 19),
        ) +
        2;
    y +=
        measureText(
          "Powered by Blue Technology Co., Ltd.",
          textStyle.copyWith(fontSize: 17),
        ) +
        10;

    final height = y.toInt();

    // Canvas setup
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );

    y = 10;

    // Draw logo
    if (logoImage != null) {
      final logoWidth = 200.0;
      final logoHeight = logoImage.height * (logoWidth / logoImage.width);
      final logoX = (width - logoWidth) / 2;
      canvas.drawImageRect(
        logoImage,
        Rect.fromLTWH(
          0,
          0,
          logoImage.width.toDouble(),
          logoImage.height.toDouble(),
        ),
        Rect.fromLTWH(logoX, y, logoWidth, logoHeight),
        Paint(),
      );
      y += logoHeight + 10;
    }

    // Draw helpers
    void drawText(
      String text,
      TextStyle style, {
      TextAlign align = TextAlign.left,
      double spacing = 2,
    }) {
      final span = TextSpan(text: text, style: style);
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: align,
      );
      painter.layout(maxWidth: width - 40);
      double xOffset = 20;
      if (align == TextAlign.center) {
        xOffset = (width - painter.width) / 2;
      } else if (align == TextAlign.right) {
        xOffset = width - painter.width - 20;
      }
      painter.paint(canvas, Offset(xOffset, y));
      y += painter.height + spacing;
    }

    void drawAlignedText(
      String text,
      double x,
      double yPos,
      double maxWidth,
      TextStyle style,
      TextAlign align,
    ) {
      final span = TextSpan(text: text, style: style);
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: align,
      );
      painter.layout(maxWidth: maxWidth);

      double xOffset = x;
      if (align == TextAlign.right)
        xOffset = x + maxWidth - painter.width;
      else if (align == TextAlign.center)
        xOffset = x + (maxWidth - painter.width) / 2;

      painter.paint(canvas, Offset(xOffset, yPos));
    }

    // Draw content
    drawText(
      companyInfo?.name ?? "",
      headerStyle.copyWith(fontSize: 30),
      align: TextAlign.center,
    );
    drawText(companyInfo?.address ?? "", textStyle, align: TextAlign.center);
    drawText(
      "Email: ${companyInfo?.email ?? ''}",
      textStyle,
      align: TextAlign.center,
      spacing: 5,
    );
    drawText("═" * 37, textStyle, spacing: 3);

    drawText("Customer: ${detail?.header.customerName ?? ''}", textStyle);
    drawText("Date: ${detail?.header.documentDate ?? ''}", textStyle);
    drawText("Invoice No: ${detail?.header.no ?? ''}", textStyle, spacing: 5);
    drawText("─" * 37, textStyle, spacing: 2);

    final headerY = y;
    drawAlignedText("#", 15, headerY, 25, boldStyle, TextAlign.left);
    drawAlignedText("Description", 45, headerY, 180, boldStyle, TextAlign.left);
    drawAlignedText("Qty", 230, headerY, 60, boldStyle, TextAlign.right);
    drawAlignedText("Price", 280, headerY, 100, boldStyle, TextAlign.right);
    drawAlignedText("Disc", 355, headerY, 100, boldStyle, TextAlign.right);
    drawAlignedText("Amount", 420, headerY, 135, boldStyle, TextAlign.right);
    y += 26;
    drawText("─" * 37, textStyle, spacing: 2);

    int itemNumber = 1;
    for (var line in detail?.lines ?? []) {
      final desc = line.description ?? "-";
      final qty = Helpers.toInt(line.quantity).toString();
      final price = Helpers.formatNumber(
        line.unitPrice,
        option: FormatType.amount,
      );
      final discount = Helpers.formatNumber(
        line.discountAmount,
        option: FormatType.amount,
      );
      final amount = Helpers.formatNumber(
        line.amountIncludingVat,
        option: FormatType.amount,
      );

      final rowY = y;
      final wrappedLines = wrapText(desc, textStyle, 180);

      drawAlignedText(
        itemNumber.toString(),
        15,
        rowY,
        25,
        textStyle,
        TextAlign.left,
      );
      for (int i = 0; i < wrappedLines.length; i++) {
        final lineY = rowY + (i * 26);
        drawAlignedText(
          wrappedLines[i],
          45,
          lineY,
          180,
          textStyle,
          TextAlign.left,
        );
      }

      drawAlignedText(qty, 230, rowY, 60, textStyle, TextAlign.right);
      drawAlignedText(price, 280, rowY, 100, textStyle, TextAlign.right);
      drawAlignedText(discount, 355, rowY, 100, textStyle, TextAlign.right);
      drawAlignedText(amount, 420, rowY, 135, textStyle, TextAlign.right);

      y += 30;
      if (wrappedLines.length > 1) y += (wrappedLines.length - 1) * 26;
      itemNumber++;
    }

    y += 5;
    drawText("─" * 37, textStyle, spacing: 2);

    final total = detail?.header.amount ?? 0;

    if (detail?.header.priceIncludeVat != null) {
      drawAlignedText("Sub-Total:", 20, y, 200, textStyle, TextAlign.left);
      drawAlignedText(
        Helpers.formatNumber(
          detail?.header.priceIncludeVat ?? 0,
          option: FormatType.amount,
        ),
        420,
        y,
        135,
        textStyle,
        TextAlign.right,
      );
      y += 26;
    }

    y += 5;
    drawText("═" * 37, textStyle, spacing: 2);

    drawAlignedText(
      "TOTAL:",
      20,
      y,
      200,
      boldStyle.copyWith(fontSize: 26),
      TextAlign.left,
    );
    drawAlignedText(
      Helpers.formatNumber(total, option: FormatType.amount),
      420,
      y,
      135,
      boldStyle.copyWith(fontSize: 26),
      TextAlign.right,
    );
    y += 30;

    drawText("═" * 37, textStyle, spacing: 5);

    drawText(
      "សូមអរគុណ! Thank you for shopping!",
      boldStyle,
      align: TextAlign.center,
    );
    drawText(
      "We look forward to serving you again! ❤️",
      textStyle.copyWith(fontSize: 19),
      align: TextAlign.center,
    );
    drawText(
      "Powered by Blue Technology Co., Ltd.",
      textStyle.copyWith(fontSize: 17),
      align: TextAlign.center,
      spacing: 0,
    );

    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(width, height);
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    debugPrint("Receipt image created: ${width}x$height pixels");
    return img.decodeImage(pngBytes)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting(_getTitle()),
        actions: [
          BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
            bloc: _cubit,
            builder: (tx, state) {
              final detail = state.record;
              final company = state.comPanyInfo;
              return BtnIconCircleWidget(
                onPressed: () =>
                    showPrintPreview(detail: detail, companyInfo: company),
                icons: const Icon(Icons.print_rounded, color: white),
                rounded: appBtnRound,
              );
            },
          ),
          Helpers.gapW(appSpace),
        ],
      ),
      body:
          BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.isLoading) return const LoadingPageWidget();
              final record = state.record;
              return ListView(
                padding: const EdgeInsets.all(appSpace),
                children: [
                  SaleHistoryDetailBox(
                    header: record?.header,
                    lines: record?.lines ?? [],
                  ),
                ],
              );
            },
          ),
    );
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui' as ui;
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as img;
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:salesforce/core/constants/app_styles.dart';
// import 'package:salesforce/core/enums/enums.dart';
// import 'package:salesforce/core/mixins/message_mixin.dart';
// import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
// import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
// import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
// import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
// import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
// import 'package:salesforce/core/utils/helpers.dart';
// import 'package:salesforce/core/utils/size_config.dart';
// import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
// import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/improve_receipt_builder.dart';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_preview_screen.dart';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
// import 'package:salesforce/localization/trans.dart';
// import 'package:salesforce/realm/scheme/schemas.dart';
// import 'package:salesforce/theme/app_colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SaleOrderHistoryDetailScreen extends StatefulWidget {
//   const SaleOrderHistoryDetailScreen({
//     super.key,
//     required this.documentNo,
//     required this.typeDoc,
//   });

//   final String documentNo;
//   final String typeDoc;
//   static const String routeName = "SaleOrderDetailHistoryScreen";

//   @override
//   State<SaleOrderHistoryDetailScreen> createState() =>
//       _SaleOrderHistoryDetailScreenState();
// }

// class _SaleOrderHistoryDetailScreenState
//     extends State<SaleOrderHistoryDetailScreen>
//     with MessageMixin {
//   final _cubit = SaleOrderHistoryDetailCubit();

//   List<BluetoothInfo> devices = [];
//   bool connected = false;
//   String? connectedMac;
//   String? connectingMac;
//   String statusMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//     _initializePrinter();
//   }

//   Future<void> loadData() async {
//     await _cubit.getSaleDetails(no: widget.documentNo);
//     await _cubit.getComapyInfo();
//   }

//   String _getTitle() {
//     switch (widget.typeDoc) {
//       case 'Invoice':
//         return 'Sale Invoice Detail';
//       case 'Order':
//         return 'Sale Order Detail';
//       default:
//         return 'Sale Credit Memo Detail';
//     }
//   }

//   Future<void> _initializePrinter() async {
//     try {
//       await scanDevices();
//       await checkExistingConnection();

//       if (!connected && devices.isNotEmpty) {
//         final storedMac = await _getStoredConnectedMac();
//         if (storedMac != null && devices.any((d) => d.macAdress == storedMac)) {
//           await connect(storedMac);
//         }
//       }
//     } catch (e) {
//       debugPrint("Initialization failed: $e");
//       if (mounted) {
//         setState(() => statusMessage = "Failed to initialize printer");
//       }
//     }
//   }

//   Future<void> scanDevices() async {
//     try {
//       final result = await PrintBluetoothThermal.pairedBluetooths;
//       if (mounted) {
//         setState(() => devices = result);
//       }
//     } catch (e) {
//       debugPrint("Scan error: $e");
//     }
//   }

//   Future<void> checkExistingConnection() async {
//     try {
//       final isConnected = await PrintBluetoothThermal.connectionStatus;
//       if (isConnected) {
//         final storedMac = await _getStoredConnectedMac();
//         if (storedMac != null) {
//           setState(() {
//             connected = true;
//             connectedMac = storedMac;
//             statusMessage = "Already connected ";
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint("Check connection error: $e");
//     }
//   }

//   Future<void> connect(String mac) async {
//     if (connectingMac != null) return;

//     setState(() {
//       connectingMac = mac;
//       statusMessage = "Connecting...";
//     });

//     try {
//       if (connected) {
//         await PrintBluetoothThermal.disconnect;
//         await Future.delayed(const Duration(milliseconds: 500));
//       }

//       final success = await PrintBluetoothThermal.connect(
//         macPrinterAddress: mac,
//       ).timeout(const Duration(seconds: 10), onTimeout: () => false);

//       if (!success) throw Exception("Connection failed");

//       await Future.delayed(const Duration(milliseconds: 500));
//       final stillConnected = await PrintBluetoothThermal.connectionStatus;
//       if (!stillConnected) throw Exception("Lost connection");

//       await _saveConnectedMac(mac);
//       if (mounted) {
//         setState(() {
//           connected = true;
//           connectedMac = mac;
//           statusMessage = "Connected ";
//         });
//       }

//       // test printer
//       final profile = await CapabilityProfile.load();
//       final generator = Generator(PaperSize.mm80, profile);
//       await PrintBluetoothThermal.writeBytes(generator.reset());
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           connected = false;
//           connectedMac = null;
//           statusMessage = "Connection failed ";
//         });
//       }
//     } finally {
//       if (mounted) setState(() => connectingMac = null);
//     }
//   }

//   Future<void> disconnect() async {
//     try {
//       await PrintBluetoothThermal.disconnect;
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('connected_printer_mac');
//       if (mounted) {
//         setState(() {
//           connected = false;
//           connectedMac = null;
//           statusMessage = "Disconnected";
//         });
//       }
//     } catch (e) {
//       debugPrint("Disconnect error: $e");
//     }
//   }

//   Future<void> _saveConnectedMac(String mac) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('connected_printer_mac', mac);
//   }

//   Future<String?> _getStoredConnectedMac() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('connected_printer_mac');
//   }

//   Future<void> showPrintPreview({
//     required SaleDetail? detail,
//     required CompanyInformation? companyInfo,
//   }) async {
//     final l = LoadingOverlay.of(context);

//     if (detail == null || companyInfo == null) {
//       showErrorMessage("No data available to print");

//       return;
//     }

//     try {
//       l.show();
//       final receiptImage = await _createReceiptImage(
//         detail: detail,
//         companyInfo: companyInfo,
//       );

//       final pngBytes = img.encodePng(receiptImage);

//       if (!mounted) return;

//       l.hide();

//       showDialog(
//         context: context,
//         builder: (context) => Dialog(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: mainColor,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.receipt_long, color: white),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Receipt Preview',
//                       style: TextStyle(
//                         color: white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: white),
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                   ],
//                 ),
//               ),

//               // Preview Image (scrollable)
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(scaleFontSize(appSpace)),
//                   child: Image.memory(pngBytes, fit: BoxFit.contain),
//                 ),
//               ),

//               // Action Buttons
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(12),
//                     bottomRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: BtnWidget(
//                         onPressed: () => Navigator.of(context).pop(),
//                         title: greeting("Cancel"),
//                         bgColor: red,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: BtnWidget(
//                         onPressed: () async {
//                           Navigator.of(context).pop();
//                           await printReceipt(
//                             detail: detail,
//                             companyInfo: companyInfo,
//                           );
//                         },
//                         icon: Icon(Icons.print, color: white),
//                         title: greeting("Print"),
//                         bgColor: success,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       Navigator.of(context).pop(); // Close loading
//       showErrorMessage("Failed to generate preview: $e");
//     }
//   }

//   Future<void> printReceipt({
//     required SaleDetail? detail,
//     required CompanyInformation? companyInfo,
//   }) async {
//     // Navigator.push(
//     //   context,
//     //   // MaterialPageRoute(builder: (context) => ReceiptPrinterApp()),
//     //   MaterialPageRoute(
//     //     builder: (context) =>
//     //         ReceiptPreviewScreen(companyInfo: companyInfo, detail: detail),
//     //   ),
//     // );
//     // return;
//     try {
//       debugPrint(" Starting print job...");

//       bool isConnected = await PrintBluetoothThermal.connectionStatus;

//       if (!isConnected) {
//         debugPrint(" Printer not connected");
//         showErrorMessage("Printer not connected!");

//         if (connectedMac != null) {
//           debugPrint(" Attempting to reconnect...");
//           await connect(connectedMac!);
//           isConnected = await PrintBluetoothThermal.connectionStatus;
//           if (!isConnected) return;
//         } else {
//           return;
//         }
//       }
//       List<int> bytes = [];
//       final profile = await CapabilityProfile.load();
//       final generator = Generator(PaperSize.mm80, profile);

//       bytes += generator.reset();
//       debugPrint("Creating receipt image...");
//       final receiptImage = await _createReceiptImage(
//         detail: detail,
//         companyInfo: companyInfo,
//       );

//       debugPrint(" Converting to printer bytes...");
//       bytes += generator.imageRaster(receiptImage);
//       bytes += generator.cut();

//       debugPrint(" Sending ${bytes.length} bytes to printer...");

//       await _writeInChunks(bytes);
//       showSuccessMessage("Sending to Printer!");
//     } catch (e) {
//       debugPrint("Print error: $e");
//       showErrorMessage("Print failed: $e");
//     }
//   }

//   Future<img.Image> _createReceiptImage({
//     required SaleDetail? detail,
//     required CompanyInformation? companyInfo,
//   }) async {
//     const width = 576;

//     final textStyle = const TextStyle(
//       color: Colors.black,
//       fontSize: 20,
//       fontFamily: 'NotoSansKhmer',
//     );
//     final boldStyle = textStyle.copyWith(
//       fontWeight: FontWeight.bold,
//       fontSize: 22,
//     );
//     final headerStyle = textStyle.copyWith(
//       fontWeight: FontWeight.bold,
//       fontSize: 26,
//     );

//     // Helper to measure text height
//     double measureText(String text, TextStyle style, {double maxWidth = 536}) {
//       final span = TextSpan(text: text, style: style);
//       final painter = TextPainter(
//         text: span,
//         textDirection: TextDirection.ltr,
//         maxLines: 10,
//       );
//       painter.layout(maxWidth: maxWidth);
//       return painter.height;
//     }

//     // Helper to wrap text
//     List<String> wrapText(String text, TextStyle style, double maxWidth) {
//       final words = text.split(' ');
//       List<String> lines = [];
//       String currentLine = '';

//       final testPainter = TextPainter(
//         textDirection: TextDirection.ltr,
//         maxLines: 1,
//       );

//       for (var word in words) {
//         final testLine = currentLine.isEmpty ? word : '$currentLine $word';
//         testPainter.text = TextSpan(text: testLine, style: style);
//         testPainter.layout(maxWidth: maxWidth);

//         if (testPainter.didExceedMaxLines || testPainter.width > maxWidth) {
//           if (currentLine.isNotEmpty) lines.add(currentLine.trim());
//           currentLine = word;
//         } else {
//           currentLine = testLine;
//         }
//       }

//       if (currentLine.isNotEmpty) lines.add(currentLine.trim());
//       return lines;
//     }

//     // Load logo first
//     ui.Image? logoImage;
//     if (companyInfo?.logo128 != null && companyInfo!.logo128!.isNotEmpty) {
//       try {
//         if (companyInfo.logo128!.startsWith('http')) {
//           final response = await http.get(Uri.parse(companyInfo.logo128!));
//           if (response.statusCode == 200) {
//             final codec = await ui.instantiateImageCodec(response.bodyBytes);
//             final frame = await codec.getNextFrame();
//             logoImage = frame.image;
//           }
//         } else {
//           final bytes = base64Decode(companyInfo.logo128!);
//           final codec = await ui.instantiateImageCodec(bytes);
//           final frame = await codec.getNextFrame();
//           logoImage = frame.image;
//         }
//       } catch (e) {
//         debugPrint(" Failed to load logo: $e");
//       }
//     }

//     double y = 10;
//     if (logoImage != null) {
//       y += (logoImage.height / (logoImage.width / 200)) + 10;
//     }

//     y +=
//         measureText(
//           companyInfo?.name ?? "Company",
//           headerStyle.copyWith(fontSize: 30),
//         ) +
//         2;
//     y += measureText(companyInfo?.address ?? "Address", textStyle) + 2;
//     y += measureText("Email: ${companyInfo?.email ?? ''}", textStyle) + 5;
//     y += measureText("═" * 37, textStyle) + 3;
//     y +=
//         measureText(
//           "Customer: ${detail?.header.customerName ?? ''}",
//           textStyle,
//         ) +
//         2;
//     y +=
//         measureText(
//           "Date: ${detail?.header.documentDate ?? DateTime.now()}",
//           textStyle,
//         ) +
//         2;
//     y += measureText("Invoice No: ${detail?.header.no ?? ''}", textStyle) + 5;
//     y += measureText("─" * 37, textStyle) + 2;
//     y += 26;
//     y += measureText("─" * 37, textStyle) + 2;

//     for (var line in detail?.lines ?? []) {
//       final desc = line.description ?? "-";
//       final wrappedLines = wrapText(desc, textStyle, 180);
//       y += 26;
//       if (wrappedLines.length > 1) y += (wrappedLines.length - 1) * 24;
//     }

//     y += 5;
//     y += measureText("─" * 37, textStyle) + 2;
//     y += 26;
//     if (detail?.header.priceIncludeVat != null) y += 26;
//     y += 5;
//     y += measureText("═" * 37, textStyle) + 2;
//     y += 30;
//     y += measureText("═" * 37, textStyle) + 5;
//     y += measureText("សូមអរគុណ! Thank you for shopping!", boldStyle) + 2;
//     y +=
//         measureText(
//           "We look forward to serving you again! ❤️",
//           textStyle.copyWith(fontSize: 19),
//         ) +
//         2;
//     y +=
//         measureText(
//           "Powered by Blue Technology Co., Ltd.",
//           textStyle.copyWith(fontSize: 17),
//         ) +
//         10;

//     final height = y.toInt();

//     // Canvas setup
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);
//     final paint = Paint()..color = Colors.white;
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
//       paint,
//     );

//     y = 10;

//     // Draw logo
//     if (logoImage != null) {
//       final logoWidth = 200.0;
//       final logoHeight = logoImage.height * (logoWidth / logoImage.width);
//       final logoX = (width - logoWidth) / 2;
//       canvas.drawImageRect(
//         logoImage,
//         Rect.fromLTWH(
//           0,
//           0,
//           logoImage.width.toDouble(),
//           logoImage.height.toDouble(),
//         ),
//         Rect.fromLTWH(logoX, y, logoWidth, logoHeight),
//         Paint(),
//       );
//       y += logoHeight + 10;
//     }

//     // Draw helpers
//     void drawText(
//       String text,
//       TextStyle style, {
//       TextAlign align = TextAlign.left,
//       double spacing = 2,
//     }) {
//       final span = TextSpan(text: text, style: style);
//       final painter = TextPainter(
//         text: span,
//         textDirection: TextDirection.ltr,
//         textAlign: align,
//       );
//       painter.layout(maxWidth: width - 40);
//       double xOffset = 20;
//       if (align == TextAlign.center) {
//         xOffset = (width - painter.width) / 2;
//       } else if (align == TextAlign.right) {
//         xOffset = width - painter.width - 20;
//       }
//       painter.paint(canvas, Offset(xOffset, y));
//       y += painter.height + spacing;
//     }

//     void drawAlignedText(
//       String text,
//       double x,
//       double yPos,
//       double maxWidth,
//       TextStyle style,
//       TextAlign align,
//     ) {
//       final span = TextSpan(text: text, style: style);
//       final painter = TextPainter(
//         text: span,
//         textDirection: TextDirection.ltr,
//         textAlign: align,
//       );
//       painter.layout(maxWidth: maxWidth);

//       double xOffset = x;
//       if (align == TextAlign.right)
//         xOffset = x + maxWidth - painter.width;
//       else if (align == TextAlign.center)
//         xOffset = x + (maxWidth - painter.width) / 2;

//       painter.paint(canvas, Offset(xOffset, yPos));
//     }

//     // Draw content
//     drawText(
//       companyInfo?.name ?? "",
//       headerStyle.copyWith(fontSize: 30),
//       align: TextAlign.center,
//     );
//     drawText(companyInfo?.address ?? "", textStyle, align: TextAlign.center);
//     drawText(
//       "Email: ${companyInfo?.email ?? ''}",
//       textStyle,
//       align: TextAlign.center,
//       spacing: 5,
//     );
//     drawText("═" * 37, textStyle, spacing: 3);

//     drawText("Customer: ${detail?.header.customerName ?? ''}", textStyle);
//     drawText("Date: ${detail?.header.documentDate ?? ''}", textStyle);
//     drawText("Invoice No: ${detail?.header.no ?? ''}", textStyle, spacing: 5);
//     drawText("─" * 37, textStyle, spacing: 2);

//     final headerY = y;
//     drawAlignedText("#", 15, headerY, 25, boldStyle, TextAlign.left);
//     drawAlignedText("Description", 45, headerY, 180, boldStyle, TextAlign.left);
//     drawAlignedText("Qty", 230, headerY, 60, boldStyle, TextAlign.right);
//     drawAlignedText("Price", 280, headerY, 100, boldStyle, TextAlign.right);
//     drawAlignedText("Disc", 355, headerY, 100, boldStyle, TextAlign.right);
//     drawAlignedText("Amount", 420, headerY, 135, boldStyle, TextAlign.right);
//     y += 26;
//     drawText("─" * 37, textStyle, spacing: 2);

//     int itemNumber = 1;
//     for (var line in detail?.lines ?? []) {
//       final desc = line.description ?? "-";
//       final qty = Helpers.toInt(line.quantity).toString();
//       final price = Helpers.formatNumber(
//         line.unitPrice,
//         option: FormatType.amount,
//       );
//       final discount = Helpers.formatNumber(
//         line.discountAmount,
//         option: FormatType.amount,
//       );
//       final amount = Helpers.formatNumber(
//         line.amountIncludingVat,
//         option: FormatType.amount,
//       );

//       final rowY = y;
//       final wrappedLines = wrapText(desc, textStyle, 180);

//       drawAlignedText(
//         itemNumber.toString(),
//         15,
//         rowY,
//         25,
//         textStyle,
//         TextAlign.left,
//       );
//       for (int i = 0; i < wrappedLines.length; i++) {
//         final lineY = rowY + (i * 26);
//         drawAlignedText(
//           wrappedLines[i],
//           45,
//           lineY,
//           180,
//           textStyle,
//           TextAlign.left,
//         );
//       }

//       drawAlignedText(qty, 230, rowY, 60, textStyle, TextAlign.right);
//       drawAlignedText(price, 280, rowY, 100, textStyle, TextAlign.right);
//       drawAlignedText(discount, 355, rowY, 100, textStyle, TextAlign.right);
//       drawAlignedText(amount, 420, rowY, 135, textStyle, TextAlign.right);

//       y += 30;
//       if (wrappedLines.length > 1) y += (wrappedLines.length - 1) * 26;
//       itemNumber++;
//     }

//     y += 5;
//     drawText("─" * 37, textStyle, spacing: 2);

//     final total = detail?.header.amount ?? 0;

//     if (detail?.header.priceIncludeVat != null) {
//       drawAlignedText("Sub-Total:", 20, y, 200, textStyle, TextAlign.left);
//       drawAlignedText(
//         Helpers.formatNumber(
//           detail?.header.priceIncludeVat ?? 0,
//           option: FormatType.amount,
//         ),
//         420,
//         y,
//         135,
//         textStyle,
//         TextAlign.right,
//       );
//       y += 26;
//     }

//     y += 5;
//     drawText("═" * 37, textStyle, spacing: 2);

//     drawAlignedText(
//       "TOTAL:",
//       20,
//       y,
//       200,
//       boldStyle.copyWith(fontSize: 26),
//       TextAlign.left,
//     );
//     drawAlignedText(
//       Helpers.formatNumber(total, option: FormatType.amount),
//       420,
//       y,
//       135,
//       boldStyle.copyWith(fontSize: 26),
//       TextAlign.right,
//     );
//     y += 30;

//     drawText("═" * 37, textStyle, spacing: 5);

//     drawText(
//       "សូមអរគុណ! Thank you for shopping!",
//       boldStyle,
//       align: TextAlign.center,
//     );
//     drawText(
//       "We look forward to serving you again! ❤️",
//       textStyle.copyWith(fontSize: 19),
//       align: TextAlign.center,
//     );
//     drawText(
//       "Powered by Blue Technology Co., Ltd.",
//       textStyle.copyWith(fontSize: 17),
//       align: TextAlign.center,
//       spacing: 0,
//     );

//     final picture = recorder.endRecording();
//     final uiImage = await picture.toImage(width, height);
//     final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
//     final pngBytes = byteData!.buffer.asUint8List();

//     debugPrint("Receipt image created: ${width}x$height pixels");
//     return img.decodeImage(pngBytes)!;
//   }

//   Future<void> _writeInChunks(List<int> bytes) async {
//     const chunkSize = 1024; // 1KB chunks
//     for (int i = 0; i < bytes.length; i += chunkSize) {
//       final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
//       await PrintBluetoothThermal.writeBytes(bytes.sublist(i, end));
//       // await Future.delayed(Duration(milliseconds: 50));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBarWidget(
//         title: greeting(_getTitle()),
//         actions: [
//           BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
//             bloc: _cubit,
//             builder: (tx, state) {
//               final detail = state.record;
//               final company = state.comPanyInfo;
//               return BtnIconCircleWidget(
//                 onPressed: () =>
//                     showPrintPreview(detail: detail, companyInfo: company),
//                 icons: const Icon(Icons.print_rounded, color: white),
//                 rounded: appBtnRound,
//               );
//             },
//           ),
//           Helpers.gapW(appSpace),
//         ],
//       ),
//       body:
//           BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
//             bloc: _cubit,
//             builder: (context, state) {
//               if (state.isLoading) return const LoadingPageWidget();
//               final record = state.record;
//               return ListView(
//                 padding: const EdgeInsets.all(appSpace),
//                 children: [
//                   SaleHistoryDetailBox(
//                     header: record?.header,
//                     lines: record?.lines ?? [],
//                   ),
//                 ],
//               );
//             },
//           ),
//     );
//   }
// }
