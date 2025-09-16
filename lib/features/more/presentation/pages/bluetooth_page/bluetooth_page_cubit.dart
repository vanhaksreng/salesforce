import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_page_state.dart';

class BluetoothPageCubit extends Cubit<BluetoothPageState> {
  BluetoothPageCubit() : super(BluetoothPageState(isLoading: true));

  void scaningBluetooth(bool isScan) async {
    emit(state.copyWith(isScanning: isScan, isLoading: false));
  }

  void setConnectingBluetooth(bool isConnect) {
    emit(state.copyWith(isConnected: isConnect, isLoading: false));
  }

  void setBluetoothAdapterState(BluetoothAdapterState adapter) {
    emit(state.copyWith(adapterState: adapter, isLoading: false));
  }

  void setBluetoothDevice(BluetoothDevice? device) {
    emit(state.copyWith(connectedDevice: device, isLoading: false));
  }

  void setBluetoothActionState(BluetoothConnectionState actionState) {
    emit(state.copyWith(bluetoothActionState: actionState, isLoading: false));
  }

  handleScanResults(List<ScanResult> results) {
    final List<BluetoothDevice> devices = List.from(state.devices);

    final newDevices = results
        .map((result) => result.device)
        .where(
          (device) =>
              !devices.contains(device) && device.platformName.isNotEmpty,
        )
        .toList();

    if (newDevices.isNotEmpty) {
      devices.addAll(newDevices);

      emit(state.copyWith(devices: devices));
    }
  }

  void setListBluetoothDevice(List<BluetoothDevice>? devices) {
    emit(state.copyWith(devices: devices, isLoading: false));
  }
}
