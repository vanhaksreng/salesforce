import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_page_state.dart';

class BluetoothPageCubit extends Cubit<BluetoothPageState> {
  BluetoothPageCubit() : super(BluetoothPageState(isLoading: true));

  List<BluetoothDevice> _originalDevices = [];

  void setListBluetoothDevice(List<BluetoothDevice> devices) {
    _originalDevices = List.from(devices); // Store original list
    emit(state.copyWith(devices: devices));
  }

  void scaningBluetooth(bool isScan) async {
    emit(state.copyWith(isScanning: isScan, isLoading: isScan));
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

  Future<void> onSearchBlueTooth(String query) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      List<BluetoothDevice> devicesToShow;

      if (query.isEmpty || query.trim().isEmpty) {
        // If query is empty, show all original devices
        devicesToShow = List.from(_originalDevices);
      } else {
        // Filter original devices based on query (not current filtered devices)
        devicesToShow = _originalDevices
            .where(
              (d) => d.platformName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }

      emit(state.copyWith(isLoading: false, devices: devicesToShow));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void handleScanResults(List<ScanResult> scanResults) {
    final newDevices = scanResults
        .map((result) => result.device)
        .where((device) => device.platformName.isNotEmpty)
        .toList();

    final currentDevices = List<BluetoothDevice>.from(_originalDevices);

    for (final device in newDevices) {
      if (!currentDevices.any((d) => d.remoteId == device.remoteId)) {
        currentDevices.add(device);
      }
    }
    setListBluetoothDevice(currentDevices);
  }
}
