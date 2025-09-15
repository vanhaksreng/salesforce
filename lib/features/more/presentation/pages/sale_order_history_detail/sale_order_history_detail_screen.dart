import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
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
  final List<BluetoothDevice> _devices = [];
  BluetoothCharacteristic? _writeCharacteristic;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<bool>? _scanningStateSubscription;

  @override
  void initState() {
    super.initState();
    _cubit.getSaleDetails(no: widget.documentNo);
    _cubit.getComapyInfo();
    _initBluetooth();
  }

  @override
  void dispose() {
    _cleanupBluetooth();
    super.dispose();
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

  Future<void> _initBluetooth() async {
    await _checkPermissions();
    _setupBluetoothStreams();
    if (await FlutterBluePlus.isSupported) {
      await _startScan();
    }
  }

  Future<void> _checkPermissions() async {
    final permissions = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    if (permissions.values.any((status) => !status.isGranted)) {
      showWarningMessage(
        'Some permissions were denied. Bluetooth functionality may be limited.',
      );
    }
  }

  void _setupBluetoothStreams() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _cubit.setBluetoothAdapterState(state);
      if (state == BluetoothAdapterState.on) {
        showSuccessMessage(greeting('Bluetooth enabled'));
        _startScan();
      } else if (state == BluetoothAdapterState.off) {
        showErrorMessage(greeting('Bluetooth disabled'));
        _cubit.scaningBluetooth(false);
        _devices.clear();
        _cubit.setBluetoothDevice(null);
      }
    });

    _scanningStateSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      _cubit.scaningBluetooth(scanning);
    });

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        if (!_devices.contains(result.device)) {
          _devices.add(result.device);
        }
      }
    });
  }

  Future<void> _startScan() async {
    if (_cubit.state.adapterState != BluetoothAdapterState.on) return;

    try {
      final systemDevices = await FlutterBluePlus.bondedDevices;
      _devices.addAll(
        systemDevices.where((device) => !_devices.contains(device)),
      );

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      showErrorMessage('Failed to start Bluetooth scan: $e');
    }
  }

  Future<void> _cleanupBluetooth() async {
    await _scanSubscription?.cancel();
    await _adapterStateSubscription?.cancel();
    await _connectionStateSubscription?.cancel();
    await _scanningStateSubscription?.cancel();
    await FlutterBluePlus.stopScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      showSuccessMessage('Connecting to ${device.platformName}...');
      await device.connect(autoConnect: false);

      try {
        await device.requestMtu(512);
      } catch (e) {
        debugPrint('MTU request failed: $e');
      }

      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((state) {
        _cubit.setConnectingBluetooth(
          state == BluetoothConnectionState.connected,
        );

        if (state == BluetoothConnectionState.connected) {
          showSuccessMessage('Connected to ${device.platformName}');
          _discoverServices(device);
        } else if (state == BluetoothConnectionState.disconnected) {
          showWarningMessage('Disconnected from ${device.platformName}');
        }
      });
    } catch (e) {
      showErrorMessage('Connection failed: $e');
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
            break;
          }
        }
        if (_writeCharacteristic != null) break;
      }

      if (_writeCharacteristic == null) {
        showWarningMessage('No writable characteristic found');
      }
    } catch (e) {
      showErrorMessage('Service discovery failed: $e');
    }
  }

  //===============================test==========================================
  Future<void> _printReceipt() async {
    if (!_cubit.state.isConnected || _writeCharacteristic == null) {
      showErrorMessage(
        'Not connected to a printer or no writable characteristic found',
      );
      return;
    }

    try {
      //=======================Generate Receipt Bytes==================
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

  IconData _getConnectionIcon(BluetoothConnectionState state) =>
      switch (state) {
        BluetoothConnectionState.connected => Icons.link,
        BluetoothConnectionState.connecting => Icons.link,
        _ => Icons.link_off,
      };

  Color _getConnectionColor(BluetoothConnectionState state) => switch (state) {
    BluetoothConnectionState.connected => Colors.green,
    BluetoothConnectionState.connecting => Colors.orange,
    _ => Colors.grey,
  };

  String _getConnectionText(BluetoothConnectionState state) => switch (state) {
    BluetoothConnectionState.connected => 'Connected',
    BluetoothConnectionState.connecting => 'Connecting...',
    BluetoothConnectionState.disconnecting => 'Disconnecting...',
    _ => 'Tap to connect',
  };

  Widget _getTrailingWidget(BluetoothConnectionState state) => switch (state) {
    BluetoothConnectionState.connected => const Icon(
      Icons.check_circle,
      color: Colors.green,
    ),
    BluetoothConnectionState.connecting => const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    _ => const Icon(Icons.arrow_forward_ios),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting(_getTitle()),
        actions: [
          BtnIconCircleWidget(
            onPressed: _showBluetoothDevices,
            icons: const Icon(Icons.print_rounded, color: white),
            rounded: appBtnRound,
          ),
          Helpers.gapW(appSpace),
        ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(appSpace),
      child: SaleHistoryDetailBox(header: record.header, lines: record.lines),
    );
  }

  Future<void> _showBluetoothDevices() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
            bloc: _cubit,
            builder: (context, state) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.95,
              builder: (context, scrollController) => Container(
                color: white,
                child: Column(
                  children: [
                    BtnTextWidget(
                      onPressed: _printReceipt,
                      child: const TextWidget(text: 'Print'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          final isDeviceConnected =
                              state.connectedDevice == device;

                          return StreamBuilder<BluetoothConnectionState>(
                            stream: device.connectionState,
                            initialData: BluetoothConnectionState.disconnected,
                            builder: (context, snapshot) {
                              final connectionState =
                                  snapshot.data ??
                                  BluetoothConnectionState.disconnected;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                elevation: isDeviceConnected ? 4 : 1,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.bluetooth,
                                    color: isDeviceConnected
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                  title: Text(
                                    device.platformName.isNotEmpty
                                        ? device.platformName
                                        : 'Unknown Device',
                                    style: TextStyle(
                                      fontWeight: isDeviceConnected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('ID: ${device.remoteId}'),
                                      Row(
                                        children: [
                                          Icon(
                                            _getConnectionIcon(connectionState),
                                            size: 12,
                                            color: _getConnectionColor(
                                              connectionState,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getConnectionText(connectionState),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getConnectionColor(
                                                connectionState,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: _getTrailingWidget(connectionState),
                                  onTap: () {
                                    if (connectionState ==
                                        BluetoothConnectionState.disconnected) {
                                      _connectToDevice(device);
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
