import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_page_screen.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
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
  BluetoothDevice? bluetoothDevice;

  // final List<BluetoothDevice> _devices = [];
  // BluetoothCharacteristic? _writeCharacteristic;
  // StreamSubscription<List<ScanResult>>? _scanSubscription;
  // StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  // StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  // StreamSubscription<bool>? _scanningStateSubscription;

  @override
  void initState() {
    super.initState();
    _cubit.getSaleDetails(no: widget.documentNo);
    _cubit.getComapyInfo();
    checkBluetoothDevie();
  }

  checkBluetoothDevie() {
    List<BluetoothDevice> devices = FlutterBluePlus.connectedDevices;
    if (devices.isEmpty) {
      return;
    }
    bluetoothDevice = FlutterBluePlus.connectedDevices[0];
  }
  // @override
  // void dispose() {
  //   _cleanupBluetooth();
  //   super.dispose();
  // }

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

  // Future<void> _initBluetooth() async {
  //   await _checkPermissions();
  //   _setupBluetoothStreams();
  //   if (await FlutterBluePlus.isSupported) {
  //     await _startScan();
  //   }
  // }

  // Future<void> _checkPermissions() async {
  //   final permissions = await [
  //     Permission.bluetoothScan,
  //     Permission.bluetoothConnect,
  //     Permission.bluetoothAdvertise,
  //     Permission.location,
  //   ].request();

  //   if (permissions.values.any((status) => !status.isGranted)) {
  //     showWarningMessage(
  //       'Some permissions were denied. Bluetooth functionality may be limited.',
  //     );
  //   }
  // }

  // void _setupBluetoothStreams() {
  //   _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
  //     _cubit.setBluetoothAdapterState(state);
  //     if (state == BluetoothAdapterState.on) {
  //       showSuccessMessage(greeting('Bluetooth enabled'));
  //       _startScan();
  //     } else if (state == BluetoothAdapterState.off) {
  //       showErrorMessage(greeting('Bluetooth disabled'));
  //       _cubit.scaningBluetooth(false);
  //       _devices.clear();
  //       _cubit.setBluetoothDevice(null);
  //     }
  //   });

  //   _scanningStateSubscription = FlutterBluePlus.isScanning.listen((scanning) {
  //     _cubit.scaningBluetooth(scanning);
  //   });

  //   _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
  //     for (final result in results) {
  //       if (!_devices.contains(result.device)) {
  //         _devices.add(result.device);
  //       }
  //     }
  //   });
  // }

  // Future<void> _startScan() async {
  //   if (_cubit.state.adapterState != BluetoothAdapterState.on) return;

  //   try {
  //     final systemDevices = await FlutterBluePlus.bondedDevices;
  //     _devices.addAll(
  //       systemDevices.where((device) => !_devices.contains(device)),
  //     );

  //     await FlutterBluePlus.startScan(
  //       timeout: const Duration(seconds: 15),
  //       androidUsesFineLocation: true,
  //     );
  //   } catch (e) {
  //     showErrorMessage('Failed to start Bluetooth scan: $e');
  //   }
  // }

  // Future<void> _cleanupBluetooth() async {
  //   await _scanSubscription?.cancel();
  //   await _adapterStateSubscription?.cancel();
  //   await _connectionStateSubscription?.cancel();
  //   await _scanningStateSubscription?.cancel();
  //   await FlutterBluePlus.stopScan();
  // }

  // Future<void> _connectToDevice(BluetoothDevice device) async {
  //   try {
  //     showSuccessMessage('Connecting to ${device.platformName}...');
  //     await device.connect(autoConnect: false);

  //     try {
  //       await device.requestMtu(512);
  //     } catch (e) {
  //       debugPrint('MTU request failed: $e');
  //     }

  //     _connectionStateSubscription?.cancel();
  //     _connectionStateSubscription = device.connectionState.listen((state) {
  //       _cubit.setConnectingBluetooth(
  //         state == BluetoothConnectionState.connected,
  //       );

  //       if (state == BluetoothConnectionState.connected) {
  //         showSuccessMessage('Connected to ${device.platformName}');
  //         _discoverServices(device);
  //       } else if (state == BluetoothConnectionState.disconnected) {
  //         showWarningMessage('Disconnected from ${device.platformName}');
  //       }
  //     });
  //   } catch (e) {
  //     showErrorMessage('Connection failed: $e');
  //   }
  // }

  // Future<void> _discoverServices(BluetoothDevice device) async {
  //   try {
  //     final services = await device.discoverServices();
  //     for (final service in services) {
  //       for (final characteristic in service.characteristics) {
  //         if (characteristic.properties.write ||
  //             characteristic.properties.writeWithoutResponse) {
  //           _writeCharacteristic = characteristic;
  //           break;
  //         }
  //       }
  //       if (_writeCharacteristic != null) break;
  //     }

  //     if (_writeCharacteristic == null) {
  //       showWarningMessage('No writable characteristic found');
  //     }
  //   } catch (e) {
  //     showErrorMessage('Service discovery failed: $e');
  //   }
  // }

  //===============================test==========================================
  // Future<void> _printReceipt() async {
  //   if (!_cubit.state.isConnected || _writeCharacteristic == null) {
  //     showErrorMessage(
  //       'Not connected to a printer or no writable characteristic found',
  //     );
  //     return;
  //   }

  //   try {
  //     //=======================Generate Receipt Bytes==================
  //     final bytes = await ReceiptMm80.generateCustomReceiptBytes(
  //       detail: _cubit.state.record,
  //       companyInfo: _cubit.state.comPanyInfo,
  //     );

  //     await _sendDataInChunks(_writeCharacteristic!, bytes);
  //     showSuccessMessage('Receipt printed successfully!');
  //   } catch (e) {
  //     showErrorMessage('Printing failed: $e');
  //   }
  // }

  //------------------------------------------------------------------------------

  // Future<void> _printReceipt() async {
  //   if (!_cubit.state.isConnected || _writeCharacteristic == null) {
  //     showErrorMessage(
  //       'Not connected to a printer or no writable characteristic found',
  //     );
  //     return;
  //   }

  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //         'https://static.wixstatic.com/media/74d6b3_90bfe62be075409f869ae62e07dfa76e~mv2.png',
  //       ),
  //     );
  //     final imageBytes = response.bodyBytes;
  //     final decodedImage = img.decodeImage(imageBytes)!;
  //     final profile = await CapabilityProfile.load();
  //     final generator = Generator(PaperSize.mm80, profile);

  //     //=======================asdffasdf==================
  //     final bytes = await ReceiptMm80.generateCustomReceiptBytes(
  //       saleDate: widget.typeDoc,
  //       staff: "",
  //       invoiceNo: widget.documentNo,
  //       telephone: "08888",
  //       items: _cubit.state.record!.lines,
  //       subTotal: 09999,
  //       grandTotal: 344,
  //       receivedAmount: 2345,
  //       accountName: "Hello",
  //       // logoUrl:
  //       //     "https://static.wixstatic.com/media/74d6b3_90bfe62be075409f869ae62e07dfa76e~mv2.png",
  //     );

  //     await _sendDataInChunks(_writeCharacteristic!, bytes);
  //   } catch (e) {
  //     showErrorMessage('Printing failed: $e');
  //   }
  // }

  Future<void> _sendDataInChunks(
    BluetoothCharacteristic characteristic,
    List<int> data, {
    int chunkSize = 180,
  }) async {
    for (var i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      final chunk = data.sublist(i, end);

      try {
        await characteristic.write(chunk, withoutResponse: true);
      } catch (e) {
        // Optional: retry once if failed
        await Future.delayed(const Duration(milliseconds: 50));
        await characteristic.write(chunk, withoutResponse: true);
      }

      // Delay to avoid BLE overflow
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  pushToBluetoothPage(BuildContext context) {
    return Navigator.pushNamed(
      context,
      BluetoothPageScreen.routeName,
      arguments: bluetoothDevice,
    ).then((bluetooth) {
      if (bluetooth == null) {
        checkBluetoothDevie();
        bluetoothDevice = null;
        return;
      }
      checkBluetoothDevie();
      final device = bluetooth as BluetoothDevice;
      bluetoothDevice = device;
      setState(() {});
    });
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
                onPressed: () => pushToBluetoothPage(context),
                icons: const Icon(Icons.print_rounded, color: white),
                rounded: appBtnRound,
              );
            },
          ),
          Helpers.gapW(appSpace),
        ],
        heightBottom: scaleFontSize(30),
        bottom: BoxWidget(
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
              TextWidget(
                color: white,
                text: "Connecting bluetooth ${bluetoothDevice?.advName}",
              ),
              // BtnTextWidget(
              //   onPressed: () {},
              //   child: TextWidget(text: "Disconnect", color: red),
              // ),
            ],
          ),
        ),
      ),
      body:
          BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildBody(state);
            },
          ),
    );
  }

  Widget _buildBody(SaleOrderHistoryDetailState state) {
    final record = state.record;
    if (record == null) {
      return const EmptyScreen();
    }
    return ListView(
      padding: const EdgeInsets.all(appSpace),
      children: [
        SaleHistoryDetailBox(header: record.header, lines: record.lines),
      ],
    );
  }

  Color changColor(bool isDeviceConnected) {
    if (isDeviceConnected) {
      return success;
    }
    return primary;
  }

  // Future<void> _showBluetoothDevices() {
  //   return showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) =>
  //         BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
  //           bloc: _cubit,
  //           builder: (context, state) => DraggableScrollableSheet(
  //             expand: false,
  //             initialChildSize: 0.6,
  //             minChildSize: 0.3,
  //             maxChildSize: 0.95,
  //             builder: (context, scrollController) => BoxWidget(
  //               color: white,
  //               isBoxShadow: false,
  //               child: Column(
  //                 children: [
  //                   HeaderBottomSheet(
  //                     childWidget: TextWidget(
  //                       text: greeting("Please selected bluetooth."),
  //                       fontSize: 16,
  //                       color: white,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: ListView.separated(
  //                       shrinkWrap: true,
  //                       controller: scrollController,
  //                       itemCount: _devices.length,
  //                       itemBuilder: (context, index) {
  //                         final device = _devices[index];
  //                         final isDeviceConnected =
  //                             state.connectedDevice == device;

  //                         return StreamBuilder<BluetoothConnectionState>(
  //                           stream: device.connectionState,
  //                           initialData: BluetoothConnectionState.disconnected,
  //                           builder: (context, snapshot) {
  //                             final connectionState =
  //                                 snapshot.data ??
  //                                 BluetoothConnectionState.disconnected;

  //                             return BoxWidget(
  //                               isBoxShadow: false,
  //                               margin: EdgeInsets.symmetric(
  //                                 horizontal: scaleFontSize(appSpace8),
  //                                 vertical: scaleFontSize(4),
  //                               ),
  //                               child: ListTile(
  //                                 minVerticalPadding: 4,
  //                                 leading: ChipWidget(
  //                                   borderColor: Colors.transparent,
  //                                   horizontal: 1,
  //                                   radius: 16,
  //                                   bgColor: changColor(
  //                                     isDeviceConnected,
  //                                   ).withValues(alpha: 0.1),
  //                                   child: Icon(
  //                                     Icons.bluetooth,
  //                                     size: scaleFontSize(20),
  //                                     color: changColor(isDeviceConnected),
  //                                   ),
  //                                 ),
  //                                 title: TextWidget(
  //                                   text: device.platformName.isNotEmpty
  //                                       ? device.platformName
  //                                       : 'Unknown Device',
  //                                   fontWeight: isDeviceConnected
  //                                       ? FontWeight.bold
  //                                       : FontWeight.normal,
  //                                 ),
  //                                 subtitle: Column(
  //                                   spacing: scaleFontSize(4),
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: [
  //                                     TextWidget(
  //                                       fontSize: 12,
  //                                       text: 'ID: ${device.remoteId}',
  //                                     ),
  //                                     Row(
  //                                       spacing: scaleFontSize(4),
  //                                       children: [
  //                                         Icon(
  //                                           _getConnectionIcon(connectionState),
  //                                           size: 12,
  //                                           color: _getConnectionColor(
  //                                             connectionState,
  //                                           ),
  //                                         ),
  //                                         TextWidget(
  //                                           text: _getConnectionText(
  //                                             connectionState,
  //                                           ),
  //                                           fontSize: 12,
  //                                           color: _getConnectionColor(
  //                                             connectionState,
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 trailing: _getTrailingWidget(connectionState),
  //                                 onTap: () {
  //                                   if (connectionState ==
  //                                       BluetoothConnectionState.disconnected) {
  //                                     _connectToDevice(device);
  //                                   }
  //                                 },
  //                               ),
  //                             );
  //                           },
  //                         );
  //                       },
  //                       separatorBuilder: (BuildContext context, int index) {
  //                         return Hr(width: double.infinity);
  //                       },
  //                     ),
  //                   ),

  //                   Padding(
  //                     padding: EdgeInsets.all(scaleFontSize(16)),
  //                     child: BtnWidget(
  //                       gradient: linearGradient,
  //                       onPressed: _printReceipt,
  //                       title: "Print invoice",
  //                       icon: Icon(
  //                         Icons.print_rounded,
  //                         size: scaleFontSize(24),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //   );
  // }
}
