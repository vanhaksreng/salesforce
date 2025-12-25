// class BluetoothDeviceCus {
//   final String bluetoothName;
//   final String macAdddress;

//   BluetoothDeviceCus({required this.bluetoothName, required this.macAdddress});
// }

import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';

class DeviceConnect {
  final String name;
  final String model;
  final PrinterDeviceDiscover connectorDevice;
  final double paperWidth;
  final bool isConnected;
  final bool isPaired;

  DeviceConnect({
    required this.name,
    required this.model,
    required this.connectorDevice,
    required this.paperWidth,
    this.isConnected = false,
    this.isPaired = false,
  });
}
