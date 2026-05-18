import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/bluetooth_list_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/imin_device/imin_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
import 'package:salesforce/infrastructure/external_services/bluetooth_printer_service.dart';
import 'package:salesforce/infrastructure/services/print_receipt.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleOrderHistoryDetailScreen extends StatefulWidget {
  const SaleOrderHistoryDetailScreen({
    super.key,
    required this.documentNo,
    required this.typeDoc,
    required this.isSync,
  });

  final String documentNo;
  final String isSync;
  final String typeDoc;
  static const String routeName = "SaleOrderDetailHistoryScreen";

  @override
  State<SaleOrderHistoryDetailScreen> createState() =>
      _SaleOrderHistoryDetailScreenState();
}

class _SaleOrderHistoryDetailScreenState
    extends State<SaleOrderHistoryDetailScreen>
    with MessageMixin, IminPrinterMixin {
  final _cubit = SaleOrderHistoryDetailCubit();

  final _printerService = BluetoothPrinterService();
  List<Map<String, dynamic>> _devices = [];
  bool _isConnected = false;

  bool connected = false;
  String? connectedMac;
  String? connectingMac;
  String statusMessage = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await checkIminDevice();
    await _cubit.getSaleDetails(no: widget.documentNo, isSync: widget.isSync);
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

  Future<void> _loadDevices() async {
    bool hasPerm = await _printerService.requestPermissions();
    if (hasPerm) {
      final list = await _printerService.getPairedDevices();
      setState(() => _devices = list);
    }
  }

  Future<void> _connectTo(String address) async {
    bool success = await _printerService.connect(address);
    setState(() => _isConnected = success);
  }

  void onConfirmSetupPrinter({
    required String address,
    required String deviceName,
    required String printerSize,
  }) async {
    final device = DevicePrinter(
      deviceName,
      deviceName,
      "Bluetooth",
      deviceName,
      address,
      Helpers.toDouble(printerSize),
    );

    await _cubit.storeDevicePrinter(device);
    await _connectTo(address);

    if (_cubit.state.record != null && _cubit.state.comPanyInfo != null) {
      PrintReceipt().print(_cubit.state.record!, _cubit.state.comPanyInfo!);
    }
  }

  Future<String?> showSessionLoginDialog(BuildContext context) {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, _, _) => BluetoothListWidget(
        devices: _devices,
        onConfirm: onConfirmSetupPrinter,
      ),
    );
  }

  void pushToPrintReceipt() async {
    await _loadDevices();

    final devices = await _cubit.getPrinterConfig();
    if (devices.isNotEmpty) {
      await _connectTo(devices.first.macAddress);
    }

    if (!mounted) return;
    if (_isConnected) {
      PrintReceipt().print(_cubit.state.record!, _cubit.state.comPanyInfo!);
    } else {
      showSessionLoginDialog(context);
    }

    // if (await checkIminDevice()) {
    //   if (!mounted) return;
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) {
    //         return ReceiptImin(companyInfo: company, detail: detail);
    //       },
    //     ),
    //   );
    // } else {
    //   if (!mounted) return;
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) {
    //         return ReceiptPreviewScreen(companyInfo: company, detail: detail);
    //       },
    //     ),
    //   );
    // }
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
              return BtnIconCircleWidget(
                onPressed: pushToPrintReceipt,
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
              if (state.isLoading) {
                return const LoadingPageWidget();
              }

              final record = state.record;
              final header = record?.header;
              final lines = record?.lines ?? [];

              final lineAmount = lines.fold<double>(
                0.0,
                (sum, line) => sum + Helpers.toDouble(line.amountIncludingVat),
              );

              return ListView(
                padding: const EdgeInsets.all(appSpace),
                children: [
                  SaleHistoryDetailBox(
                    header: header,
                    lines: lines,
                    lineAmount: Helpers.formatNumber(
                      lineAmount,
                      option: FormatType.amount,
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
