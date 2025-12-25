// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class BluetoothPageState {
//   final bool isLoading;
//   final String? error;
//   final bool isScanning;
//   final bool isConnected;
//   final BluetoothAdapterState adapterState;
//   final BluetoothDevice? connectedDevice;
//   final BluetoothConnectionState? bluetoothActionState;
//   final List<BluetoothDevice> devices;

//   const BluetoothPageState({
//     this.isLoading = false,
//     this.error,
//     this.isScanning = false,
//     this.isConnected = false,
//     this.adapterState = BluetoothAdapterState.unknown,
//     this.connectedDevice,
//     this.bluetoothActionState = BluetoothConnectionState.disconnected,
//     this.devices = const [],
//   });

//   BluetoothPageState copyWith({
//     bool? isLoading,
//     String? error,
//     bool? isScanning,
//     bool? isConnected,
//     BluetoothAdapterState? adapterState,
//     BluetoothDevice? connectedDevice,
//     List<BluetoothDevice>? devices,
//     BluetoothConnectionState? bluetoothActionState,
//   }) {
//     return BluetoothPageState(
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//       isScanning: isScanning ?? this.isScanning,
//       isConnected: isConnected ?? this.isConnected,
//       adapterState: adapterState ?? this.adapterState,
//       connectedDevice: connectedDevice ?? this.connectedDevice,
//       devices: devices ?? this.devices,
//       bluetoothActionState: bluetoothActionState ?? this.bluetoothActionState,
//     );
//   }
// }
