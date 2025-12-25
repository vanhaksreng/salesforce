// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_page_screen.dart';

// class BluetoothConnectionManager {
//   final Map<String, BluetoothCharacteristic> _writeCharacteristics = {};
//   final Map<String, StreamSubscription<BluetoothConnectionState>>
//   _subscriptions = {};
//   final Map<String, int> _retryCount = {};
//   final Set<String> _connectingDevices = {};

//   static const int _maxRetries = 3;
//   static const Duration _connectionTimeout = Duration(seconds: 10);
//   static const Duration _retryDelay = Duration(seconds: 2);
//   static const Duration _preConnectDelay = Duration(milliseconds: 300);

//   Future<ConnectionResult> handleConnection({
//     required BluetoothDevice device,
//     required Function(BluetoothConnectionState) onStateUpdate,
//     required Function(bool) onConnectingUpdate,
//     required Function(String, bool) onMessage,
//   }) async {
//     final deviceId = device.remoteId.toString();
//     final deviceName = device.platformName.isNotEmpty
//         ? device.platformName
//         : 'Unknown Device';

//     if (_connectingDevices.contains(deviceId)) {
//       debugPrint('[BT] Already connecting $deviceName ($deviceId)');
//       return ConnectionResult.alreadyConnecting();
//     }

//     // Check current connection state (safe short read)
//     try {
//       final state = await device.connectionState.first.timeout(
//         const Duration(seconds: 2),
//         onTimeout: () => BluetoothConnectionState.disconnected,
//       );
//       if (state == BluetoothConnectionState.connected) {
//         debugPrint(
//           '[BT] Device already connected: $deviceName ($deviceId). Disconnecting now.',
//         );
//         return await _disconnect(device, deviceName, onStateUpdate, onMessage);
//       }
//     } catch (e) {
//       debugPrint('[BT] connectionState check error (ignored): $e');
//       // continue to connect
//     }

//     return await _connect(
//       device,
//       deviceName,
//       onStateUpdate,
//       onConnectingUpdate,
//       onMessage,
//     );
//   }

//   Future<ConnectionResult> _connect(
//     BluetoothDevice device,
//     String deviceName,
//     Function(BluetoothConnectionState) onStateUpdate,
//     Function(bool) onConnectingUpdate,
//     Function(String, bool) onMessage,
//   ) async {
//     final deviceId = device.remoteId.toString();
//     int currentRetry = _retryCount[deviceId] ?? 0;

//     if (currentRetry >= _maxRetries) {
//       _retryCount[deviceId] = 0;
//       final msg = 'Connection failed after $_maxRetries attempts';
//       debugPrint('[BT] $msg ($deviceName)');
//       return ConnectionResult.failure(msg);
//     }

//     _connectingDevices.add(deviceId);
//     onConnectingUpdate(true);
//     onStateUpdate(BluetoothConnectionState.connecting);

//     if (currentRetry > 0) {
//       onMessage('Retry attempt ${currentRetry + 1}/$_maxRetries', false);
//       await Future.delayed(_retryDelay);
//     }

//     _retryCount[deviceId] = currentRetry + 1;

//     try {
//       // Always stop scanning before connecting — avoids platform race conditions
//       try {
//         await FlutterBluePlus.stopScan();
//       } catch (e) {
//         debugPrint('[BT] stopScan failed (ignored): $e');
//       }

//       // small delay to avoid racing the scan/adapter
//       await Future.delayed(_preConnectDelay);

//       debugPrint(
//         '[BT] Attempting connect to $deviceName ($deviceId). Retry ${_retryCount[deviceId]}',
//       );

//       // Do the connect with a generous timeout
//       await device.connect(autoConnect: false).timeout(_connectionTimeout);

//       // Wait a small moment for connection state to stabilize
//       await Future.delayed(const Duration(milliseconds: 200));

//       // Confirm connected
//       final postState = await device.connectionState.first.timeout(
//         const Duration(seconds: 2),
//         onTimeout: () => BluetoothConnectionState.disconnected,
//       );

//       if (postState != BluetoothConnectionState.connected) {
//         throw Exception(
//           'Device did not reach connected state (state: $postState)',
//         );
//       }

//       // Setup monitoring & service discovery
//       _setupConnectionMonitoring(device, onStateUpdate);

//       await _discoverServices(device);

//       onStateUpdate(BluetoothConnectionState.connected);
//       onMessage('Connected to $deviceName', false);

//       // reset retry counter on success
//       _retryCount[deviceId] = 0;

//       return ConnectionResult.success();
//     } catch (e, st) {
//       debugPrint('[BT] Connect error for $deviceName ($deviceId): $e\n$st');
//       final retryable = _isRetryableError(e);

//       if (retryable && (_retryCount[deviceId] ?? 0) < _maxRetries) {
//         debugPrint('[BT] Will retry for $deviceName ($deviceId).');
//         // cleanup any partial subscription
//         _subscriptions[deviceId]?.cancel();
//         _subscriptions.remove(deviceId);

