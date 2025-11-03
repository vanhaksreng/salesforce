import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
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
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
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

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
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

      final isConnected = await ESCPOSPrinter.isConnected();
      if (isConnected) {
        _updateConnectionState(true, storedAddress, "Connected to printer");
        return;
      }

      final success = await ESCPOSPrinter.connect(storedAddress);
      if (success) {
        _updateConnectionState(true, storedAddress, "Reconnected to printer");
      }
    } catch (e) {
      debugPrint("⚠️ Printer initialization failed: $e");
    }
  }

  Future<void> _showDeviceSelector() async {
    _showLoadingDialog();
    final devices = await ESCPOSPrinter.scanDevices(timeout: 10);

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

    final success = await ESCPOSPrinter.connect(device.address);

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
    await ESCPOSPrinter.disconnect();
    await _clearStoredAddress();
    _updateConnectionState(false, null, "Disconnected");
    showSuccessMessage("Printer disconnected");
  }

  void _updateConnectionState(bool connected, String? address, String message) {
    if (mounted) {
      setState(() {
        _connected = connected;
        _connectedAddress = address;
        _statusMessage = message;
      });
    }
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
  // PREVIEW & PRINTING METHODS
  // ============================================================================

  Future<void> _showReceiptPreview({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptPreviewScreen(
          detail: detail,
          companyInfo: companyInfo,
          onPrint: _connected
              ? () => _printReceipt(detail: detail, companyInfo: companyInfo)
              : null,
        ),
      ),
    );
  }

  // ============================================================================
  // OPTIMIZED PRINTING WITH ESC/POS + KHMER IMAGES
  // ============================================================================

  Future<void> _printReceipt({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    try {
      debugPrint("🖨️ Starting hybrid print (ESC/POS + Khmer images)...");

      if (!await _ensurePrinterConnection()) return;

      final l = LoadingOverlay.of(context);
      l.show();

      final startTime = DateTime.now();

      // Build ESC/POS commands with Khmer image placeholders
      var escposData = <int>[];

      // Reset printer
      escposData.addAll([0x1B, 0x40]); // ESC @

      // Center alignment
      escposData.addAll([0x1B, 0x61, 0x01]); // ESC a 1

      // Logo (if exists)
      if (companyInfo?.logo128 != null && companyInfo!.logo128!.isNotEmpty) {
        final logoImage = await _loadLogoForPrinter(companyInfo.logo128!);
        if (logoImage != null) {
          final logoESCPOS = _imageToESCPOS(logoImage, width: 200);
          escposData.addAll(logoESCPOS);
          escposData.addAll([0x0A]); // Line feed
        }
      }

      // Company Name (check if Khmer)
      if (_hasKhmer(companyInfo?.name)) {
        final khmerImage = await KhmerPrinter.renderKhmerText(
          companyInfo!.name!,
          width: 384,
          fontSize: 22,
        );
        final khmerESCPOS = _imageToESCPOS(khmerImage, width: 384);
        escposData.addAll(khmerESCPOS);
        escposData.addAll([0x0A]);
      } else if (companyInfo?.name != null) {
        // Bold, large font
        escposData.addAll([0x1B, 0x45, 0x01]); // Bold on
        escposData.addAll([0x1D, 0x21, 0x11]); // Large font
        escposData.addAll(utf8.encode(companyInfo!.name!));
        escposData.addAll([0x0A]); // Line feed
        escposData.addAll([0x1B, 0x45, 0x00]); // Bold off
        escposData.addAll([0x1D, 0x21, 0x00]); // Normal font
      }

      // Company Address
      if (_hasKhmer(companyInfo?.address)) {
        final khmerImage = await KhmerPrinter.renderKhmerText(
          companyInfo!.address!,
          width: 384,
          fontSize: 14,
        );
        final khmerESCPOS = _imageToESCPOS(khmerImage, width: 384);
        escposData.addAll(khmerESCPOS);
        escposData.addAll([0x0A]);
      } else if (companyInfo?.address != null) {
        escposData.addAll(utf8.encode(companyInfo!.address!));
        escposData.addAll([0x0A]);
      }

      // Company Email
      if (companyInfo?.email != null && companyInfo!.email!.isNotEmpty) {
        escposData.addAll(utf8.encode(companyInfo.email!));
        escposData.addAll([0x0A]);
      }

      // Separator
      escposData.addAll([0x0A]);
      escposData.addAll(utf8.encode('=' * 48));
      escposData.addAll([0x0A]);

      // Left alignment for customer info
      escposData.addAll([0x1B, 0x61, 0x00]); // ESC a 0

      // Customer Name
      if (_hasKhmer(detail?.header.customerName)) {
        escposData.addAll(utf8.encode('Customer: '));
        escposData.addAll([0x0A]);
        final khmerImage = await KhmerPrinter.renderKhmerText(
          detail!.header.customerName!,
          width: 350,
          fontSize: 14,
        );
        final khmerESCPOS = _imageToESCPOS(khmerImage, width: 350);
        escposData.addAll(khmerESCPOS);
        escposData.addAll([0x0A]);
      } else if (detail?.header.customerName != null) {
        escposData.addAll(
          utf8.encode('Customer: ${detail!.header.customerName}'),
        );
        escposData.addAll([0x0A]);
      }

      // Invoice Number
      if (detail?.header.no != null) {
        escposData.addAll(utf8.encode('Invoice No: ${detail!.header.no}'));
        escposData.addAll([0x0A]);
      }

      // Date
      final date = detail?.header.documentDate != null
          ? detail!.header.documentDate!
          : '';
      if (date.isNotEmpty) {
        escposData.addAll(utf8.encode('Date: $date'));
        escposData.addAll([0x0A]);
      }

      // Separator
      escposData.addAll(utf8.encode('-' * 48));
      escposData.addAll([0x0A]);

      // Table Header
      escposData.addAll([0x1B, 0x45, 0x01]); // Bold on
      final header =
          '#'.padRight(3) +
          'Item'.padRight(20) +
          'Qty'.padLeft(5) +
          'Price'.padLeft(10) +
          'Total'.padLeft(10);
      escposData.addAll(utf8.encode(header));
      escposData.addAll([0x0A]);
      escposData.addAll([0x1B, 0x45, 0x00]); // Bold off
      escposData.addAll(utf8.encode('-' * 48));
      escposData.addAll([0x0A]);

      // Items
      // Replace the Items section in _printReceipt() method with this:

      // Items
      int itemNumber = 1;
      for (final line in detail?.lines ?? []) {
        String description = line.description ?? '';
        final qty = Helpers.toInt(line.quantity).toString();
        final price = Helpers.formatNumber(
          line.unitPrice,
          option: FormatType.amount,
        );
        final amount = Helpers.formatNumber(
          line.amountIncludingVat,
          option: FormatType.amount,
        );

        if (_hasKhmer(description)) {
          // KHMER: Render the ENTIRE LINE as an image (so Khmer aligns with numbers)
          escposData.addAll([0x1B, 0x61, 0x00]); // Left align

          // Build the full line text with Khmer
          final itemNum = '$itemNumber '.padRight(2);
          // Truncate or wrap long Khmer descriptions
          final descForDisplay = description.length > 18
              ? description.substring(0, 18)
              : description;
          final qtyStr = qty.padLeft(4);
          final priceStr = price.padLeft(7);
          final disc = '—'.padLeft(5);
          final totalStr = amount.padLeft(9);

          // Create full line: "# Description  Qty Price — Total"
          final fullLineText =
              '$itemNum$descForDisplay  $qtyStr$priceStr$disc$totalStr';

          final lineImage = await KhmerPrinter.renderKhmerText(
            fullLineText,
            width: 384,
            fontSize: 12,
            maxLines: 1,
          );
          final lineESCPOS = _imageToESCPOS(lineImage, width: 384);
          escposData.addAll(lineESCPOS);
          escposData.addAll([0x0A]);

          // If description was truncated or is long, show full description on next line
          if (description.length > 18) {
            escposData.addAll(utf8.encode('  '));
            final fullDescImage = await KhmerPrinter.renderKhmerText(
              description,
              width: 340,
              fontSize: 12,
              maxLines: 2,
            );
            final descESCPOS = _imageToESCPOS(fullDescImage, width: 340);
            escposData.addAll(descESCPOS);
            escposData.addAll([0x0A]);
          }
        } else {
          // ENGLISH: Standard text handling
          final itemNum = '$itemNumber '.padRight(2);

          if (description.length <= 15) {
            // Fits on one line
            final descStr = description.padRight(16);
            final qtyStr = qty.padLeft(4);
            final priceStr = price.padLeft(8);
            final disc = '—'.padLeft(6);
            final totalStr = amount.padLeft(10);

            final line = '$itemNum$descStr$qtyStr$priceStr$disc$totalStr';
            escposData.addAll(utf8.encode(line));
            escposData.addAll([0x0A]);
          } else {
            // Long description - print numbers first, wrap description below
            final qtyStr = qty.padLeft(4);
            final priceStr = price.padLeft(8);
            final disc = '—'.padLeft(6);
            final totalStr = amount.padLeft(10);

            final firstLine = '$itemNum$qtyStr$priceStr$disc$totalStr';
            escposData.addAll(utf8.encode(firstLine));
            escposData.addAll([0x0A]);

            // Wrap description
            final maxLineLength = 46;
            final words = description.split(' ');
            String currentLine = '  ';

            for (final word in words) {
              if ((currentLine.length + word.length + 1) <= maxLineLength) {
                currentLine += (currentLine.length > 2 ? ' ' : '') + word;
              } else {
                escposData.addAll(utf8.encode(currentLine));
                escposData.addAll([0x0A]);
                currentLine = '  $word';
              }
            }

            if (currentLine.trim().isNotEmpty) {
              escposData.addAll(utf8.encode(currentLine));
              escposData.addAll([0x0A]);
            }
          }
        }

        itemNumber++;
      }

      // Separator
      escposData.addAll(utf8.encode('-' * 48));
      escposData.addAll([0x0A]);

      // Right alignment for totals
      escposData.addAll([0x1B, 0x61, 0x02]); // ESC a 2

      // Subtotal
      if (detail?.header.priceIncludeVat != null) {
        final subtotal =
            'Subtotal: ${Helpers.formatNumber(detail!.header.priceIncludeVat!, option: FormatType.amount)}';
        escposData.addAll(utf8.encode(subtotal));
        escposData.addAll([0x0A]);
      }

      // Discount
      final discountAmount = detail?.header.amount ?? 0;
      final discountText = discountAmount > 0
          ? 'Discount: -${Helpers.formatNumber(discountAmount, option: FormatType.amount)}'
          : 'Discount: \$0.00';
      escposData.addAll(utf8.encode(discountText));
      escposData.addAll([0x0A]);

      // VAT (if applicable)
      if (detail?.header.amount != null && detail!.header.amount! > 0) {
        final vat =
            'VAT: ${Helpers.formatNumber(detail.header.amount!, option: FormatType.amount)}';
        escposData.addAll(utf8.encode(vat));
        escposData.addAll([0x0A]);
      }

      // Separator
      escposData.addAll(utf8.encode('=' * 48));
      escposData.addAll([0x0A]);

      // Total (bold, large)
      escposData.addAll([0x1B, 0x45, 0x01]); // Bold on
      escposData.addAll([0x1D, 0x21, 0x10]); // Wide font
      final total =
          'TOTAL: ${Helpers.formatNumber(detail?.header.amount ?? 0, option: FormatType.amount)}';
      escposData.addAll(utf8.encode(total));
      escposData.addAll([0x0A]);
      escposData.addAll([0x1B, 0x45, 0x00]); // Bold off
      escposData.addAll([0x1D, 0x21, 0x00]); // Normal font

      // Separator
      escposData.addAll(utf8.encode('=' * 48));
      escposData.addAll([0x0A, 0x0A]);

      // Center alignment for footer
      escposData.addAll([0x1B, 0x61, 0x01]); // ESC a 1

      // Thank you message (check if Khmer)
      const thankYouMessage =
          'សូមអរគុណSamsung មួយទឹក មានធានា០១ឆ្នាំដំបូងគេ​នៅកម្ពុជា!------------- Thank you!';
      if (_hasKhmer(thankYouMessage)) {
        final khmerImage = await KhmerPrinter.renderKhmerText(
          thankYouMessage,
          width: 384,
          fontSize: 16,
        );
        final khmerESCPOS = _imageToESCPOS(khmerImage, width: 384);
        escposData.addAll(khmerESCPOS);
        escposData.addAll([0x0A]);
      } else {
        escposData.addAll(utf8.encode(thankYouMessage));
        escposData.addAll([0x0A]);
      }

      escposData.addAll(utf8.encode('We look forward to serving you again!'));
      escposData.addAll([0x0A, 0x0A]);

      escposData.addAll(utf8.encode('Powered by Blue Technology Co., Ltd.'));
      escposData.addAll([0x0A]);

      // Feed and cut
      escposData.addAll([0x1B, 0x64, 0x03]); // Feed 3 lines
      escposData.addAll([0x1D, 0x56, 0x00]); // Cut paper

      // Send to printer
      final success = await ESCPOSPrinter.printRaw(
        Uint8List.fromList(escposData),
      );

      final totalTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint("🎉 Total print time: ${totalTime}ms");

      l.hide();

      if (success) {
        showSuccessMessage("✓ Print successful!");
      } else {
        showErrorMessage("✗ Print failed");
      }
    } catch (e) {
      debugPrint("❌ Print error: $e");
      if (mounted) {
        LoadingOverlay.of(context).hide();
      }
      showErrorMessage("Print failed: $e");
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  bool _hasKhmer(String? text) {
    if (text == null || text.isEmpty) return false;
    return KhmerPrinter.containsKhmer(text);
  }

  Future<bool> _ensurePrinterConnection() async {
    bool isConnected = await ESCPOSPrinter.isConnected();

    if (!isConnected && _connectedAddress != null) {
      debugPrint("🔄 Attempting to reconnect...");
      isConnected = await ESCPOSPrinter.connect(_connectedAddress!);
    }

    if (!isConnected) {
      showErrorMessage("Printer not connected. Please connect first.");
      _showDeviceSelector();
      return false;
    }

    return true;
  }

  Future<img.Image?> _loadLogoForPrinter(String logo) async {
    try {
      img.Image? logoImage;
      if (logo.startsWith('http')) {
        final response = await http.get(Uri.parse(logo));
        if (response.statusCode == 200) {
          logoImage = img.decodeImage(response.bodyBytes);
        }
      } else {
        final bytes = base64Decode(logo);
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

  List<int> _imageToESCPOS(img.Image image, {int width = 384}) {
    final resized = img.copyResize(image, width: width);
    final imageWidth = resized.width;
    final imageHeight = resized.height;
    final widthBytes = (imageWidth + 7) ~/ 8;

    // Convert to monochrome bitmap
    final bitmap = <int>[];
    for (int y = 0; y < imageHeight; y++) {
      for (int x = 0; x < widthBytes; x++) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          final px = x * 8 + bit;
          if (px < imageWidth) {
            final pixel = resized.getPixel(px, y);
            final luminance = pixel.r.toInt();
            if (luminance < 128) {
              byte |= (1 << (7 - bit));
            }
          }
        }
        bitmap.add(byte);
      }
    }

    // Build ESC/POS command
    final escpos = <int>[];
    escpos.addAll([0x1D, 0x76, 0x30, 0x00]); // GS v 0
    escpos.add(widthBytes & 0xFF);
    escpos.add((widthBytes >> 8) & 0xFF);
    escpos.add(imageHeight & 0xFF);
    escpos.add((imageHeight >> 8) & 0xFF);
    escpos.addAll(bitmap);

    return escpos;
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
          onPressed: () => _showReceiptPreview(
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

// ============================================================================
// RECEIPT PREVIEW SCREEN - MATCHES PRINTED RECEIPT EXACTLY
// ============================================================================

class ReceiptPreviewScreen extends StatelessWidget {
  final SaleDetail? detail;
  final CompanyInformation? companyInfo;
  final VoidCallback? onPrint;

  const ReceiptPreviewScreen({
    super.key,
    required this.detail,
    required this.companyInfo,
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Preview'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (onPrint != null)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: onPrint,
              tooltip: 'Print Receipt',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Print Status
            if (onPrint != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Printer is connected and ready',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (onPrint != null) const SizedBox(height: 8),

            // Receipt Preview - EXACT MATCH to printed receipt
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 384),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: _buildReceiptContent(),
            ),

            // Action Buttons
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo
        _buildLogo(),

        // Company Name - CENTERED like printed receipt
        if (companyInfo?.name != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Text(
              companyInfo!.name!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Company Address - CENTERED
        if (companyInfo?.address != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              companyInfo!.address!,
              style: const TextStyle(fontSize: 12, height: 1.1),
              textAlign: TextAlign.center,
            ),
          ),

        // Company Email - CENTERED
        if (companyInfo?.email != null && companyInfo!.email!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              companyInfo!.email!,
              style: const TextStyle(fontSize: 12, height: 1.1),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 8),
        _buildSeparator('='), // Same as printed receipt
        const SizedBox(height: 8),

        // Customer Info - LEFT ALIGNED
        if (detail?.header.customerName != null)
          _buildReceiptRow(
            'Customer:',
            detail!.header.customerName!,
            alignRight: false,
            fontSize: 12,
          ),

        if (detail?.header.no != null)
          _buildReceiptRow(
            'Invoice No:',
            detail!.header.no!,
            alignRight: false,
            fontSize: 12,
          ),

        if (detail?.header.documentDate != null)
          _buildReceiptRow(
            'Date:',
            detail!.header.documentDate!,
            alignRight: false,
            fontSize: 12,
          ),

        const SizedBox(height: 6),
        _buildSeparator('-'), // Same as printed receipt
        const SizedBox(height: 6),

        // Table Header - EXACT MATCH to printed format
        _buildTableHeader(),

        const SizedBox(height: 4),
        _buildSeparator('-'),
        const SizedBox(height: 4),

        // Items - EXACT MATCH to printed format
        ..._buildItemRows(),

        const SizedBox(height: 6),
        _buildSeparator('-'),
        const SizedBox(height: 6),

        // Totals - RIGHT ALIGNED like printed receipt
        if (detail?.header.priceIncludeVat != null)
          _buildReceiptRow(
            'Subtotal:',
            Helpers.formatNumber(
              detail!.header.priceIncludeVat!,
              option: FormatType.amount,
            ),
            alignRight: true,
            fontSize: 12,
          ),

        _buildReceiptRow(
          'Discount:',
          detail?.header.amount != null && detail!.header.amount! > 0
              ? '-${Helpers.formatNumber(detail!.header.amount!, option: FormatType.amount)}'
              : '\$0.00',
          alignRight: true,
          fontSize: 12,
        ),

        if (detail?.header.amount != null && detail!.header.amount! > 0)
          _buildReceiptRow(
            'VAT:',
            Helpers.formatNumber(
              detail!.header.amount!,
              option: FormatType.amount,
            ),
            alignRight: true,
            fontSize: 12,
          ),

        const SizedBox(height: 4),
        _buildSeparator('='),
        const SizedBox(height: 4),

        // Total - BOLD and LARGER like printed receipt
        _buildReceiptRow(
          'TOTAL:',
          Helpers.formatNumber(
            detail?.header.amount ?? 0,
            option: FormatType.amount,
          ),
          alignRight: true,
          isTotal: true,
          fontSize: 14,
        ),

        const SizedBox(height: 4),
        _buildSeparator('='),
        const SizedBox(height: 8),

        // Footer - CENTERED like printed receipt
        const Text(
          'សូមអរគុណSamsung មួយទឹក មានធានា០១ឆ្នាំដំបូងគេ​នៅកម្ពុជា!------------- Thank you!',
          style: TextStyle(fontSize: 12, height: 1.1),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'We look forward to serving you again!',
          style: TextStyle(fontSize: 10, height: 1.1),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'Powered by Blue Technology Co., Ltd.',
          style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.1),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLogo() {
    if (companyInfo?.logo128 == null || companyInfo!.logo128!.isEmpty) {
      return const SizedBox(height: 8);
    }

    try {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: Image.memory(
          base64Decode(companyInfo!.logo128!),
          width: 60, // Smaller like printed receipt
          height: 60,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(height: 8);
          },
        ),
      );
    } catch (e) {
      return const SizedBox(height: 8);
    }
  }

  Widget _buildSeparator(String character) {
    return Text(
      character * 48, // Same width as printed receipt
      style: const TextStyle(fontSize: 10, letterSpacing: 0.5),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTableHeader() {
    return const Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '#  ',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 20,
          child: Text(
            'Item',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            'Qty',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          flex: 10,
          child: Text(
            'Price',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          flex: 10,
          child: Text(
            'Total',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildItemRows() {
    final List<Widget> rows = [];
    int itemNumber = 1;

    for (final line in detail?.lines ?? []) {
      final description = line.description ?? '';
      final qty = Helpers.toInt(line.quantity).toString();
      final price = Helpers.formatNumber(
        line.unitPrice,
        option: FormatType.amount,
      );
      final amount = Helpers.formatNumber(
        line.amountIncludingVat,
        option: FormatType.amount,
      );

      // Check if description fits on one line with number
      final descriptionFitsOneLine = description.length <= 15;

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main row with numbers (and short description if it fits)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Item number
                  SizedBox(
                    width: 15,
                    child: Text(
                      '$itemNumber',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Description column (only if short enough)
                  if (descriptionFitsOneLine)
                    SizedBox(
                      width: 100,
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 10),
                      ),
                    )
                  else
                    const SizedBox(width: 100), // Empty space if long desc
                  // Quantity
                  SizedBox(
                    width: 35,
                    child: Text(
                      qty,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  // Price
                  SizedBox(
                    width: 60,
                    child: Text(
                      price,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  // Disc
                  SizedBox(
                    width: 40,
                    child: Text(
                      '—',
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Amount
                  Expanded(
                    child: Text(
                      amount,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Long description on next line(s) if needed
              if (!descriptionFitsOneLine)
                Padding(
                  padding: const EdgeInsets.only(left: 2, top: 1),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 10, height: 1.2),
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                  ),
                ),
            ],
          ),
        ),
      );

      itemNumber++;
    }

    return rows;
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool alignRight = true,
    bool isTotal = false,
    double fontSize = 12,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: alignRight ? TextAlign.left : TextAlign.left,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back'),
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black87,
          ),
        ),
        if (onPrint != null)
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Print Receipt'),
            onPressed: onPrint,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}

// ==================== ESC/POS PRINTER CLASS ====================
class ESCPOSPrinter {
  static const MethodChannel _channel = MethodChannel(
    'native_bluetooth_printer',
  );

  static Future<List<BluetoothDevice>> scanDevices({int timeout = 10}) async {
    try {
      debugPrint("🔍 Scanning for Bluetooth devices...");
      final List<dynamic>? devices = await _channel.invokeMethod(
        'scanDevices',
        {'timeout': timeout},
      );

      if (devices == null) return [];

      return devices.map((device) {
        return BluetoothDevice(
          name: device['name'] ?? 'Unknown',
          address: device['address'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint("❌ Error scanning devices: $e");
      return [];
    }
  }

  static Future<bool> connect(String address) async {
    try {
      debugPrint("🔗 Connecting to device: $address");
      final bool? result = await _channel.invokeMethod('connect', {
        'address': address,
      });
      return result ?? false;
    } catch (e) {
      debugPrint("❌ Error connecting: $e");
      return false;
    }
  }

  static Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
      debugPrint("🔌 Disconnected from printer");
    } catch (e) {
      debugPrint("❌ Error disconnecting: $e");
    }
  }

  static Future<bool> isConnected() async {
    try {
      final bool? result = await _channel.invokeMethod('isConnected');
      return result ?? false;
    } catch (e) {
      debugPrint("❌ Error checking connection: $e");
      return false;
    }
  }

  static Future<bool> printRaw(Uint8List data) async {
    try {
      final bool? result = await _channel.invokeMethod('printRaw', {
        'data': data,
      });
      return result ?? false;
    } catch (e) {
      debugPrint("❌ Error printing raw data: $e");
      return false;
    }
  }
}

class BluetoothDevice {
  final String name;
  final String address;

  BluetoothDevice({required this.name, required this.address});

  @override
  String toString() => 'BluetoothDevice(name: $name, address: $address)';
}

// ==================== KHMER PRINTER CLASS ====================
class KhmerPrinter {
  static const MethodChannel _channel = MethodChannel('khmer_text_renderer');

  static Future<img.Image> renderKhmerText(
    String text, {
    double width = 384,
    double fontSize = 36,
    int maxLines = 1,
    bool useCache = true,
  }) async {
    try {
      final Uint8List? result = await _channel.invokeMethod('renderText', {
        'text': text,
        'width': width,
        'fontSize': fontSize,
        'maxLines': maxLines,
        'useCache': useCache,
      });

      if (result == null) {
        throw Exception('Failed to render Khmer text');
      }

      final image = img.decodeImage(result);
      if (image == null) {
        throw Exception('Failed to decode rendered image');
      }

      return image;
    } catch (e) {
      debugPrint('Error rendering Khmer text: $e');
      rethrow;
    }
  }

  static Future<Map<String, img.Image>> renderKhmerBatch(
    Map<String, KhmerTextConfig> configs,
  ) async {
    if (configs.isEmpty) return {};

    try {
      final startTime = DateTime.now();

      final texts = configs.keys.toList();
      final textValues = configs.values.map((c) => c.text).toList();
      final widths = configs.values.map((c) => c.width).toList();
      final fontSizes = configs.values.map((c) => c.fontSize).toList();
      final maxLines = configs.values.map((c) => c.maxLines).toList();

      debugPrint("📤 Batch rendering ${texts.length} Khmer texts...");

      final List<dynamic>? results = await _channel
          .invokeMethod('renderTextBatch', {
            'texts': textValues,
            'widths': widths,
            'fontSizes': fontSizes,
            'maxLines': maxLines,
          });

      if (results == null) {
        throw Exception('Failed to batch render Khmer text');
      }

      final Map<String, img.Image> renderedImages = {};

      for (int i = 0; i < texts.length; i++) {
        if (results[i] != null && results[i] is Uint8List) {
          final image = img.decodeImage(results[i] as Uint8List);
          if (image != null) {
            renderedImages[texts[i]] = image;
          }
        }
      }

      final batchTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint(
        "✅ Batch rendered ${renderedImages.length} texts in ${batchTime}ms",
      );

      return renderedImages;
    } catch (e) {
      debugPrint('Error batch rendering Khmer text: $e');
      return {};
    }
  }

  static Future<void> clearCache() async {
    try {
      await _channel.invokeMethod('clearCache');
      debugPrint('✅ Khmer render cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  static bool containsKhmer(String text) {
    return text.contains(RegExp(r'[\u1780-\u17FF]'));
  }
}

class KhmerTextConfig {
  final String text;
  final double width;
  final double fontSize;
  final int maxLines;

  KhmerTextConfig({
    required this.text,
    this.width = 384,
    this.fontSize = 24,
    this.maxLines = 1,
  });
}

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as img;
// import 'package:salesforce/core/constants/app_styles.dart';
// import 'package:salesforce/core/enums/enums.dart';
// import 'package:salesforce/core/mixins/message_mixin.dart';
// import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
// import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
// import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
// import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
// import 'package:salesforce/core/utils/helpers.dart';
// import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
// import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
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
//   bool _connected = false;
//   String? _connectedAddress;
//   String _statusMessage = "";
//   static const String _printerAddressKey = 'native_printer_address';

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     _initializePrinter();
//   }

//   @override
//   void dispose() {
//     _cubit.close();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
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

//   // ============================================================================
//   // PRINTER CONNECTION METHODS
//   // ============================================================================

//   Future<void> _initializePrinter() async {
//     try {
//       final storedAddress = await _getStoredAddress();
//       if (storedAddress == null) return;

//       final isConnected = await ESCPOSPrinter.isConnected();
//       if (isConnected) {
//         _updateConnectionState(true, storedAddress, "Connected to printer");
//         return;
//       }

//       final success = await ESCPOSPrinter.connect(storedAddress);
//       if (success) {
//         _updateConnectionState(true, storedAddress, "Reconnected to printer");
//       }
//     } catch (e) {
//       debugPrint("⚠️ Printer initialization failed: $e");
//     }
//   }

//   Future<void> _showDeviceSelector() async {
//     _showLoadingDialog();
//     final devices = await ESCPOSPrinter.scanDevices(timeout: 10);

//     if (!mounted) return;
//     Navigator.pop(context);

//     if (devices.isEmpty) {
//       showErrorMessage("No Bluetooth devices found");
//       return;
//     }

//     final selectedDevice = await _showDeviceDialog(devices);
//     if (selectedDevice != null && mounted) {
//       await _connectToPrinter(selectedDevice);
//     }
//   }

//   Future<BluetoothDevice?> _showDeviceDialog(
//     List<BluetoothDevice> devices,
//   ) async {
//     return showDialog<BluetoothDevice>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Printer'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: devices.length,
//             itemBuilder: (context, index) {
//               final device = devices[index];
//               final isConnected = device.address == _connectedAddress;
//               return ListTile(
//                 leading: Icon(
//                   isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
//                   color: isConnected ? Colors.green : null,
//                 ),
//                 title: Text(device.name),
//                 subtitle: Text(device.address),
//                 trailing: isConnected
//                     ? const Chip(
//                         label: Text('Connected'),
//                         backgroundColor: Colors.green,
//                       )
//                     : null,
//                 onTap: () => Navigator.pop(context, device),
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _connectToPrinter(BluetoothDevice device) async {
//     setState(() => _statusMessage = "Connecting to ${device.name}...");

//     final success = await ESCPOSPrinter.connect(device.address);

//     if (success) {
//       await _saveAddress(device.address);
//       _updateConnectionState(
//         true,
//         device.address,
//         "Connected to ${device.name}",
//       );
//       showSuccessMessage("Connected to ${device.name}");
//     } else {
//       _updateConnectionState(false, null, "Failed to connect");
//       showErrorMessage("Failed to connect to ${device.name}");
//     }
//   }

//   Future<void> _disconnect() async {
//     await ESCPOSPrinter.disconnect();
//     await _clearStoredAddress();
//     _updateConnectionState(false, null, "Disconnected");
//     showSuccessMessage("Printer disconnected");
//   }

//   void _updateConnectionState(bool connected, String? address, String message) {
//     if (mounted) {
//       setState(() {
//         _connected = connected;
//         _connectedAddress = address;
//         _statusMessage = message;
//       });
//     }
//   }

//   Future<void> _saveAddress(String address) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_printerAddressKey, address);
//   }

//   Future<String?> _getStoredAddress() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_printerAddressKey);
//   }

//   Future<void> _clearStoredAddress() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_printerAddressKey);
//   }

//   // ============================================================================
//   // OPTIMIZED PRINTING WITH ESC/POS + KHMER IMAGES
//   // ============================================================================

//   Future<void> _printReceipt({
//     required SaleDetail? detail,
//     required CompanyInformation? companyInfo,
//   }) async {
//     try {
//       debugPrint("🖨️ Starting hybrid print (ESC/POS + Khmer images)...");

//       if (!await _ensurePrinterConnection()) return;

//       final l = LoadingOverlay.of(context);
//       l.show();

//       final startTime = DateTime.now();

//       // Build ESC/POS commands with Khmer image placeholders
//       var escposData = <int>[];

//       // Reset printer
//       escposData.addAll([0x1B, 0x40]); // ESC @

//       // Center alignment
//       escposData.addAll([0x1B, 0x61, 0x01]); // ESC a 1

//       // Logo (if exists)
//       if (companyInfo?.logo128 != null && companyInfo!.logo128!.isNotEmpty) {
//         final logoImage = await _loadLogoForPrinter(companyInfo.logo128!);
//         if (logoImage != null) {
//           final logoESCPOS = _imageToESCPOS(logoImage, width: 200);
//           escposData.addAll(logoESCPOS);
//           escposData.addAll([0x0A]); // Line feed
//         }
//       }

//       // Company Name (check if Khmer)
//       if (_hasKhmer(companyInfo?.name)) {
//         final khmerImage = await KhmerPrinter.renderKhmerText(
//           companyInfo!.name!,
//           width: 384,
//           fontSize: 22,
//         );
//         final khmerESCPOS = _imageToESCPOS(khmerImage, width: 384);
//         escposData.addAll(khmerESCPOS);
//         escposData.addAll([0x0A]);
//       } else if (companyInfo?.name != null) {
//         // Bold, large font
//         escposData.addAll([0x1B, 0x45, 0x01]); // Bold on
//         escposData.addAll([0x1D, 0x21, 0x11]); // Large font
//         escposData.addAll(utf8.encode(companyInfo!.name!));
//         escposData.addAll([0x0A]); // Line feed
//         escposData.addAll([0x1B, 0x45, 0x00]); // Bold off
//         escposData.addAll([0x1D, 0x21, 0x00]); // Normal font
//       }

//       // Company Address
//       if (_hasKhmer(companyInfo?.address)) {
//         final khmerImage = await KhmerPrinter.renderKhmerText(
//           companyInfo!.address!,
//           width: 384,
//           fontSize: 14,
//         );
//         final khmerESCPOS = _imageToESCPOS(khmerImage, width: 384);
//         escposData.addAll(khmerESCPOS);
//         escposData.addAll([0x0A]);
//       } else if (companyInfo?.address != null) {
//         escposData.addAll(utf8.encode(companyInfo!.address!));
//         escposData.addAll([0x0A]);
//       }

//       // Company Email
//       if (companyInfo?.email != null && companyInfo!.email!.isNotEmpty) {
//         escposData.addAll(utf8.encode(companyInfo.email!));
//         escposData.addAll([0x0A]);
//       }

//       // Separator
//       escposData.addAll([0x0A]);
//       escposData.addAll(utf8.encode('=' * 48));
//       escposData.addAll([0x0A]);

//       // Left alignment for customer info
//       escposData.addAll([0x1B, 0x61, 0x00]); // ESC a 0

//       // Customer Name
//       if (_hasKhmer(detail?.header.customerName)) {
//         escposData.addAll(utf8.encode('Customer: '));
//         escposData.addAll([0x0A]);
//         final khmerImage = await KhmerPrinter.renderKhmerText(
//           detail!.header.customerName!,
//           width: 350,
//           fontSize: 14,
//         );
//         final khmerESCPOS = _imageToESCPOS(khmerImage, width: 350);
//         escposData.addAll(khmerESCPOS);
//         escposData.addAll([0x0A]);
//       } else if (detail?.header.customerName != null) {
//         escposData.addAll(
//           utf8.encode('Customer: ${detail!.header.customerName}'),
//         );
//         escposData.addAll([0x0A]);
//       }

//       // Invoice Number
//       if (detail?.header.no != null) {
//         escposData.addAll(utf8.encode('Invoice No: ${detail!.header.no}'));
//         escposData.addAll([0x0A]);
//       }

//       // Date
//       final date = detail?.header.documentDate != null
//           ? detail!.header.documentDate!
//           : '';
//       if (date.isNotEmpty) {
//         escposData.addAll(utf8.encode('Date: $date'));
//         escposData.addAll([0x0A]);
//       }

//       // Separator
//       escposData.addAll(utf8.encode('-' * 48));
//       escposData.addAll([0x0A]);

//       // Table Header
//       escposData.addAll([0x1B, 0x45, 0x01]); // Bold on
//       final header =
//           '#'.padRight(3) +
//           'Item'.padRight(20) +
//           'Qty'.padLeft(5) +
//           'Price'.padLeft(10) +
//           'Total'.padLeft(10);
//       escposData.addAll(utf8.encode(header));
//       escposData.addAll([0x0A]);
//       escposData.addAll([0x1B, 0x45, 0x00]); // Bold off
//       escposData.addAll(utf8.encode('-' * 48));
//       escposData.addAll([0x0A]);

//       // Items
//       // Items
//       int itemNumber = 1;
//       for (final line in detail?.lines ?? []) {
//         String description = line.description ?? '';
//         final qty = Helpers.toInt(line.quantity).toString().padLeft(5);
//         final price = Helpers.formatNumber(
//           line.unitPrice,
//           option: FormatType.amount,
//         ).padLeft(10);
//         final amount = Helpers.formatNumber(
//           line.amountIncludingVat,
//           option: FormatType.amount,
//         ).padLeft(10);

//         if (_hasKhmer(description)) {
//           // Print item number and values first (without description)
//           final itemNum = '$itemNumber.'.padRight(3);
//           final lineText = itemNum + ''.padRight(20) + qty + price + amount;
//           escposData.addAll(utf8.encode(lineText));
//           escposData.addAll([0x0A]);

//           final khmerImage = await KhmerPrinter.renderKhmerText(
//             '   $description', // Add indent in the text to be rendered
//             width: 380,
//             fontSize: 13,
//             maxLines: 2,
//           );
//           final khmerESCPOS = _imageToESCPOS(khmerImage, width: 380);
//           // DON'T add text before the image - go directly to image data
//           escposData.addAll(khmerESCPOS);
//           escposData.addAll([0x0A]);
//         } else {
//           // English description - simple text
//           final truncated = description.length > 20
//               ? description.substring(0, 20)
//               : description.padRight(20);
//           final itemNum = '$itemNumber.'.padRight(3);
//           final lineText = itemNum + truncated + qty + price + amount;
//           escposData.addAll(utf8.encode(lineText));
//           escposData.addAll([0x0A]);
//         }

//         itemNumber++;
//       }

//       // Separator
//       escposData.addAll(utf8.encode('-' * 48));
//       escposData.addAll([0x0A]);

//       // Right alignment for totals
//       escposData.addAll([0x1B, 0x61, 0x02]); // ESC a 2

//       // Subtotal
//       if (detail?.header.priceIncludeVat != null) {
//         final subtotal =
//             'Subtotal: ${Helpers.formatNumber(detail!.header.priceIncludeVat!, option: FormatType.amount)}';
//         escposData.addAll(utf8.encode(subtotal));
//         escposData.addAll([0x0A]);
//       }

//       // Discount
//       final discountAmount = detail?.header.amount ?? 0;
//       final discountText = discountAmount > 0
//           ? 'Discount: -${Helpers.formatNumber(discountAmount, option: FormatType.amount)}'
//           : 'Discount: \$0.00';
//       escposData.addAll(utf8.encode(discountText));
//       escposData.addAll([0x0A]);

//       // VAT (if applicable)
//       if (detail?.header.amount != null && detail!.header.amount! > 0) {
//         final vat =
//             'VAT: ${Helpers.formatNumber(detail.header.amount!, option: FormatType.amount)}';
//         escposData.addAll(utf8.encode(vat));
//         escposData.addAll([0x0A]);
//       }

//       // Separator
//       escposData.addAll(utf8.encode('=' * 48));
//       escposData.addAll([0x0A]);

//       // Total (bold, large)
//       escposData.addAll([0x1B, 0x45, 0x01]); // Bold on
//       escposData.addAll([0x1D, 0x21, 0x10]); // Wide font
//       final total =
//           'TOTAL: ${Helpers.formatNumber(detail?.header.amount ?? 0, option: FormatType.amount)}';
//       escposData.addAll(utf8.encode(total));
//       escposData.addAll([0x0A]);
//       escposData.addAll([0x1B, 0x45, 0x00]); // Bold off
//       escposData.addAll([0x1D, 0x21, 0x00]); // Normal font

//       // Separator
//       escposData.addAll(utf8.encode('=' * 48));
//       escposData.addAll([0x0A, 0x0A]);

//       // Center alignment for footer
//       escposData.addAll([0x1B, 0x61, 0x01]); // ESC a 1

//       // Thank you message (check if Khmer)
//       const thankYouMessage =
//           'សូមអរគុណSamsung មួយទឹក មានធានា០១ឆ្នាំដំបូងគេ​នៅកម្ពុជា!------------- Thank you!';
//       if (_hasKhmer(thankYouMessage)) {
//         final khmerImage = await KhmerPrinter.renderKhmerText(
//           thankYouMessage,
//           width: 384,
//           fontSize: 16,
//         );
//         final khmerESCPOS = _imageToESCPOS(khmerImage, width: 384);
//         escposData.addAll(khmerESCPOS);
//         escposData.addAll([0x0A]);
//       } else {
//         escposData.addAll(utf8.encode(thankYouMessage));
//         escposData.addAll([0x0A]);
//       }

//       escposData.addAll(utf8.encode('We look forward to serving you again!'));
//       escposData.addAll([0x0A, 0x0A]);

//       escposData.addAll(utf8.encode('Powered by Blue Technology Co., Ltd.'));
//       escposData.addAll([0x0A]);

//       // Feed and cut
//       escposData.addAll([0x1B, 0x64, 0x03]); // Feed 3 lines
//       escposData.addAll([0x1D, 0x56, 0x00]); // Cut paper

//       // Send to printer
//       final success = await ESCPOSPrinter.printRaw(
//         Uint8List.fromList(escposData),
//       );

//       final totalTime = DateTime.now().difference(startTime).inMilliseconds;
//       debugPrint("🎉 Total print time: ${totalTime}ms");

//       l.hide();

//       if (success) {
//         showSuccessMessage("✓ Print successful!");
//       } else {
//         showErrorMessage("✗ Print failed");
//       }
//     } catch (e) {
//       debugPrint("❌ Print error: $e");
//       if (mounted) {
//         LoadingOverlay.of(context).hide();
//       }
//       showErrorMessage("Print failed: $e");
//     }
//   }

//   // ============================================================================
//   // HELPER METHODS
//   // ============================================================================

//   bool _hasKhmer(String? text) {
//     if (text == null || text.isEmpty) return false;
//     return KhmerPrinter.containsKhmer(text);
//   }

//   Future<bool> _ensurePrinterConnection() async {
//     bool isConnected = await ESCPOSPrinter.isConnected();

//     if (!isConnected && _connectedAddress != null) {
//       debugPrint("🔄 Attempting to reconnect...");
//       isConnected = await ESCPOSPrinter.connect(_connectedAddress!);
//     }

//     if (!isConnected) {
//       showErrorMessage("Printer not connected. Please connect first.");
//       _showDeviceSelector();
//       return false;
//     }

//     return true;
//   }

//   Future<img.Image?> _loadLogoForPrinter(String logo) async {
//     try {
//       img.Image? logoImage;
//       if (logo.startsWith('http')) {
//         final response = await http.get(Uri.parse(logo));
//         if (response.statusCode == 200) {
//           logoImage = img.decodeImage(response.bodyBytes);
//         }
//       } else {
//         final bytes = base64Decode(logo);
//         logoImage = img.decodeImage(bytes);
//       }
//       if (logoImage != null) {
//         return img.copyResize(logoImage, width: 120);
//       }
//     } catch (e) {
//       debugPrint("⚠️ Failed to load logo: $e");
//     }
//     return null;
//   }

//   List<int> _imageToESCPOS(img.Image image, {int width = 384}) {
//     final resized = img.copyResize(image, width: width);
//     final imageWidth = resized.width;
//     final imageHeight = resized.height;
//     final widthBytes = (imageWidth + 7) ~/ 8;

//     // Convert to monochrome bitmap
//     final bitmap = <int>[];
//     for (int y = 0; y < imageHeight; y++) {
//       for (int x = 0; x < widthBytes; x++) {
//         int byte = 0;
//         for (int bit = 0; bit < 8; bit++) {
//           final px = x * 8 + bit;
//           if (px < imageWidth) {
//             final pixel = resized.getPixel(px, y);
//             final luminance = pixel.r.toInt();
//             if (luminance < 128) {
//               byte |= (1 << (7 - bit));
//             }
//           }
//         }
//         bitmap.add(byte);
//       }
//     }

//     // Build ESC/POS command
//     final escpos = <int>[];
//     escpos.addAll([0x1D, 0x76, 0x30, 0x00]); // GS v 0
//     escpos.add(widthBytes & 0xFF);
//     escpos.add((widthBytes >> 8) & 0xFF);
//     escpos.add(imageHeight & 0xFF);
//     escpos.add((imageHeight >> 8) & 0xFF);
//     escpos.addAll(bitmap);

//     return escpos;
//   }

//   void _showLoadingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );
//   }

//   // ============================================================================
//   // UI BUILD METHODS
//   // ============================================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: _buildAppBar(), body: _buildBody());
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBarWidget(
//       title: greeting(_getTitle()),
//       actions: [
//         if (_connected) _buildConnectionIndicator(),
//         _buildBluetoothButton(),
//         Helpers.gapW(8),
//         _buildPrintButton(),
//         Helpers.gapW(appSpace),
//       ],
//     );
//   }

//   Widget _buildConnectionIndicator() {
//     return Padding(
//       padding: const EdgeInsets.only(right: 8),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.green.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.green),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Icon(Icons.bluetooth_connected, color: Colors.green, size: 16),
//               SizedBox(width: 4),
//               Text(
//                 'Connected',
//                 style: TextStyle(color: Colors.green, fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBluetoothButton() {
//     return BtnIconCircleWidget(
//       onPressed: _connected ? _disconnect : _showDeviceSelector,
//       icons: Icon(
//         _connected ? Icons.bluetooth_connected : Icons.bluetooth,
//         color: white,
//       ),
//       rounded: appBtnRound,
//     );
//   }

//   Widget _buildPrintButton() {
//     return BlocBuilder<
//       SaleOrderHistoryDetailCubit,
//       SaleOrderHistoryDetailState
//     >(
//       bloc: _cubit,
//       builder: (context, state) {
//         return BtnIconCircleWidget(
//           onPressed: () => _printReceipt(
//             detail: state.record,
//             companyInfo: state.comPanyInfo,
//           ),
//           icons: const Icon(Icons.print_rounded, color: white),
//           rounded: appBtnRound,
//         );
//       },
//     );
//   }

//   Widget _buildBody() {
//     return BlocBuilder<
//       SaleOrderHistoryDetailCubit,
//       SaleOrderHistoryDetailState
//     >(
//       bloc: _cubit,
//       builder: (context, state) {
//         if (state.isLoading) return const LoadingPageWidget();

//         return ListView(
//           padding: const EdgeInsets.all(appSpace),
//           children: [
//             if (_statusMessage.isNotEmpty) _buildStatusCard(),
//             if (_statusMessage.isNotEmpty) const SizedBox(height: 8),
//             SaleHistoryDetailBox(
//               header: state.record?.header,
//               lines: state.record?.lines ?? [],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildStatusCard() {
//     return Card(
//       color: _connected ? Colors.green.shade50 : Colors.orange.shade50,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             Icon(
//               _connected ? Icons.check_circle : Icons.info,
//               color: _connected ? Colors.green : Colors.orange,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 _statusMessage,
//                 style: TextStyle(
//                   color: _connected
//                       ? Colors.green.shade900
//                       : Colors.orange.shade900,
//                 ),
//               ),
//             ),
//             if (!_connected)
//               TextButton(
//                 onPressed: _showDeviceSelector,
//                 child: const Text('Connect'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==================== ESC/POS PRINTER CLASS ====================
// class ESCPOSPrinter {
//   static const MethodChannel _channel = MethodChannel(
//     'native_bluetooth_printer',
//   );

//   static Future<List<BluetoothDevice>> scanDevices({int timeout = 10}) async {
//     try {
//       debugPrint("🔍 Scanning for Bluetooth devices...");
//       final List<dynamic>? devices = await _channel.invokeMethod(
//         'scanDevices',
//         {'timeout': timeout},
//       );

//       if (devices == null) return [];

//       return devices.map((device) {
//         return BluetoothDevice(
//           name: device['name'] ?? 'Unknown',
//           address: device['address'] ?? '',
//         );
//       }).toList();
//     } catch (e) {
//       debugPrint("❌ Error scanning devices: $e");
//       return [];
//     }
//   }

//   static Future<bool> connect(String address) async {
//     try {
//       debugPrint("🔗 Connecting to device: $address");
//       final bool? result = await _channel.invokeMethod('connect', {
//         'address': address,
//       });
//       return result ?? false;
//     } catch (e) {
//       debugPrint("❌ Error connecting: $e");
//       return false;
//     }
//   }

//   static Future<void> disconnect() async {
//     try {
//       await _channel.invokeMethod('disconnect');
//       debugPrint("🔌 Disconnected from printer");
//     } catch (e) {
//       debugPrint("❌ Error disconnecting: $e");
//     }
//   }

//   static Future<bool> isConnected() async {
//     try {
//       final bool? result = await _channel.invokeMethod('isConnected');
//       return result ?? false;
//     } catch (e) {
//       debugPrint("❌ Error checking connection: $e");
//       return false;
//     }
//   }

//   static Future<bool> printRaw(Uint8List data) async {
//     try {
//       final bool? result = await _channel.invokeMethod('printRaw', {
//         'data': data,
//       });
//       return result ?? false;
//     } catch (e) {
//       debugPrint("❌ Error printing raw data: $e");
//       return false;
//     }
//   }
// }

// class BluetoothDevice {
//   final String name;
//   final String address;

//   BluetoothDevice({required this.name, required this.address});

//   @override
//   String toString() => 'BluetoothDevice(name: $name, address: $address)';
// }

// // ==================== KHMER PRINTER CLASS ====================
// class KhmerPrinter {
//   static const MethodChannel _channel = MethodChannel('khmer_text_renderer');

//   static Future<img.Image> renderKhmerText(
//     String text, {
//     double width = 384,
//     double fontSize = 24,
//     int maxLines = 1,
//     bool useCache = true,
//   }) async {
//     try {
//       final Uint8List? result = await _channel.invokeMethod('renderText', {
//         'text': text,
//         'width': width,
//         'fontSize': fontSize,
//         'maxLines': maxLines,
//         'useCache': useCache,
//       });

//       if (result == null) {
//         throw Exception('Failed to render Khmer text');
//       }

//       final image = img.decodeImage(result);
//       if (image == null) {
//         throw Exception('Failed to decode rendered image');
//       }

//       return image;
//     } catch (e) {
//       debugPrint('Error rendering Khmer text: $e');
//       rethrow;
//     }
//   }

//   static Future<Map<String, img.Image>> renderKhmerBatch(
//     Map<String, KhmerTextConfig> configs,
//   ) async {
//     if (configs.isEmpty) return {};

//     try {
//       final startTime = DateTime.now();

//       final texts = configs.keys.toList();
//       final textValues = configs.values.map((c) => c.text).toList();
//       final widths = configs.values.map((c) => c.width).toList();
//       final fontSizes = configs.values.map((c) => c.fontSize).toList();
//       final maxLines = configs.values.map((c) => c.maxLines).toList();

//       debugPrint("📤 Batch rendering ${texts.length} Khmer texts...");

//       final List<dynamic>? results = await _channel
//           .invokeMethod('renderTextBatch', {
//             'texts': textValues,
//             'widths': widths,
//             'fontSizes': fontSizes,
//             'maxLines': maxLines,
//           });

//       if (results == null) {
//         throw Exception('Failed to batch render Khmer text');
//       }

//       final Map<String, img.Image> renderedImages = {};

//       for (int i = 0; i < texts.length; i++) {
//         if (results[i] != null && results[i] is Uint8List) {
//           final image = img.decodeImage(results[i] as Uint8List);
//           if (image != null) {
//             renderedImages[texts[i]] = image;
//           }
//         }
//       }

//       final batchTime = DateTime.now().difference(startTime).inMilliseconds;
//       debugPrint(
//         "✅ Batch rendered ${renderedImages.length} texts in ${batchTime}ms",
//       );

//       return renderedImages;
//     } catch (e) {
//       debugPrint('Error batch rendering Khmer text: $e');
//       return {};
//     }
//   }

//   static Future<void> clearCache() async {
//     try {
//       await _channel.invokeMethod('clearCache');
//       debugPrint('✅ Khmer render cache cleared');
//     } catch (e) {
//       debugPrint('Error clearing cache: $e');
//     }
//   }

//   static bool containsKhmer(String text) {
//     return text.contains(RegExp(r'[\u1780-\u17FF]'));
//   }
// }

// class KhmerTextConfig {
//   final String text;
//   final double width;
//   final double fontSize;
//   final int maxLines;

//   KhmerTextConfig({
//     required this.text,
//     this.width = 384,
//     this.fontSize = 24,
//     this.maxLines = 1,
//   });
// }
