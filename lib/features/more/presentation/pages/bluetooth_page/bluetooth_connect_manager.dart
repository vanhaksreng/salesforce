import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_page_screen.dart';

class BluetoothConnectionManager {
  final Map<String, BluetoothCharacteristic> _writeCharacteristics = {};
  final Map<String, StreamSubscription<BluetoothConnectionState>>
  _subscriptions = {};
  final Map<String, int> _retryCount = {};
  final Set<String> _connectingDevices = {};

  static const int _maxRetries = 3;
  static const Duration _connectionTimeout = Duration(seconds: 3);
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<ConnectionResult> handleConnection({
    required BluetoothDevice device,
    required Function(BluetoothConnectionState) onStateUpdate,
    required Function(bool) onConnectingUpdate,
    required Function(String, bool) onMessage,
  }) async {
    final deviceId = device.remoteId.toString();
    final deviceName = device.platformName.isNotEmpty
        ? device.platformName
        : 'Unknown Device';

    if (_connectingDevices.contains(deviceId)) {
      return ConnectionResult.alreadyConnecting();
    }

    try {
      final connectionState = await device.connectionState.first.timeout(
        const Duration(seconds: 2),
      );

      if (connectionState == BluetoothConnectionState.connected) {
        return await _disconnect(device, deviceName, onStateUpdate, onMessage);
      } else {
        return await _connect(
          device,
          deviceName,
          onStateUpdate,
          onConnectingUpdate,
          onMessage,
        );
      }
    } catch (e) {
      return await _connect(
        device,
        deviceName,
        onStateUpdate,
        onConnectingUpdate,
        onMessage,
      );
    }
  }

  Future<ConnectionResult> _connect(
    BluetoothDevice device,
    String deviceName,
    Function(BluetoothConnectionState) onStateUpdate,
    Function(bool) onConnectingUpdate,
    Function(String, bool) onMessage,
  ) async {
    final deviceId = device.remoteId.toString();
    int currentRetry = _retryCount[deviceId] ?? 0;

    if (currentRetry >= _maxRetries) {
      _retryCount[deviceId] = 0;
      return ConnectionResult.failure(
        'Connection failed after $_maxRetries attempts',
      );
    }

    _connectingDevices.add(deviceId);
    onConnectingUpdate(true);

    try {
      if (currentRetry > 0) {
        onMessage('Retry attempt $currentRetry/$_maxRetries', false);
        await Future.delayed(_retryDelay);
      }

      _retryCount[deviceId] = currentRetry + 1;

      await _attemptConnection(device);
      _retryCount[deviceId] = 0;

      onStateUpdate(BluetoothConnectionState.connected);
      _setupConnectionMonitoring(device, onStateUpdate);
      await _discoverServices(device);

      onMessage('Connected to $deviceName', false);
      return ConnectionResult.success();
    } catch (e) {
      if (_retryCount[deviceId]! < _maxRetries && _isRetryableError(e)) {
        return await _connect(
          device,
          deviceName,
          onStateUpdate,
          onConnectingUpdate,
          onMessage,
        );
      } else {
        _retryCount[deviceId] = 0;
        onStateUpdate(BluetoothConnectionState.disconnected);
        return ConnectionResult.failure(_getErrorMessage(e, deviceName));
      }
    } finally {
      _connectingDevices.remove(deviceId);
      onConnectingUpdate(false);
    }
  }

  Future<ConnectionResult> _disconnect(
    BluetoothDevice device,
    String deviceName,
    Function(BluetoothConnectionState) onStateUpdate,
    Function(String, bool) onMessage,
  ) async {
    final deviceId = device.remoteId.toString();

    try {
      await _subscriptions[deviceId]?.cancel();
      _subscriptions.remove(deviceId);

      await Future.delayed(const Duration(milliseconds: 500));
      await device.disconnect();

      onStateUpdate(BluetoothConnectionState.disconnected);
      onMessage('Disconnected from $deviceName', false);

      return ConnectionResult.success();
    } catch (e) {
      onStateUpdate(BluetoothConnectionState.disconnected);
      return ConnectionResult.failure('Error disconnecting from $deviceName');
    }
  }

  Future<void> _attemptConnection(BluetoothDevice device) async {
    try {
      await device.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Disconnect error (ignored): $e');
    }

    await device
        .connect(autoConnect: false, mtu: null)
        .timeout(_connectionTimeout);

    try {
      await device.requestMtu(512);
    } catch (e) {
      debugPrint('MTU request failed: $e');
    }
  }

  void _setupConnectionMonitoring(
    BluetoothDevice device,
    Function(BluetoothConnectionState) onStateUpdate,
  ) {
    final deviceId = device.remoteId.toString();

    _subscriptions[deviceId]?.cancel();
    _subscriptions[deviceId] = device.connectionState.listen(
      (state) {
        if (state == BluetoothConnectionState.disconnected) {
          onStateUpdate(BluetoothConnectionState.disconnected);
          _subscriptions[deviceId]?.cancel();
          _subscriptions.remove(deviceId);
        }
      },
      onError: (error) {
        debugPrint('Connection monitoring error: $error');
        onStateUpdate(BluetoothConnectionState.disconnected);
      },
    );
  }

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
            break outerLoop;
          }
        }
      }

      if (writeCharacteristic != null) {
        _writeCharacteristics[device.remoteId.toString()] = writeCharacteristic;
      }
    } catch (e) {
      debugPrint('Service discovery error: $e');
    }
  }

  bool _isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return error is TimeoutException ||
        errorString.contains('133') ||
        errorString.contains('gatt') ||
        errorString.contains('connection') ||
        errorString.contains('timeout');
  }

  String _getErrorMessage(dynamic error, String deviceName) {
    if (error.toString().contains('133')) {
      return 'Connection failed: Device communication error';
    } else if (error is TimeoutException) {
      return 'Connection failed: Timeout';
    } else {
      return 'Connection failed: Unable to connect to $deviceName';
    }
  }

  bool isConnecting(String deviceId) => _connectingDevices.contains(deviceId);
  int getRetryCount(String deviceId) => _retryCount[deviceId] ?? 0;

  void clearAll() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _writeCharacteristics.clear();
    _retryCount.clear();
    _connectingDevices.clear();
  }

  void dispose() {
    clearAll();
  }
}