//         // small pause and retry recursively
//         await Future.delayed(_retryDelay);
//         return await _connect(
//           device,
//           deviceName,
//           onStateUpdate,
//           onConnectingUpdate,
//           onMessage,
//         );
//       }

//       // non-retryable or max retries reached
//       _retryCount[deviceId] = 0;
//       onStateUpdate(BluetoothConnectionState.disconnected);
//       onMessage(_getErrorMessage(e, deviceName), true);
//       return ConnectionResult.failure(_getErrorMessage(e, deviceName));
//     } finally {
//       _connectingDevices.remove(deviceId);
//       onConnectingUpdate(false);
//     }
//   }

//   Future<ConnectionResult> _disconnect(
//     BluetoothDevice device,
//     String deviceName,
//     Function(BluetoothConnectionState) onStateUpdate,
//     Function(String, bool) onMessage,
//   ) async {
//     final deviceId = device.remoteId.toString();
//     try {
//       debugPrint('[BT] Disconnecting $deviceName ($deviceId)');
//       await _subscriptions[deviceId]?.cancel();
//       _subscriptions.remove(deviceId);

//       // small grace period before disconnect
//       await Future.delayed(const Duration(milliseconds: 200));

//       await device.disconnect();

//       onStateUpdate(BluetoothConnectionState.disconnected);
//       onMessage('Disconnected from $deviceName', false);
//       return ConnectionResult.success();
//     } catch (e) {
//       debugPrint('[BT] Disconnect error for $deviceName: $e');
//       onStateUpdate(BluetoothConnectionState.disconnected);
//       return ConnectionResult.failure('Error disconnecting from $deviceName');
//     }
//   }

//   Future<void> _discoverServices(BluetoothDevice device) async {
//     try {
//       final services = await device.discoverServices();
//       BluetoothCharacteristic? writeCharacteristic;

//       outerLoop:
//       for (final service in services) {
//         for (final characteristic in service.characteristics) {
//           if (characteristic.properties.write ||
//               characteristic.properties.writeWithoutResponse) {
//             writeCharacteristic = characteristic;
//             break outerLoop;
//           }
//         }
//       }

//       if (writeCharacteristic != null) {
//         _writeCharacteristics[device.remoteId.toString()] = writeCharacteristic;
//         debugPrint('[BT] Write characteristic cached for ${device.remoteId}');
//       } else {
//         debugPrint(
//           '[BT] No writable characteristic found for ${device.remoteId}',
//         );
//       }
//     } catch (e) {
//       debugPrint('[BT] Service discovery error: $e');
//       // non-fatal: we still consider connected even if discovery or char detection fails
//     }
//   }

//   void _setupConnectionMonitoring(
//     BluetoothDevice device,
//     Function(BluetoothConnectionState) onStateUpdate,
//   ) {
//     final deviceId = device.remoteId.toString();

//     try {
//       _subscriptions[deviceId]?.cancel();
//     } catch (_) {}

//     _subscriptions[deviceId] = device.connectionState.listen(
//       (state) {
//         debugPrint('[BT] Connection state change for $deviceId: $state');
//         onStateUpdate(state);
//         if (state == BluetoothConnectionState.disconnected) {
//           _subscriptions[deviceId]?.cancel();
//           _subscriptions.remove(deviceId);
//         }
//       },
//       onError: (error) {
//         debugPrint('[BT] Connection monitoring error for $deviceId: $error');
//         onStateUpdate(BluetoothConnectionState.disconnected);
//         _subscriptions[deviceId]?.cancel();
//         _subscriptions.remove(deviceId);
//       },
//     );
//   }

//   bool _isRetryableError(dynamic error) {
//     final err = error?.toString()?.toLowerCase() ?? '';
//     return error is TimeoutException ||
//         err.contains('133') ||
//         err.contains('gatt') ||
//         err.contains('connection') ||
//         err.contains('timeout') ||
//         err.contains('failed') ||
//         err.contains('android');
//   }

//   String _getErrorMessage(dynamic error, String deviceName) {
//     final eStr = error?.toString() ?? '';
//     if (eStr.contains('133')) {
//       return 'Connection failed: Device communication error';
//     } else if (error is TimeoutException) {
//       return 'Connection failed: Timeout';
//     } else {
//       return 'Connection failed: Unable to connect to $deviceName';
//     }
//   }

//   bool isConnecting(String deviceId) => _connectingDevices.contains(deviceId);
//   int getRetryCount(String deviceId) => _retryCount[deviceId] ?? 0;

//   void clearAll() {
//     for (final subscription in _subscriptions.values) {
//       try {
//         subscription.cancel();
//       } catch (_) {}
//     }
//     _subscriptions.clear();
//     _writeCharacteristics.clear();
//     _retryCount.clear();
//     _connectingDevices.clear();
//   }

//   void dispose() {
//     clearAll();
//   }
// }
