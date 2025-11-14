import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/khmer_text_render.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bluetooth_device.dart';

class PrinterManager {
  static const String _printerAddressKey = 'native_printer_address';

  bool _connected = false;
  String? _connectedAddress;
  String _statusMessage = "";

  bool get isConnected => _connected;
  String? get connectedAddress => _connectedAddress;
  String get statusMessage => _statusMessage;

  VoidCallback? onConnectionStateChanged;

  PrinterManager({this.onConnectionStateChanged});

  Future<void> initializePrinter() async {
    try {
      final storedAddress = await _getStoredAddress();
      if (storedAddress == null) return;

      final isConnected = await BluetoothPrinter.isConnected();
      if (isConnected) {
        _updateConnectionState(true, storedAddress, "Connected to printer");
        return;
      }

      final success = await BluetoothPrinter.connect(storedAddress);
      if (success) {
        _updateConnectionState(true, storedAddress, "Reconnected to printer");
      }
    } catch (e) {
      debugPrint("⚠️ Printer initialization failed: $e");
    }
  }

  Future<void> showDeviceSelector(BuildContext context) async {
    _showLoadingDialog(context);
    final devices = await BluetoothPrinter.scanDevices();

    if (!context.mounted) return;
    Navigator.pop(context);

    if (devices.isEmpty) {
      _showErrorMessage(context, "No Bluetooth devices found");
      return;
    }

    final selectedDevice = await _showDeviceDialog(context, devices);
    if (selectedDevice != null && context.mounted) {
      await _connectToPrinter(context, selectedDevice);
    }
  }

  Future<BluetoothDevice?> _showDeviceDialog(
    BuildContext context,
    List<BluetoothDevice> devices,
  ) async {
    return showDialog<BluetoothDevice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Printer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final isConnected = device.address == _connectedAddress;
              return ListTile(
                leading: Icon(
                  isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                  color: isConnected ? Colors.green : null,
                ),
                title: Text(device.name),
                subtitle: Text(device.address),
                trailing: isConnected
                    ? const Chip(
                        label: Text('Connected'),
                        backgroundColor: Colors.green,
                      )
                    : null,
                onTap: () => Navigator.pop(context, device),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToPrinter(
    BuildContext context,
    BluetoothDevice device,
  ) async {
    _updateConnectionState(false, null, "Connecting to ${device.name}...");

    final success = await BluetoothPrinter.connect(device.address);

    if (success) {
      await _saveAddress(device.address);
      _updateConnectionState(
        true,
        device.address,
        "Connected to ${device.name}",
      );
      _showSuccessMessage(context, "Connected to ${device.name}");
    } else {
      _updateConnectionState(false, null, "Failed to connect");
      _showErrorMessage(context, "Failed to connect to ${device.name}");
    }
  }

  Future<void> disconnect() async {
    await BluetoothPrinter.disconnect();
    await _clearStoredAddress();
    _updateConnectionState(false, null, "Disconnected");
  }

  void _updateConnectionState(bool connected, String? address, String message) {
    _connected = connected;
    _connectedAddress = address;
    _statusMessage = message;
    onConnectionStateChanged?.call();
  }

  Future<void> _saveAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_printerAddressKey, address);
  }

  Future<String?> _getStoredAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_printerAddressKey);
  }

  Future<void> _clearStoredAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_printerAddressKey);
  }

  Future<bool> ensurePrinterConnection() async {
    bool isConnected = await BluetoothPrinter.isConnected();

    if (!isConnected && _connectedAddress != null) {
      debugPrint("🔄 Attempting to reconnect...");
      isConnected = await BluetoothPrinter.connect(_connectedAddress!);
    }

    return isConnected;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
