import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:salesforce/features/more/domain/entities/device_info.dart';

class AdministrationState {
  final bool isLoading;
  final String? error;
  final DeviceInfo? deviceInfo;
  final BluetoothDevice? bluetoothDevice;

  const AdministrationState({
    this.isLoading = false,
    this.error,
    this.deviceInfo,
    this.bluetoothDevice,
  });

  AdministrationState copyWith({
    bool? isLoading,
    String? error,
    DeviceInfo? deviceInfo,
    BluetoothDevice? bluetoothDevice,
  }) {
    return AdministrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
    );
  }
}
