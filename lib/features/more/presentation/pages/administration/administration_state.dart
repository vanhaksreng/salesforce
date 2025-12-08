// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:salesforce/features/more/domain/entities/device_info.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_permission_handler.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

class AdministrationState {
  final bool isLoading;
  final bool isFetching;
  final String? error;
  final DeviceInfo? deviceInfo;
  final bool hasPermission;
  final BluetoothStatus? status;
  final bool isScanning;
  final DateTime? lastScanTime;
  final bool isIminDevice;
  final List<DevicePrinter> devicePrinter;
  final DevicePrinter? selectedDevice;
  final String? connectingDeviceId;
  final List<PrinterDeviceDiscover> printerDeviceDiscover;

  const AdministrationState({
    this.isLoading = false,
    this.isFetching = false,
    this.isScanning = false,
    this.status,
    this.hasPermission = false,
    this.error,
    this.lastScanTime,
    this.deviceInfo,
    // this.bluetoothDevice,
    this.selectedDevice,
    this.connectingDeviceId,
    this.devicePrinter = const [],
    this.printerDeviceDiscover = const [],
    this.isIminDevice = false,
  });

  AdministrationState copyWith({
    bool? isLoading,
    bool? isFetching,
    String? error,
    BluetoothStatus? status,
    bool? hasPermission,
    DateTime? lastScanTime,
    DeviceInfo? deviceInfo,
    // BluetoothInfo? bluetoothDevice,
    bool? isIminDevice,
    bool? isScanning,
    List<DevicePrinter>? devicePrinter,
    List<PrinterDeviceDiscover>? printerDeviceDiscover,
    DevicePrinter? selectedDevice,
    String? connectingDeviceId,
    bool clearSelectedDevice = false, // Add this flag
    bool clearConnectingDeviceId = false, // Add this flag
  }) {
    return AdministrationState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      isFetching: isFetching ?? this.isFetching,
      devicePrinter: devicePrinter ?? this.devicePrinter,
      error: error ?? this.error,
      hasPermission: hasPermission ?? this.hasPermission,
      isScanning: isScanning ?? this.isScanning,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      lastScanTime: lastScanTime ?? this.lastScanTime,
      // bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
      isIminDevice: isIminDevice ?? this.isIminDevice,
      printerDeviceDiscover:
          printerDeviceDiscover ?? this.printerDeviceDiscover,
      selectedDevice: clearSelectedDevice
          ? null
          : (selectedDevice ?? this.selectedDevice),
      connectingDeviceId: clearConnectingDeviceId
          ? null
          : (connectingDeviceId ?? this.connectingDeviceId),
    );
  }

  @override
  List<Object?> get props => [
    devicePrinter,
    selectedDevice,
    connectingDeviceId,
    isLoading,
  ];
}
