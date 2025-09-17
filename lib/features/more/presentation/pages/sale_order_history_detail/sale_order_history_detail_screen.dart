import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:image/image.dart' as img;
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_mm80.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

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
  late BluetoothDevice bluetoothDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  final Map<String, BluetoothCharacteristic> _writeCharacteristics = {};

  ReceiptPreview? preview;

  @override
  void initState() {
    super.initState();
    _loadData();
    checkBluetoothDevie();
    _waitForDataAndLoadPreview();
  }

  _loadData() async {
    _cubit.getSaleDetails(no: widget.documentNo);
    _cubit.getComapyInfo();

    // Wait a bit and then check for data periodically
    _waitForDataAndLoadPreview();
  }

  _waitForDataAndLoadPreview() async {
    // Poll until data is available
    while (_cubit.state.record == null || _cubit.state.comPanyInfo == null) {
      await Future.delayed(Duration(milliseconds: 100));
      if (!mounted) return; // Exit if widget is disposed
    }

    // Data is now available, load preview
    await loadPreview();
  }

  loadPreview() async {
    // Add null checks to be safe
    if (_cubit.state.record == null || _cubit.state.comPanyInfo == null) {
      print("Data not ready for preview");
      return;
    }

    final segments = buildReceiptSegmentsForPreview(
      detail: _cubit.state.record,
      companyInfo: _cubit.state.comPanyInfo,
    );

    preview = await generateReceiptPreview(segments);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> checkBluetoothDevie() async {
    final devices = FlutterBluePlus.connectedDevices;
    if (devices.isEmpty) return;

    bluetoothDevice = devices[0];
    await _discoverServices(bluetoothDevice);
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

  Future<void> _printReceipt() async {
    if (_writeCharacteristic == null ||
        bluetoothDevice.remoteId.str.isEmpty ||
        bluetoothDevice.isDisconnected) {
      showErrorMessage(
        'Not connected to a printer or no writable characteristic found',
      );
      return;
    }

    try {
      final bytes = await ReceiptMm80.generateCustomReceiptBytes(
        detail: _cubit.state.record,
        companyInfo: _cubit.state.comPanyInfo,
      );

      await _sendDataInChunks(_writeCharacteristic!, bytes);
      showSuccessMessage('Receipt printed successfully!');
    } catch (e) {
      showErrorMessage('Printing failed: $e');
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      BluetoothCharacteristic? writeCharacteristic;

      outerLoop:
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            writeCharacteristic = characteristic;
            break outerLoop;
          }
        }
      }

      if (writeCharacteristic != null) {
        _writeCharacteristics[device.remoteId.toString()] = writeCharacteristic;
        _writeCharacteristic = writeCharacteristic;
      }
    } catch (e) {
      debugPrint('Service discovery error: $e');
    }
  }

  // Future<void> _sendDataInChunks(
  //   BluetoothCharacteristic characteristic,
  //   List<int> data, {
  //   int chunkSize = 182, // smaller is smoother
  // }) async {
  //   for (var i = 0; i < data.length; i += chunkSize) {
  //     final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
  //     final chunk = data.sublist(i, end);

  //     try {
  //       await characteristic.write(chunk, withoutResponse: true);
  //     } catch (e) {
  //       await Future.delayed(const Duration(milliseconds: 20));
  //       await characteristic.write(chunk, withoutResponse: true);
  //     }

  //     // Longer delay helps smoothness
  //     await Future.delayed(const Duration(milliseconds: 20));
  //   }
  // }

  Future<void> _sendDataInChunks(
    BluetoothCharacteristic characteristic,
    List<int> data, {
    int chunkSize = 128,
  }) async {
    for (var i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      final chunk = data.sublist(i, end);

      await characteristic.write(chunk, withoutResponse: true);

      // Delay only if not the last chunk
      if (end < data.length) {
        await Future.delayed(Duration(milliseconds: 10));
      }
    }

    // Final delay to ensure printer processes last command
    await Future.delayed(Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting(_getTitle()),
        actions: [
          BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
            bloc: _cubit,
            builder: (context, state) {
              return BtnIconCircleWidget(
                onPressed: () => showReceiptPreviewDialog(context, preview),
                // onPressed: () => _printReceipt(),
                icons: const Icon(Icons.print_rounded, color: white),
                rounded: appBtnRound,
              );
            },
          ),
          Helpers.gapW(appSpace),
        ],
        heightBottom: scaleFontSize(30),
        bottom: _buildStatusConnect(),
      ),
      body:
          BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
            bloc: _cubit,
            builder: (context, state) {
              return _buildBody(state);
            },
          ),
    );
  }

  BoxWidget _buildStatusConnect() {
    return BoxWidget(
      isBoxShadow: false,
      color: success,
      padding: EdgeInsets.symmetric(
        horizontal: scaleFontSize(16),
        vertical: scaleFontSize(8),
      ),
      isRounding: false,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(color: white, text: "Connecting bluetooth "),
          // BtnTextWidget(
          //   onPressed: () {},
          //   child: TextWidget(text: "Disconnect", color: red),
          // ),
        ],
      ),
    );
  }

  Widget _buildBody(SaleOrderHistoryDetailState state) {
    if (state.isLoading) {
      return LoadingPageWidget();
    }
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
  }

  Color changColor(bool isDeviceConnected) {
    if (isDeviceConnected) {
      return success;
    }
    return primary;
  }
}
