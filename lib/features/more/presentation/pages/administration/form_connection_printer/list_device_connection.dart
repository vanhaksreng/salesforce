import 'package:flutter/material.dart';
import 'package:salesforce/features/more/presentation/pages/administration/adminstatration_helper.dart';
import 'package:salesforce/features/more/presentation/pages/administration/form_connection_printer/device_card.dart';

class BluetoothDeviceList extends StatelessWidget {
  final List<DeviceConnect> devices;
  final Function(DeviceConnect)? onDeviceTap;

  const BluetoothDeviceList({
    super.key,
    required this.devices,
    this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return BluetoothDeviceItem(device: devices[index], onTap: onDeviceTap);
      },
    );
  }
}
