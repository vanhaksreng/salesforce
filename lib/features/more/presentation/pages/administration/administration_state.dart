import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:salesforce/features/more/domain/entities/device_info.dart';

class AdministrationState {
  final bool isLoading;
  final String? error;
  final DeviceInfo? deviceInfo;
  final BluetoothInfo? bluetoothDevice;
  final bool isIminDevice;

  const AdministrationState({
    this.isLoading = false,
    this.error,
    this.deviceInfo,
    this.bluetoothDevice,
    this.isIminDevice = false,
  });

  AdministrationState copyWith({
    bool? isLoading,
    String? error,
    DeviceInfo? deviceInfo,
    BluetoothInfo? bluetoothDevice,
    bool? isIminDevice,
  }) {
    return AdministrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
      isIminDevice: isIminDevice ?? this.isIminDevice,
    );
  }
}
