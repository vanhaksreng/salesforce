import 'package:flutter/material.dart';
import 'package:salesforce/features/more/presentation/pages/administration/form_connection_printer/device_card.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

class BluetoothDeviceList extends StatelessWidget {
  final List<DevicePrinter> devices;
  final Function(DevicePrinter)? onDeviceTap;
  final Function(DevicePrinter)? onConnect;
  final Function(DevicePrinter)? onDisconnect;
  final Function(DevicePrinter)? onDelete;
  final DevicePrinter? selectedDevice;
  final String? connectingDeviceId;

  const BluetoothDeviceList({
    super.key,
    required this.devices,
    this.onDeviceTap,
    this.onConnect,
    this.onDisconnect,
    this.selectedDevice,
    this.onDelete,
    this.connectingDeviceId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return BluetoothDeviceItem(
          device: device,
          onTap: onDeviceTap,
          onConnect: onConnect,
          onDisconnect: onDisconnect,
          onDelete: onDelete,
          isConnected: selectedDevice?.macAddress == device.macAddress,
          isConnecting: connectingDeviceId == device.macAddress,
        );
      },
    );
  }
}
