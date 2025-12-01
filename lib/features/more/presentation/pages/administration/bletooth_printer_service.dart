import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:salesforce/core/data/models/extension/device_printer_extention.dart';
import 'package:salesforce/features/more/presentation/pages/administration/device_printer_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service to manage Bluetooth printer connection across the app
class BluetoothPrinterService with DevicePrinterMixin {
  static final BluetoothPrinterService _instance =
      BluetoothPrinterService._internal();
  factory BluetoothPrinterService() => _instance;
  BluetoothPrinterService._internal();

  DevicePrinter? _connectedDevice;
  bool _isConnected = false;
  bool _isConnecting = false;

  // Stream controllers for reactive updates
  final _connectionController = StreamController<DevicePrinter?>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  Stream<DevicePrinter?> get connectionStream => _connectionController.stream;
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  DevicePrinter? get connectedDevice => _connectedDevice;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  /// Initialize and attempt to reconnect to previously saved printer
  Future<void> initialize() async {
    try {
      final savedPrinter = await loadSelectedPrinter();

      if (savedPrinter != null) {
        await connect(savedPrinter, autoReconnect: true);
      }
    } catch (e) {
      debugPrint('Failed to initialize printer service: $e');
    }
  }

  /// Connect to a printer device
  Future<bool> connect(
    DevicePrinter device, {
    bool autoReconnect = false,
  }) async {
    // Already connected to this device
    if (_isConnected && _connectedDevice?.macAddress == device.macAddress) {
      return true;
    }

    // Prevent multiple simultaneous connection attempts
    if (_isConnecting) {
      return false;
    }

    _isConnecting = true;
    _statusController.add(ConnectionStatus.connecting);

    try {
      // Disconnect from previous device if any
      if (_isConnected && _connectedDevice != null) {
        await disconnect(silent: true);
      }

      // Attempt connection
      final result = await ThermalPrinter.connect(
        PrinterDeviceDiscover(
          address: device.macAddress,
          name: device.originDeviceName,
          type: device.typeConnection == "bluetooth"
              ? ConnectionType.bluetooth
              : ConnectionType.usb,
        ),
      );

      if (result) {
        _connectedDevice = device;
        _isConnected = true;

        // Save to preferences for auto-reconnect
        if (!autoReconnect) {
          await _saveSelectedPrinter(device);
        }

        _connectionController.add(_connectedDevice);
        _statusController.add(ConnectionStatus.connected);

        debugPrint('✅ Connected to: ${device.deviceName}');
        return true;
      } else {
        _statusController.add(ConnectionStatus.disconnected);

        if (autoReconnect) {
          await clearSelectedPrinter();
        }

        return false;
      }
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      _statusController.add(ConnectionStatus.error);

      if (autoReconnect) {
        await clearSelectedPrinter();
      }

      return false;
    } finally {
      _isConnecting = false;
    }
  }

  /// Disconnect from current printer
  Future<bool> disconnect({bool silent = false}) async {
    if (_connectedDevice == null) return true;

    try {
      final result = await ThermalPrinter.disconnect();

      if (result || silent) {
        final deviceName = _connectedDevice?.deviceName ?? 'Unknown';

        _connectedDevice = null;
        _isConnected = false;

        if (!silent) {
          await clearSelectedPrinter();
        }

        _connectionController.add(null);
        _statusController.add(ConnectionStatus.disconnected);

        debugPrint('🔌 Disconnected from: $deviceName');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Disconnection failed: $e');
      return false;
    }
  }

  // Private helper methods
  Future<void> _saveSelectedPrinter(DevicePrinter device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceJson = jsonEncode(device.toMap());
      await prefs.setString('selected_printer', deviceJson);
    } catch (e) {
      debugPrint('Failed to save printer: $e');
    }
  }

  // Future<DevicePrinter?> _loadSelectedPrinter() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final deviceJson = prefs.getString('selected_printer');

  //     if (deviceJson != null) {
  //       final deviceMap = jsonDecode(deviceJson) as Map<String, dynamic>;
  //       return DevicePrinter.fromMap(deviceMap);
  //     }
  //   } catch (e) {
  //     debugPrint('Failed to load printer: $e');
  //   }
  //   return null;
  // }

  // Future<void> _clearSelectedPrinter() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.remove('selected_printer');
  //   } catch (e) {
  //     debugPrint('Failed to clear printer: $e');
  //   }
  // }

  /// Dispose streams (call this when app is closing)
  void dispose() {
    _connectionController.close();
    _statusController.close();
  }
}

/// Connection status enum
enum ConnectionStatus { disconnected, connecting, connected, error }
