// import 'dart:async';

// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_screen.dart'
//     show MessageType, PrinterConstants;
// import 'package:salesforce/realm/scheme/schemas.dart';

// class BluetoothManager {
//   final SaleOrderHistoryDetailCubit cubit;
//   final Function(String, MessageType) messageCallback;

//   final List<BluetoothDevice> _devices = [];
//   BluetoothCharacteristic? _writeCharacteristic;

//   // Stream subscriptions
//   StreamSubscription<List<ScanResult>>? _scanSubscription;
//   StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
//   StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
//   StreamSubscription<bool>? _scanningStateSubscription;

//   BluetoothManager({required this.cubit, required this.messageCallback});

//   List<BluetoothDevice> get devices => List.unmodifiable(_devices);

//   Future<void> initialize() async {
//     await _checkPermissions();
//     _setupBluetoothStreams();

//     if (await FlutterBluePlus.isSupported) {
//       await _startAutoScan();
//     }
//   }

//   void _setupBluetoothStreams() {
//     _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
//       cubit.setBluetoothAdapterState(state);

//       if (state == BluetoothAdapterState.on) {
//         messageCallback("Bluetooth enabled", MessageType.success);
//         _startAutoScan();
//       } else if (state == BluetoothAdapterState.off) {
//         messageCallback("Bluetooth disabled", MessageType.error);
//         cubit.scaningBluetooth(false);
//         _devices.clear();
//         cubit.setBluetoothDevice(null);
//       }
//     });

//     _scanningStateSubscription = FlutterBluePlus.isScanning.listen((scanning) {
//       cubit.scaningBluetooth(scanning);
//     });

//     _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         if (!_devices.contains(result.device) &&
//             result.device.platformName.isNotEmpty) {
//           _devices.add(result.device);
//         }
//       }
//     });
//   }

//   Future<void> _startAutoScan() async {
//     if (cubit.state.adapterState != BluetoothAdapterState.on) return;

//     try {
//       // Add bonded devices
//       final systemDevices = await FlutterBluePlus.bondedDevices;
//       _devices.addAll(
//         systemDevices.where(
//           (device) =>
//               !_devices.contains(device) && device.platformName.isNotEmpty,
//         ),
//       );

//       await FlutterBluePlus.startScan(
//         timeout: PrinterConstants.scanTimeout,
//         androidUsesFineLocation: true,
//       );
//     } catch (e) {
//       messageCallback("Auto scan error: ${e.toString()}", MessageType.error);
//     }
//   }

//   Future<void> _checkPermissions() async {
//     final permissions = await [
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//       Permission.bluetoothAdvertise,
//       Permission.location,
//     ].request();

//     final allGranted = permissions.values.every((status) => status.isGranted);
//     if (!allGranted) {
//       messageCallback(
//         "Some permissions denied. App may not work properly.",
//         MessageType.warning,
//       );
//     }
//   }

//   Future<void> connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect(
//         autoConnect: false,
//         mtu: PrinterConstants.bluetoothMtu,
//       );

//       _connectionStateSubscription?.cancel();
//       _connectionStateSubscription = device.connectionState.listen((state) {
//         final isConnected = state == BluetoothConnectionState.connected;

//         if (isConnected) {
//           cubit.setBluetoothDevice(device);
//           _discoverServices(device);
//         } else {
//           cubit.setBluetoothDevice(null);
//           _writeCharacteristic = null;
//         }
//       });
//     } catch (e) {
//       messageCallback("Connection failed: ${e.toString()}", MessageType.error);
//       rethrow;
//     }
//   }

//   Future<void> _discoverServices(BluetoothDevice device) async {
//     try {
//       final services = await device.discoverServices();

//       for (final service in services) {
//         for (final characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _writeCharacteristic = characteristic;
//             break;
//           }
//         }
//         if (_writeCharacteristic != null) break;
//       }
//     } catch (e) {
//       messageCallback(
//         "Service discovery failed: ${e.toString()}",
//         MessageType.error,
//       );
//     }
//   }

//   Future<bool> isReadyToPrint() async {
//     return cubit.state.isConnected && _writeCharacteristic != null;
//   }

//   Future<void> printReceipt(ReceiptData receiptData) async {
//     if (!await isReadyToPrint()) {
//       throw Exception('Printer not ready');
//     }

//     try {
//       final bytes = await _generateReceiptBytes(receiptData);
//       await _sendDataInChunks(_writeCharacteristic!, bytes);
//     } catch (e) {
//       throw Exception('Print failed: ${e.toString()}');
//     }
//   }

//   Future<List<int>> _generateReceiptBytes(ReceiptData receiptData) async {
//     // Load image
//     final response = await http.get(
//       Uri.parse(PrinterConstants.defaultImageUrl),
//     );
//     final imageBytes = response.bodyBytes;
//     final decodedImage = img.decodeImage(imageBytes)!;

//     // Create printer generator
//     final profile = await CapabilityProfile.load();
//     final generator = Generator(PaperSize.mm58, profile);

//     // Generate receipt content
//     List<int> bytes = [];

//     // Header
//     bytes += generator.image(decodedImage);
//     bytes += generator.text(
//       receiptData.title,
//       styles: PosStyles(align: PosAlign.center, bold: true),
//     );
//     bytes += generator.text(PrinterConstants.separator);
//     bytes += generator.text("${DateTime.now()}");
//     bytes += generator.text(PrinterConstants.separator);

//     // Items
//     bytes += generator.text("Item              Price");
//     bytes += generator.text(PrinterConstants.itemSeparator);

//     for (final item in receiptData.items) {
//       bytes += generator.text(
//         "${item.name.padRight(18)}\$${item.price.toStringAsFixed(2)}",
//       );
//     }

//     // Footer
//     bytes += generator.text(PrinterConstants.separator);
//     bytes += generator.text(
//       "Total             \$${receiptData.total.toStringAsFixed(2)}",
//       styles: PosStyles(bold: true),
//     );
//     bytes += generator.text(
//       "\nThank you for shopping!\n\n\n",
//       styles: PosStyles(align: PosAlign.center),
//     );

//     return bytes;
//   }

//   Future<void> _sendDataInChunks(
//     BluetoothCharacteristic characteristic,
//     List<int> data,
//   ) async {
//     for (var i = 0; i < data.length; i += PrinterConstants.chunkSize) {
//       final end = (i + PrinterConstants.chunkSize < data.length)
//           ? i + PrinterConstants.chunkSize
//           : data.length;
//       final chunk = data.sublist(i, end);

//       await characteristic.write(chunk, withoutResponse: true);
//       await Future.delayed(PrinterConstants.chunkDelay);
//     }
//   }

//   void dispose() {
//     _scanSubscription?.cancel();
//     _adapterStateSubscription?.cancel();
//     _connectionStateSubscription?.cancel();
//     _scanningStateSubscription?.cancel();
//     FlutterBluePlus.stopScan();
//   }
// }
