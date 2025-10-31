import 'dart:async';
import 'dart:convert';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
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
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/khmer_font_helpers.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
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

  bool _connected = false;
  String? _connectedAddress;
  String _statusMessage = "";

  static const String _printerAddressKey = 'native_printer_address';

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializePrinter();
  }

  Future<void> _loadData() async {
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

  // ============================================================================
  // PRINTER CONNECTION METHODS
  // ============================================================================

  Future<void> _initializePrinter() async {
    try {
      final storedAddress = await _getStoredAddress();
      if (storedAddress == null) return;

      final isConnected = await NativeBluetoothPrinter.isConnected();
      if (isConnected) {
        _updateConnectionState(true, storedAddress, "Connected to printer");
        return;
      }

      final success = await NativeBluetoothPrinter.connect(storedAddress);
      if (success) {
        _updateConnectionState(true, storedAddress, "Reconnected to printer");
      }
    } catch (e) {
      debugPrint("⚠️ Printer initialization failed: $e");
    }
  }

  Future<void> _showDeviceSelector() async {
    _showLoadingDialog();

    final devices = await NativeBluetoothPrinter.scanDevices(timeout: 10);

    if (!mounted) return;
    Navigator.pop(context);

    if (devices.isEmpty) {
      showErrorMessage("No Bluetooth devices found");
      return;
    }

    final selectedDevice = await _showDeviceDialog(devices);
    if (selectedDevice != null && mounted) {
      await _connectToPrinter(selectedDevice);
    }
  }

  Future<BluetoothDevice?> _showDeviceDialog(
    List<BluetoothDevice> devices,
  ) async {
    return showDialog<BluetoothDevice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Printer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final isConnected = device.address == _connectedAddress;
              return ListTile(
                leading: Icon(
                  isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                  color: isConnected ? Colors.green : null,
                ),
                title: Text(device.name),
                subtitle: Text(device.address),
                trailing: isConnected
                    ? const Chip(
                        label: Text('Connected'),
                        backgroundColor: Colors.green,
                      )
                    : null,
                onTap: () => Navigator.pop(context, device),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToPrinter(BluetoothDevice device) async {
    setState(() => _statusMessage = "Connecting to ${device.name}...");

    final success = await NativeBluetoothPrinter.connect(device.address);

    if (success) {
      await _saveAddress(device.address);
      _updateConnectionState(
        true,
        device.address,
        "Connected to ${device.name}",
      );
      showSuccessMessage("Connected to ${device.name}");
    } else {
      _updateConnectionState(false, null, "Failed to connect");
      showErrorMessage("Failed to connect to ${device.name}");
    }
  }

  Future<void> _disconnect() async {
    await NativeBluetoothPrinter.disconnect();
    await _clearStoredAddress();
    _updateConnectionState(false, null, "Disconnected");
    showSuccessMessage("Printer disconnected");
  }

  void _updateConnectionState(bool connected, String? address, String message) {
    setState(() {
      _connected = connected;
      _connectedAddress = address;
      _statusMessage = message;
    });
  }

  Future<void> _saveAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_printerAddressKey, address);
  }

  Future<String?> _getStoredAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_printerAddressKey);
  }

  Future<void> _clearStoredAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_printerAddressKey);
  }

  // ============================================================================
  // PRINT PREVIEW & PRINTING
  // ============================================================================

  Future<void> _showPrintPreview({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    if (detail == null || companyInfo == null) {
      showErrorMessage("No data available to print");
      return;
    }

    final l = LoadingOverlay.of(context);

    try {
      l.show();
      final receiptImage = await _createReceiptImage(
        detail: detail,
        companyInfo: companyInfo,
      );
      final pngBytes = img.encodePng(receiptImage);

      if (!mounted) return;
      l.hide();

      await _showPreviewDialog(pngBytes, detail, companyInfo);
    } catch (e) {
      debugPrint("❌ Failed to generate preview: $e");
      if (!mounted) return;
      l.hide();
      showErrorMessage("Failed to generate preview: $e");
    }
  }

  Future<void> _showPreviewDialog(
    Uint8List pngBytes,
    SaleDetail detail,
    CompanyInformation companyInfo,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPreviewHeader(),
            _buildPreviewContent(pngBytes),
            _buildPreviewActions(detail, companyInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Container(
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
    );
  }

  Widget _buildPreviewContent(Uint8List pngBytes) {
    return Flexible(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(scaleFontSize(appSpace)),
        child: Image.memory(pngBytes, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildPreviewActions(
    SaleDetail detail,
    CompanyInformation companyInfo,
  ) {
    return Container(
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
                await _printReceipt(detail: detail, companyInfo: companyInfo);
              },
              icon: const Icon(Icons.print, color: white),
              title: greeting("Print"),
              bgColor: success,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReceipt({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    try {
      debugPrint("🖨️ Starting print job...");

      if (!await _ensurePrinterConnection()) return;

      final startTime = DateTime.now();

      final receiptImage = await _createReceiptImage(
        detail: detail,
        companyInfo: companyInfo,
      );

      final success = await NativeBluetoothPrinter.printImage(receiptImage);

      final totalTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint("🎉 Total print time: ${totalTime}ms");

      if (success) {
        showSuccessMessage("✓ Print successful!");
      } else {
        showErrorMessage("❌ Print failed");
      }
    } catch (e) {
      debugPrint("❌ Print error: $e");
      showErrorMessage("Print failed: $e");
    }
  }

  Future<bool> _ensurePrinterConnection() async {
    bool isConnected = await NativeBluetoothPrinter.isConnected();

    if (!isConnected && _connectedAddress != null) {
      debugPrint("🔄 Attempting to reconnect...");
      isConnected = await NativeBluetoothPrinter.connect(_connectedAddress!);
    }

    if (!isConnected) {
      showErrorMessage("Printer not connected. Please connect first.");
      _showDeviceSelector();
      return false;
    }

    return true;
  }

  // ============================================================================
  // RECEIPT IMAGE GENERATION
  // ============================================================================

  Future<img.Image> _createReceiptImage({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    const width = 384;
    final startTime = DateTime.now();

    // Render Khmer text
    final khmerImages = await _renderKhmerTexts(detail, companyInfo, width);

    // Load logo
    final logoImage = await _loadLogo(companyInfo);

    // Calculate height
    final totalHeight = _calculateReceiptHeight(
      detail,
      companyInfo,
      khmerImages,
      logoImage,
    );

    // Create canvas
    final finalImage = img.Image(width: width, height: totalHeight);
    img.fill(finalImage, color: img.ColorRgb8(255, 255, 255));

    // Draw content
    await _drawReceiptContent(
      finalImage,
      width,
      detail,
      companyInfo,
      khmerImages,
      logoImage,
    );

    debugPrint(
      "✓ Receipt built in ${DateTime.now().difference(startTime).inMilliseconds}ms",
    );

    return ImageProcessor.quickProcessForPrinting(finalImage);
  }

  Future<Map<String, img.Image>> _renderKhmerTexts(
    SaleDetail? detail,
    CompanyInformation? companyInfo,
    int width,
  ) async {
    final khmerConfigs = <String, KhmerTextConfig>{};

    // Company name
    if (_hasKhmer(companyInfo?.name)) {
      khmerConfigs['companyName'] = KhmerTextConfig(
        text: companyInfo!.name!,
        width: width.toDouble(),
        fontSize: 22,
      );
    }

    // Company address
    if (_hasKhmer(companyInfo?.address)) {
      khmerConfigs['companyAddress'] = KhmerTextConfig(
        text: companyInfo!.address!,
        width: width.toDouble(),
        fontSize: 16,
      );
    }

    // Customer name
    if (_hasKhmer(detail?.header.customerName)) {
      khmerConfigs['customerName'] = KhmerTextConfig(
        text: detail!.header.customerName!,
        width: (width - 80).toDouble(),
        fontSize: 16,
      );
    }

    // Product descriptions
    int lineIndex = 0;
    for (var line in detail?.lines ?? []) {
      if (_hasKhmer(line.description)) {
        khmerConfigs['product_$lineIndex'] = KhmerTextConfig(
          text: line.description!,
          width: 250.0,
          fontSize: 16,
        );
      }
      lineIndex++;
    }

    // Thank you message
    const thankYouMessage = 'សូមអរគុណ! Thank you for shopping!';
    if (KhmerPrinter.containsKhmer(thankYouMessage)) {
      khmerConfigs['thankYou'] = KhmerTextConfig(
        text: thankYouMessage,
        width: width.toDouble(),
        fontSize: 16,
      );
    }

    // Batch render
    try {
      return await KhmerPrinter.renderKhmerBatch(khmerConfigs);
    } catch (e) {
      debugPrint("⚠️ Batch render failed: $e");
      return {};
    }
  }

  bool _hasKhmer(String? text) {
    return text != null && text.isNotEmpty && KhmerPrinter.containsKhmer(text);
  }

  Future<img.Image?> _loadLogo(CompanyInformation? companyInfo) async {
    if (companyInfo?.logo128 == null || companyInfo!.logo128!.isEmpty) {
      return null;
    }

    try {
      img.Image? logoImage;

      if (companyInfo.logo128!.startsWith('http')) {
        final response = await http.get(Uri.parse(companyInfo.logo128!));
        if (response.statusCode == 200) {
          logoImage = img.decodeImage(response.bodyBytes);
        }
      } else {
        final bytes = base64Decode(companyInfo.logo128!);
        logoImage = img.decodeImage(bytes);
      }

      if (logoImage != null) {
        return img.copyResize(logoImage, width: 120);
      }
    } catch (e) {
      debugPrint("⚠️ Failed to load logo: $e");
    }

    return null;
  }

  int _calculateReceiptHeight(
    SaleDetail? detail,
    CompanyInformation? companyInfo,
    Map<String, img.Image> khmerImages,
    img.Image? logoImage,
  ) {
    int height = 20;

    // Logo
    if (logoImage != null) height += logoImage.height + 10;

    // Company info
    height += khmerImages.containsKey('companyName')
        ? khmerImages['companyName']!.height + 5
        : 30;
    height += khmerImages.containsKey('companyAddress')
        ? khmerImages['companyAddress']!.height + 5
        : 22;

    // Email
    if (companyInfo?.email?.isNotEmpty ?? false) height += 22;

    // Separator + Customer + Date + Invoice + Separator
    height += 25 + 25 + 22 + 22 + 25;

    // Table header + separator
    height += 24 + 25;

    // Product lines
    for (int i = 0; i < (detail?.lines.length ?? 0); i++) {
      height += 20; // Item number
      height += khmerImages.containsKey('product_$i')
          ? khmerImages['product_$i']!.height + 5
          : 22;
      height += 24; // Price row
    }

    // Separator + Subtotal + Separator + Total + Separator
    height += 25 + 24 + 25 + 28 + 25;

    // Thank you messages
    height += khmerImages.containsKey('thankYou')
        ? khmerImages['thankYou']!.height + 5
        : 22;
    height += 22 + 20 + 30;

    return height;
  }

  Future<void> _drawReceiptContent(
    img.Image canvas,
    int width,
    SaleDetail? detail,
    CompanyInformation? companyInfo,
    Map<String, img.Image> khmerImages,
    img.Image? logoImage,
  ) async {
    int currentY = 15;

    // Logo
    if (logoImage != null) {
      final x = (width - logoImage.width) ~/ 2;
      img.compositeImage(canvas, logoImage, dstX: x, dstY: currentY);
      currentY += logoImage.height + 10;
    }

    // Company name
    currentY = await _drawCompanyName(
      canvas,
      width,
      currentY,
      companyInfo,
      khmerImages,
    );

    // Company address
    currentY = await _drawCompanyAddress(
      canvas,
      width,
      currentY,
      companyInfo,
      khmerImages,
    );

    // Email
    if (companyInfo?.email?.isNotEmpty ?? false) {
      currentY = await _drawText(
        canvas,
        width,
        currentY,
        companyInfo!.email!,
        center: true,
        fontSize: 13,
      );
    }

    // Phone (from your image)
    if (companyInfo?.address?.isNotEmpty ?? false) {
      currentY = await _drawText(
        canvas,
        width,
        currentY,
        'Adress: ${companyInfo!.address}',
        center: true,
        fontSize: 13,
      );
    }

    // Separator
    currentY = await _drawText(
      canvas,
      width,
      currentY,
      '═' * 48,
      center: true,
      fontSize: 10,
    );

    // Customer
    currentY = await _drawCustomerInfo(
      canvas,
      width,
      currentY,
      detail,
      khmerImages,
    );

    // Date
    // currentY = await _drawText(
    //   canvas,
    //   width,
    //   currentY,
    //   'Date: ${_formatDate(detail?.header.documentDate)}',
    //   fontSize: 14,
    // );

    // Invoice number
    currentY = await _drawText(
      canvas,
      width,
      currentY,
      'Invoice No: ${detail?.header.no ?? 'N/A'}',
      fontSize: 14,
    );

    // Separator
    currentY = await _drawText(canvas, width, currentY, '─' * 48, fontSize: 10);

    // Table header
    currentY = await _drawTableHeader(canvas, width, currentY);

    // Separator
    currentY = await _drawText(canvas, width, currentY, '─' * 48, fontSize: 10);

    // Product lines
    currentY = await _drawProductLines(
      canvas,
      width,
      currentY,
      detail,
      khmerImages,
    );

    // Separator
    currentY = await _drawText(canvas, width, currentY, '─' * 48, fontSize: 10);

    // Subtotal
    if (detail?.header.priceIncludeVat != null) {
      currentY = await _drawTableRow(
        canvas,
        width,
        currentY,
        '',
        'Subtotal:',
        '',
        '',
        '',
        Helpers.formatNumber(
          detail!.header.priceIncludeVat ?? 0,
          option: FormatType.amount,
        ),
      );
    }

    // Discount (from your image)
    currentY = await _drawTableRow(
      canvas,
      width,
      currentY,
      '',
      'Discount:',
      '',
      '',
      '',
      '-\$No',
    );

    // Separator
    currentY = await _drawText(canvas, width, currentY, '═' * 48, fontSize: 10);

    // Total
    currentY = await _drawTableRow(
      canvas,
      width,
      currentY,
      '',
      'Total Amount:',
      '',
      '',
      '',
      Helpers.formatNumber(
        detail?.header.amount ?? 0,
        option: FormatType.amount,
      ),
      bold: true,
      fontSize: 16,
    );

    // Separator
    currentY = await _drawText(canvas, width, currentY, '═' * 48, fontSize: 10);

    // Thank you
    currentY = await _drawThankYou(canvas, width, currentY, khmerImages);

    currentY = await _drawText(
      canvas,
      width,
      currentY,
      'We look forward to serving you again! ❤️',
      center: true,
      fontSize: 13,
    );

    // Footer
    await _drawText(
      canvas,
      width,
      currentY,
      'Powered by Blue Technology Co., Ltd.',
      center: true,
      fontSize: 11,
    );
  }

  Future<int> _drawCompanyName(
    img.Image canvas,
    int width,
    int currentY,
    CompanyInformation? companyInfo,
    Map<String, img.Image> khmerImages,
  ) async {
    if (khmerImages.containsKey('companyName')) {
      final khmerImg = khmerImages['companyName']!;
      final x = (width - khmerImg.width) ~/ 2;
      img.compositeImage(canvas, khmerImg, dstX: x, dstY: currentY);
      return currentY + khmerImg.height + 5;
    } else if (companyInfo?.name?.isNotEmpty ?? false) {
      return await _drawText(
        canvas,
        width,
        currentY,
        companyInfo!.name!,
        bold: true,
        center: true,
        fontSize: 22,
      );
    }
    return currentY;
  }

  Future<int> _drawCompanyAddress(
    img.Image canvas,
    int width,
    int currentY,
    CompanyInformation? companyInfo,
    Map<String, img.Image> khmerImages,
  ) async {
    if (khmerImages.containsKey('companyAddress')) {
      final khmerImg = khmerImages['companyAddress']!;
      final x = (width - khmerImg.width) ~/ 2;
      img.compositeImage(canvas, khmerImg, dstX: x, dstY: currentY);
      return currentY + khmerImg.height + 5;
    } else if (companyInfo?.address?.isNotEmpty ?? false) {
      return await _drawText(
        canvas,
        width,
        currentY,
        companyInfo!.address!,
        center: true,
        fontSize: 14,
      );
    }
    return currentY;
  }

  Future<int> _drawCustomerInfo(
    img.Image canvas,
    int width,
    int currentY,
    SaleDetail? detail,
    Map<String, img.Image> khmerImages,
  ) async {
    if (khmerImages.containsKey('customerName')) {
      currentY = await _drawText(
        canvas,
        width,
        currentY,
        'Customer:',
        fontSize: 14,
      );
      img.compositeImage(
        canvas,
        khmerImages['customerName']!,
        dstX: 15,
        dstY: currentY,
      );
      return currentY + khmerImages['customerName']!.height + 5;
    } else if (detail?.header.customerName?.isNotEmpty ?? false) {
      return await _drawText(
        canvas,
        width,
        currentY,
        'Customer: ${detail!.header.customerName}',
        fontSize: 14,
      );
    }
    return currentY;
  }

  Future<int> _drawTableHeader(
    img.Image canvas,
    int width,
    int currentY,
  ) async {
    return await _drawTableRow(
      canvas,
      width,
      currentY,
      '#',
      'Description',
      'Qty',
      'Price',
      'Disc',
      'Amount',
      bold: true,
    );
  }

  Future<int> _drawProductLines(
    img.Image canvas,
    int width,
    int currentY,
    SaleDetail? detail,
    Map<String, img.Image> khmerImages,
  ) async {
    int itemNumber = 1;
    int lineIndex = 0;

    for (PosSalesLine line in detail?.lines ?? []) {
      // Item number and description on same line
      if (khmerImages.containsKey('product_$lineIndex')) {
        // If Khmer, draw number first, then Khmer text
        currentY = await _drawText(
          canvas,
          width,
          currentY,
          '$itemNumber  ',
          bold: true,
          fontSize: 15,
        );

        img.compositeImage(
          canvas,
          khmerImages['product_$lineIndex']!,
          dstX: 35,
          dstY: currentY - 5,
        );
        currentY += khmerImages['product_$lineIndex']!.height;
      } else {
        // Normal text - number and description on same line
        currentY = await _drawText(
          canvas,
          width,
          currentY,
          '$itemNumber  ${line.description ?? "-"}',
          bold: true,
          fontSize: 14,
        );
      }

      // Quantity, price, discount, and amount row
      final qty = Helpers.toInt(line.quantity).toString();
      final price = Helpers.formatNumber(
        line.unitPrice,
        option: FormatType.amount,
      );
      final disc = line.discountAmount != null && line.discountAmount! > 0
          ? Helpers.formatNumber(line.discountAmount, option: FormatType.amount)
          : '—';
      final amount = Helpers.formatNumber(
        line.amountIncludingVat,
        option: FormatType.amount,
      );

      currentY = await _drawTableRow(
        canvas,
        width,
        currentY,
        '',
        '',
        qty,
        price,
        disc,
        amount,
        fontSize: 14,
      );

      itemNumber++;
      lineIndex++;
    }

    return currentY;
  }

  Future<int> _drawThankYou(
    img.Image canvas,
    int width,
    int currentY,
    Map<String, img.Image> khmerImages,
  ) async {
    if (khmerImages.containsKey('thankYou')) {
      final khmerImg = khmerImages['thankYou']!;
      final x = (width - khmerImg.width) ~/ 2;
      img.compositeImage(canvas, khmerImg, dstX: x, dstY: currentY);
      return currentY + khmerImg.height + 5;
    } else {
      return await _drawText(
        canvas,
        width,
        currentY,
        'សូមអរគុណ! Thank you for shopping!',
        center: true,
        bold: true,
        fontSize: 16,
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return DateTime.now().toString().split('.')[0];
    return date.toString().split('.')[0];
  }

  // ============================================================================
  // DRAWING UTILITIES
  // ============================================================================

  Future<int> _drawText(
    img.Image canvas,
    int width,
    int currentY,
    String text, {
    bool bold = false,
    bool center = false,
    int fontSize = 16,
  }) async {
    final recorder = ui.PictureRecorder();
    final uiCanvas = Canvas(recorder);

    final style = TextStyle(
      color: Colors.black,
      fontSize: fontSize.toDouble(),
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontFamily: 'Roboto',
    );

    final span = TextSpan(text: text, style: style);
    final painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: center ? TextAlign.center : TextAlign.left,
    );
    painter.layout(maxWidth: width - 30);

    final textHeight = painter.height.toInt() + 8;
    uiCanvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), textHeight.toDouble()),
      Paint()..color = Colors.white,
    );

    double x = center ? (width - painter.width) / 2 : 15;
    painter.paint(uiCanvas, Offset(x, 4));

    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(width, textHeight);
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final textImg = img.decodeImage(pngBytes)!;

    img.compositeImage(canvas, textImg, dstY: currentY);
    return currentY + textHeight;
  }

  Future<int> _drawTableRow(
    img.Image canvas,
    int width,
    int currentY,
    String col1,
    String col2,
    String col3,
    String col4,
    String col5,
    String col6, {
    bool bold = false,
    int fontSize = 15,
  }) async {
    final recorder = ui.PictureRecorder();
    final uiCanvas = Canvas(recorder);

    const rowHeight = 24.0;
    uiCanvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), rowHeight),
      Paint()..color = Colors.white,
    );

    final style = TextStyle(
      color: Colors.black,
      fontSize: fontSize.toDouble(),
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontFamily: 'Roboto',
    );

    void drawCol(String text, double x, double w, TextAlign align) {
      if (text.isEmpty) return;

      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textAlign: align,
      );
      painter.layout(maxWidth: w);

      double xPos = x;
      if (align == TextAlign.right) {
        xPos = x + w - painter.width;
      } else if (align == TextAlign.center) {
        xPos = x + (w - painter.width) / 2;
      }

      painter.paint(uiCanvas, Offset(xPos, 4));
    }

    // Column positions optimized for 384px width with 6 columns
    // # | Description | Qty | Price | Disc | Amount
    drawCol(col1, 10, 25, TextAlign.left); // #
    drawCol(col2, 40, 120, TextAlign.left); // Description
    drawCol(col3, 165, 45, TextAlign.right); // Qty
    drawCol(col4, 215, 45, TextAlign.right); // Price
    drawCol(col5, 265, 45, TextAlign.right); // Disc
    drawCol(col6, 315, 60, TextAlign.right); // Amount

    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(width, rowHeight.toInt());
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final rowImg = img.decodeImage(pngBytes)!;

    img.compositeImage(canvas, rowImg, dstY: currentY);
    return currentY + rowHeight.toInt();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  // ============================================================================
  // UI BUILD METHODS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBarWidget(
      title: greeting(_getTitle()),
      actions: [
        if (_connected) _buildConnectionIndicator(),
        _buildBluetoothButton(),
        Helpers.gapW(8),
        _buildPrintButton(),
        Helpers.gapW(appSpace),
      ],
    );
  }

  Widget _buildConnectionIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bluetooth_connected, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text(
                'Connected',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBluetoothButton() {
    return BtnIconCircleWidget(
      onPressed: _connected ? _disconnect : _showDeviceSelector,
      icons: Icon(
        _connected ? Icons.bluetooth_connected : Icons.bluetooth,
        color: white,
      ),
      rounded: appBtnRound,
    );
  }

  Widget _buildPrintButton() {
    return BlocBuilder<
      SaleOrderHistoryDetailCubit,
      SaleOrderHistoryDetailState
    >(
      bloc: _cubit,
      builder: (context, state) {
        return BtnIconCircleWidget(
          onPressed: () => _showPrintPreview(
            detail: state.record,
            companyInfo: state.comPanyInfo,
          ),
          icons: const Icon(Icons.print_rounded, color: white),
          rounded: appBtnRound,
        );
      },
    );
  }

  Widget _buildBody() {
    return BlocBuilder<
      SaleOrderHistoryDetailCubit,
      SaleOrderHistoryDetailState
    >(
      bloc: _cubit,
      builder: (context, state) {
        if (state.isLoading) return const LoadingPageWidget();

        return ListView(
          padding: const EdgeInsets.all(appSpace),
          children: [
            if (_statusMessage.isNotEmpty) _buildStatusCard(),
            if (_statusMessage.isNotEmpty) const SizedBox(height: 8),
            SaleHistoryDetailBox(
              header: state.record?.header,
              lines: state.record?.lines ?? [],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _connected ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _connected ? Icons.check_circle : Icons.info,
              color: _connected ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _connected
                      ? Colors.green.shade900
                      : Colors.orange.shade900,
                ),
              ),
            ),
            if (!_connected)
              TextButton(
                onPressed: _showDeviceSelector,
                child: const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }
}
