import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_mm80.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class PrinterService {
  BluetoothDevice? bluetoothDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  final Map<String, BluetoothCharacteristic> _writeCharacteristics = {};

  bool _isPrinting = false;
  bool _shouldStop = false;
  int _lastBytesSent = 0; // Tracks bytes sent for timeout
  Timer? _timeoutTimer; // New: Timeout timer

  bool get isConnected => bluetoothDevice?.isConnected ?? false;
  bool get canPrint => isConnected && _writeCharacteristic != null;
  bool get isPrinting => _isPrinting;

  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      BluetoothCharacteristic? writeCharacteristic;

      outerLoop:
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            writeCharacteristic = characteristic;
            debugPrint('Found writable characteristic: ${characteristic.uuid}');
            break outerLoop;
          }
        }
      }

      if (writeCharacteristic != null) {
        _writeCharacteristics[device.remoteId.toString()] = writeCharacteristic;
        _writeCharacteristic = writeCharacteristic;
        debugPrint('Write characteristic configured successfully');
      } else {
        throw Exception('No writable characteristic found');
      }
    } catch (e) {
      debugPrint('Service discovery error: $e');
      rethrow;
    }
  }

  /// Emergency stop with immediate effect.
  Future<void> emergencyStop() async {
    if (_writeCharacteristic == null) {
      debugPrint('No write characteristic available for emergency stop');
      return;
    }

    try {
      debugPrint('Executing emergency stop...');
      _shouldStop = true;
      _timeoutTimer?.cancel(); // Cancel timer on manual stop

      final stopCommands = [
        0x18, // Cancel (CAN) - stops current operation
        0x1B, 0x40, // Initialize printer (ESC @)
      ];

      await _writeCharacteristic!.write(stopCommands, withoutResponse: false);
      await Future.delayed(const Duration(milliseconds: 10));

      final cutCommands = [
        0x1D, 0x56, 0x00, // Full cut
        0x0C, // Form feed to clear buffer
      ];

      await _writeCharacteristic!.write(cutCommands, withoutResponse: false);

      _isPrinting = false;
      _shouldStop = false;

      debugPrint('Emergency stop commands sent with immediate effect');
    } catch (e) {
      debugPrint('Emergency stop failed: $e');
      _isPrinting = false;
      _shouldStop = false;
    }
  }

  /// Enhanced data sending with stop and timeout checks.
  Future<void> _sendDataOptimized(
    BluetoothCharacteristic characteristic,
    List<int> data,
  ) async {
    const int chunkSize = 180;
    final totalBytes = data.length;
    int bytesSent = 0;

    debugPrint('Sending $totalBytes bytes...');
    _isPrinting = true;
    _shouldStop = false;
    _lastBytesSent = 0; // Reset byte counter
    _startTimeoutMonitor(); // Start the timeout monitor

    try {
      while (bytesSent < totalBytes && !_shouldStop) {
        final remaining = totalBytes - bytesSent;
        final size = remaining < chunkSize ? remaining : chunkSize;

        final chunk = data.sublist(bytesSent, bytesSent + size);

        await characteristic.write(chunk, withoutResponse: true);

        bytesSent += size;
        _lastBytesSent = bytesSent; // Update last bytes sent

        if (size > 150) {
          await Future.delayed(const Duration(milliseconds: 2));
        }
      }

      if (!_shouldStop) {
        await _sendTerminationCommands(characteristic);
        debugPrint("Print completed successfully ($bytesSent/$totalBytes)");
      } else {
        debugPrint("Print job was manually or automatically stopped.");
      }
    } catch (e) {
      debugPrint("Error while printing: $e");
      rethrow;
    } finally {
      _timeoutTimer?.cancel();
      _isPrinting = false;
      _shouldStop = false;
      _lastBytesSent = 0;
    }
  }

  /// New: Starts a timer to monitor print progress.
  void _startTimeoutMonitor() {
    _timeoutTimer?.cancel(); // Cancel any existing timer
    _timeoutTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // If no progress has been made in the last 5 seconds
      if (_isPrinting && _lastBytesSent == 0) {
        debugPrint('Print job timed out. Initiating emergency stop.');
        emergencyStop();
        timer.cancel(); // Stop monitoring
      } else {
        // Reset the counter if progress is being made
        _lastBytesSent = 0;
      }
    });
  }

  Future<void> _sendTerminationCommands(
    BluetoothCharacteristic characteristic,
  ) async {
    final commands = [
      [0x1B, 0x64, 0x03], // Feed 3 lines
      [0x1D, 0x56, 0x00], // Full cut
      [0x1B, 0x40], // Reset/init printer
    ];

    for (var cmd in commands) {
      await characteristic.write(cmd, withoutResponse: false);
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<bool> connectToDevice() async {
    // ... existing code ...
    try {
      List<BluetoothDevice> devices = FlutterBluePlus.connectedDevices;

      if (devices.isEmpty) {
        debugPrint('No connected Bluetooth devices found');
        return false;
      }

      bluetoothDevice = devices.first;

      if (!bluetoothDevice!.isConnected) {
        debugPrint('Device is not connected, attempting to connect...');
        await bluetoothDevice!.connect(timeout: const Duration(seconds: 10));
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await _discoverServices(bluetoothDevice!);

      if (_writeCharacteristic != null) {
        try {
          await clearPrinterBuffer();
          debugPrint('Printer initialized and buffer cleared');
        } catch (e) {
          debugPrint('Printer initialization failed: $e');
        }
      }

      return canPrint;
    } catch (e) {
      debugPrint('Connection error: $e');
      return false;
    }
  }

  Future<bool> printReceiptFast({
    SaleDetail? detail,
    CompanyInformation? companyInfo,
    bool validateData = true,
  }) async {
    if (_isPrinting) {
      debugPrint('Printer is busy, cannot start new print job');
      return false;
    }

    if (!canPrint) {
      debugPrint('Attempting to reconnect to printer...');
      final connected = await connectToDevice();
      if (!connected) {
        throw Exception(
          'Not connected to a printer or no writable characteristic found',
        );
      }
    }

    if (bluetoothDevice != null && !bluetoothDevice!.isConnected) {
      debugPrint('Device disconnected during print, reconnecting...');
      try {
        await bluetoothDevice!.connect(timeout: const Duration(seconds: 5));
        await _discoverServices(bluetoothDevice!);
      } catch (e) {
        throw Exception('Failed to reconnect to printer: $e');
      }
    }

    try {
      debugPrint('Generating receipt bytes...');
      final bytes = await ReceiptMm80.generateCustomReceiptBytes(
        detail: detail,
        companyInfo: companyInfo,
      );

      if (validateData && !_validateReceiptData(bytes)) {
        throw Exception('Receipt data validation failed');
      }

      debugPrint('Receipt size: ${bytes.length} bytes');

      await _sendDataOptimized(_writeCharacteristic!, bytes);

      if (!_shouldStop) {
        await Future.delayed(const Duration(milliseconds: 1000));
        debugPrint('Receipt printed successfully!');
      }

      return !_shouldStop;
    } catch (e) {
      debugPrint('Printing failed: $e');

      if (_writeCharacteristic != null) {
        try {
          await clearPrinterBuffer();
        } catch (resetError) {
          debugPrint('Failed to reset printer: $resetError');
        }
      }

      _isPrinting = false;
      _shouldStop = false;
      rethrow;
    }
  }

  bool _validateReceiptData(List<int> bytes) {
    // ... existing code ...
    if (bytes.isEmpty) {
      debugPrint('ERROR: Receipt data is empty');
      return false;
    }

    if (bytes.length > 50000) {
      debugPrint('WARNING: Receipt data is very large (${bytes.length} bytes)');
    }

    if (bytes.length > 1000) {
      final sample = bytes.take(100).toList();
      final firstByte = sample.first;
      final allSame = sample.every((byte) => byte == firstByte);

      if (allSame) {
        debugPrint('ERROR: Receipt data appears to be corrupted');
        return false;
      }
    }

    debugPrint('Receipt data validation passed: ${bytes.length} bytes');
    return true;
  }

  Future<void> stopPrinting() async {
    if (!_isPrinting) {
      debugPrint('No active print job to stop');
      return;
    }

    debugPrint('Stopping current print job...');
    await emergencyStop();
  }

  Map<String, dynamic> getPrintingStatus() {
    return {
      'isPrinting': _isPrinting,
      'shouldStop': _shouldStop,
      'isConnected': isConnected,
      'canPrint': canPrint,
    };
  }

  void dispose() {
    _shouldStop = true;
    _isPrinting = false;
    _timeoutTimer?.cancel();
    _writeCharacteristics.clear();
    _writeCharacteristic = null;
    bluetoothDevice = null;
    debugPrint('PrinterService disposed');
  }

  Future<void> clearPrinterBuffer() async {
    // ... existing code ...
    if (_writeCharacteristic == null) return;

    try {
      debugPrint('Clearing printer buffer...');

      final clearCommands = [
        0x18, // Cancel current job
        0x1B, 0x40, // Initialize printer
        0x0C, // Form feed to flush buffer
        0x1B, 0x40, // Initialize again
      ];

      await _writeCharacteristic!.write(clearCommands, withoutResponse: false);
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Printer buffer cleared');
    } catch (e) {
      debugPrint('Failed to clear printer buffer: $e');
    }
  }

  Future<bool> hasDataInBuffer() async {
    // ... existing code ...
    if (_writeCharacteristic == null) return false;

    try {
      final statusRequest = [0x10, 0x04, 0x01]; // DLE EOT 1
      await _writeCharacteristic!.write(statusRequest, withoutResponse: false);
      await Future.delayed(const Duration(milliseconds: 100));
      return false;
    } catch (e) {
      debugPrint('Buffer status check failed: $e');
      return false;
    }
  }
}
