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
      await QuickExamples.printMixedReceipt();
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
