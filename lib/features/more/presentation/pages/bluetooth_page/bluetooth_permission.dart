import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPermissionManager {
  static const _permissions = [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
    Permission.location,
  ];

  Future<bool> requestPermissions() async {
    try {
      final statuses = await _permissions.request();
      return statuses.values.every((status) => status.isGranted);
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }
}
