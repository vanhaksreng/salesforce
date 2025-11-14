import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/khmer_text_render.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/printer_manager.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
import 'package:salesforce/infrastructure/printer/bluetooth/bluetooth_printer_handler.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'receipt_printer/receipt_builder.dart';

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
    extends State<SaleOrderHistoryDetailScreen> {
  final _cubit = SaleOrderHistoryDetailCubit();
  final _printerManager = PrinterManager();

  @override
  void initState() {
    super.initState();
    _loadData();
    _printerManager.initializePrinter();
    _printerManager.onConnectionStateChanged = _onConnectionStateChanged;
  }

  void _onConnectionStateChanged() {
    if (mounted) setState(() {});
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

  Future<void> _showReceiptPreview({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating receipt preview...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Generate preview PNG bytes
      Uint8List? imageData = await ReceiptBuilder.testPrint(
        // saleDetail: detail,
        // companyInfo: companyInfo,
        // forPreview: true,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show preview dialog
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long),
                      const SizedBox(width: 8),
                      const Text(
                        'Receipt Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                // Receipt preview image
                // Receipt preview image
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.memory(
                            imageData!,
                            fit: BoxFit.cover,
                            width: 576,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Image error: $error');
                              return Container(
                                width: 576,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Invalid image data',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      error.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      if (_printerManager.isConnected)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.print),
                          label: const Text('Print Receipt'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _printReceipt(
                              detail: detail,
                              companyInfo: companyInfo,
                            );
                          },
                        )
                      else
                        Tooltip(
                          message: 'No printer connected',
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.print_disabled),
                            label: const Text('Print Receipt'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: null,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading

        _showErrorMessage("Failed to generate preview: $e");
      }
    }
  }

  Future<void> _printReceipt({
    required SaleDetail? detail,
    required CompanyInformation? companyInfo,
  }) async {
    try {
      Helpers.showMessage(msg: "msg");

      await BluetoothPrinterHandler.scanDevices();

      // Listen for discovered devices
      BluetoothPrinterHandler.setDeviceFoundCallback((device) {
        // print('Found: ${device['name']} - ${device['address']}');

        if (!BluetoothPrinterHandler.isConnected &&
            device['name'] == "XP-P323B-E1FE") {
          BluetoothPrinterHandler.connectDevice(device['address']);
        }
      });

      if (BluetoothPrinterHandler.isConnected) {

        final exampleInvoiceData = <String, dynamic>{
  'company_khmer': 'ម៉ូនីសាន់ ឯ.ក',
  'company_english': 'MONISUN CO., LTD',
  'vat': 'K005-901704358',
  'address': 'Street 215, Psar Depot 3, Toul Kork, Phnom Penh',
  'tel': '096 304 3250',
  'title_khmer': 'វិក្កយកបត្រអាករ',
  'title_english': 'TAX INVOICE',
  'customer_id': 'PANHABOY',
  'customer_name_khmer': 'Panha123343121',  // Or full bilingual
  'customer_name_english': 'Boy123',
  'customer_tel': '089214054',
  'customer_address_khmer': 'ផ្ទះលេខ២០ ជាន់ផ្ទាល់ដី បន្ទប់១០១ ផ្លូវ៣០២ សង្កាត់បឹងកេងកង១ ខណ្ឌបឹងកេងកង រាជធានីភ្នំពេញ',
  'customer_address_english': '#20 Ground Floor Room101, Street 302, Sangkat Boengkengkang 1, Khan BoengKengKong, Phnom Penh',
  'invoice_no': 'SO0000000003',
  'date': '31-Oct-2025',
  'salesman': 'G.L',
  'payment': 'COD',
  'items': [
    {
      'no': 1,
      'code': '00000BC3',
      'desc_khmer': 'ពណ៌នាទំនិញ (Khmer)',
      'desc_english': 'Puthea',
      'qty': 1,
      'uom': 'PCS',
      'price': '40',
      'discount': '0',
      'amount': '44'
    },
    {
      'no': 2,
      'code': '00002400',
      'desc_khmer': 'ពណ៌នាទំនិញ (Khmer)',
      'desc_english': 'Rice',
      'qty': 1,
      'uom': 'PCS',
      'price': '10.56',
      'discount': '0',
      'amount': '11.62'
    },
    {
      'no': 3,
      'code': '0201',
      'desc_khmer': 'វិញ្ញាសាចំណេះដឹងទូទៅ និងសិស្សពូកែ-សំ ប៊ុនណា',
      'desc_english': 'General Knowledge Book',
      'qty': 5,
      'uom': 'UNIT',
      'price': '0.8',
      'discount': '0',
      'amount': '4'
    },
    {
      'no': 4,
      'code': '01-10',
      'desc_khmer': 'ពណ៌នាទំនិញ (Khmer)',
      'desc_english': 'Pentel Marker Blue',
      'qty': 4,
      'uom': 'PCS',
      'price': '10',
      'discount': '0',
      'amount': '40'
    },
  ],
  'total_qty': '11',
  'subtotal': '94.56',
  'vat_rate': '20%',
  'vat_amount': '5.06',
  'grand_total': '99.62',
  'signatures': [
    'បេឡាករ/អ្នកចេញបណ្ណ័\nCashier/UserID',
    'អ្នកឃ្លាំង និង អ្នកដឹក\nWarehouse & Deliver',
    'អតិថិជន\nCustomer/Buyer'
  ],
  'template': 'detailed_khmer',  // For switching styles
};

       await printRawTemplate(exampleInvoiceData);
        // await BluetoothPrinterHandler.printText("");
      }

      // await QuickExamples.printMixedReceipt();
      // if (!await _printerManager.ensurePrinterConnection()) {
      //   _showErrorMessage("Printer not connected. Please connect first.");
      //   _printerManager.showDeviceSelector(context);
      //   return;
      // }

      // final l = LoadingOverlay.of(context);
      // l.show();

      // final receiptData = await printMixedReceipt.testPrint(
      //   // companyInfo: companyInfo,
      //   // saleDetail: detail,
      // );

      // final success = await BluetoothPrinter.printRaw(receiptData!);

      // if (success) {
      //   l.hide();
      //   _showSuccessMessage("✓ Print successful!");
      // } else {
      //   l.hide();
      //   _showErrorMessage("✗ Print failed");
      // }
    } catch (e) {
      debugPrint(" Print error: $e");
      if (mounted) LoadingOverlay.of(context).hide();
      _showErrorMessage("Print failed: $e");
    }
  }

  static Future<void> printRawTemplate(Map<String, dynamic> data) async {
    final StringBuffer buffer = StringBuffer();
    // buffer.writeln('=== CLEAN INVOICE TEMPLATE (Khmer-English) ===');
    buffer.writeln();
    buffer.writeln('ប្លូតិចឡូជី'); // Khmer company
    buffer.writeln('BLUE TECHNOLOGY CO., LTD');
    buffer.writeln();
    
    // buffer.writeln('VATTIN: ${data['vat']}');
    // buffer.writeln('Street 215, Psar Depot 3, Toul Kork, Phnom Penh');
    // buffer.writeln('Tel: 096 304 3250');
    // buffer.writeln();
    // buffer.writeln('-------------------');
    // buffer.writeln('វិក្កយកបត្រអាករ - TAX INVOICE'); // Khmer title
    // buffer.writeln('-------------------');
    // buffer.writeln();
    // // Customer/Invoice details (left/right aligned via padding)
    // buffer.writeln('Customer ID:         ${data['customer_id']}');
    // buffer.writeln('Customer Name:       ${data['customer_name']}');
    // buffer.writeln('Tel:                 ${data['tel']}');
    // buffer.writeln('Address:             ${data['address']}');
    // buffer.writeln();
    // buffer.writeln('Invoice No:          ${data['invoice_no']}');
    // buffer.writeln('Date:                ${data['date']}');
    // buffer.writeln('Salesman:            ${data['salesman']}');
    // buffer.writeln('Payment:             ${data['payment']}');
    // buffer.writeln();
    // buffer.writeln('-------------------');
    // buffer.writeln('ITEMS TABLE');
    // buffer.writeln(
    //   'Description              Qty  UOM  Price  Disc  Amount',
    // );
    // buffer.writeln('-------------------');
    // final List items = data['items'] ?? [];
    // for (int i = 0; i < items.length; i++) {
    //   // Loop for 50+ items
    //   final item = items[i];
    //   if (i >= 20) {
    //     // Paginate: Add page break every 20
    //     buffer.writeln('--- Page ${(i / 20).floor() + 1} ---');
    //   }
    //   buffer.writeln(
    //     '${item['no'].toString().padLeft(2)}   ${(item['desc_khmer'] as String).padRight(25)}  ${item['qty'].toString().padLeft(2)}   ${item['uom']}  ${item['price']}   ${item['discount']}  ${item['amount']}',
    //   );
    // }
    buffer.writeln();
    // buffer.writeln('Total QTY: ${data['total_qty']}');
    // buffer.writeln();
    // buffer.writeln('Sub Total:           ${data['subtotal']}');
    // buffer.writeln('VAT 20%:             ${data['vat_amount']}');
    // buffer.writeln('Grand Total:         ${data['grand_total']}');
    // buffer.writeln();
    // buffer.writeln('-------------------');
    // buffer.writeln('Signatures:');
    // buffer.writeln('Cashier/UserID:      ________________');
    // buffer.writeln('Warehouse/Deliver:   ________________');
    // buffer.writeln('Customer/Buyer:      ________________');
    // buffer.writeln();
    // buffer.writeln('=== END TEMPLATE ===');

    final rawString = buffer.toString();
    final rawBytes = utf8.encode(rawString); // UTF-8 for Khmer

    await BluetoothPrinterHandler.printRaw(rawBytes);
    // await _channel.invokeMethod('printRaw', {'rawBytes': rawBytes});
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBarWidget(
      title: greeting(_getTitle()),
      actions: [
        if (_printerManager.isConnected) _buildConnectionIndicator(),
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
      onPressed: _printerManager.isConnected
          ? _printerManager.disconnect
          : () => _printerManager.showDeviceSelector(context),
      icons: Icon(
        _printerManager.isConnected
            ? Icons.bluetooth_connected
            : Icons.bluetooth,
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
          onPressed: () => _printReceipt(
            detail: state.record,
            companyInfo: state.comPanyInfo,
          ),
          // _showReceiptPreview(
          //   detail: state.record,
          //   companyInfo: state.comPanyInfo,
          // ),
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
            if (_printerManager.statusMessage.isNotEmpty) _buildStatusCard(),
            if (_printerManager.statusMessage.isNotEmpty)
              const SizedBox(height: 8),
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
      color: _printerManager.isConnected
          ? Colors.green.shade50
          : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _printerManager.isConnected ? Icons.check_circle : Icons.info,
              color: _printerManager.isConnected ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _printerManager.statusMessage,
                style: TextStyle(
                  color: _printerManager.isConnected
                      ? Colors.green.shade900
                      : Colors.orange.shade900,
                ),
              ),
            ),
            if (!_printerManager.isConnected)
              TextButton(
                onPressed: () => _printerManager.showDeviceSelector(context),
                child: const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }
}
