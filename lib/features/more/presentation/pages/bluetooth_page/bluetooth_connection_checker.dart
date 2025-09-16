import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothConnectionChecker {
  // Method 1: Check specific device connection status
  static Future<bool> isDeviceConnected(BluetoothDevice device) async {
    try {
      final connectionState = await device.connectionState.first;
      return connectionState == BluetoothConnectionState.connected;
    } catch (e) {
      print('Error checking device connection: $e');
      return false;
    }
  }

  // Method 2: Get current connection state as stream
  static Stream<bool> deviceConnectionStream(BluetoothDevice device) {
    return device.connectionState.map(
      (state) => state == BluetoothConnectionState.connected,
    );
  }

  // Method 3: Check if any devices are connected
  static Future<bool> hasAnyConnectedDevice() async {
    try {
      final connectedDevices = await FlutterBluePlus.connectedDevices;
      return connectedDevices.isNotEmpty;
    } catch (e) {
      print('Error getting connected devices: $e');
      return false;
    }
  }

  // Method 4: Get all connected devices
  static Future<List<BluetoothDevice>> getConnectedDevices() async {
    try {
      return await FlutterBluePlus.connectedDevices;
    } catch (e) {
      print('Error getting connected devices: $e');
      return [];
    }
  }

  // Method 5: Check connection with timeout
  static Future<bool> isDeviceConnectedWithTimeout(
    BluetoothDevice device, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      final connectionState = await device.connectionState.first.timeout(
        timeout,
      );
      return connectionState == BluetoothConnectionState.connected;
    } catch (e) {
      print('Connection check timeout or error: $e');
      return false;
    }
  }

  // Method 6: Comprehensive device status checker
  static Future<DeviceConnectionInfo> getDeviceConnectionInfo(
    BluetoothDevice device,
  ) async {
    try {
      final connectionState = await device.connectionState.first;
      final isConnected = connectionState == BluetoothConnectionState.connected;

      // Additional info if connected
      int? mtu;
      List<BluetoothService> services = [];

      if (isConnected) {
        try {
          mtu = await device.mtu.first;
          services = await device.discoverServices();
        } catch (e) {
          print('Error getting additional device info: $e');
        }
      }

      return DeviceConnectionInfo(
        device: device,
        connectionState: connectionState,
        isConnected: isConnected,
        mtu: mtu,
        services: services,
      );
    } catch (e) {
      print('Error getting device connection info: $e');
      return DeviceConnectionInfo(
        device: device,
        connectionState: BluetoothConnectionState.disconnected,
        isConnected: false,
      );
    }
  }

  // Method 7: Periodic connection checker
  static Stream<bool> periodicConnectionCheck(
    BluetoothDevice device, {
    Duration interval = const Duration(seconds: 5),
  }) {
    return Stream.periodic(interval).asyncMap((_) => isDeviceConnected(device));
  }

  // Method 8: Check multiple devices at once
  static Future<Map<BluetoothDevice, bool>> checkMultipleDevices(
    List<BluetoothDevice> devices,
  ) async {
    final results = <BluetoothDevice, bool>{};

    await Future.wait(
      devices.map((device) async {
        results[device] = await isDeviceConnected(device);
      }),
    );

    return results;
  }
}

// Helper class to hold comprehensive device connection information
class DeviceConnectionInfo {
  final BluetoothDevice device;
  final BluetoothConnectionState connectionState;
  final bool isConnected;
  final int? mtu;
  final List<BluetoothService> services;

  DeviceConnectionInfo({
    required this.device,
    required this.connectionState,
    required this.isConnected,
    this.mtu,
    this.services = const [],
  });

  String get deviceName =>
      device.platformName.isNotEmpty ? device.platformName : 'Unknown Device';

  String get deviceId => device.remoteId.toString();

  bool get hasServices => services.isNotEmpty;

  String get statusText {
    switch (connectionState) {
      case BluetoothConnectionState.connected:
        return 'Connected';
      case BluetoothConnectionState.connecting:
        return 'Connecting...';
      case BluetoothConnectionState.disconnecting:
        return 'Disconnecting...';
      case BluetoothConnectionState.disconnected:
        return 'Disconnected';
    }
  }
}
