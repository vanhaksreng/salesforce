import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class BluetoothPermissionHandler {
  static final BluetoothPermissionHandler _instance =
      BluetoothPermissionHandler._internal();
  factory BluetoothPermissionHandler() => _instance;
  BluetoothPermissionHandler._internal() {
    _setupStateListener();
  }

  static const MethodChannel _channel = MethodChannel('bluetooth_permissions');

  // NEW: Callback for Bluetooth state changes (iOS)
  Function(bool isEnabled)? onBluetoothStateChanged;

  //  Setup listener for iOS state changes
  void _setupStateListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onBluetoothStateChanged') {
        final bool isEnabled = call.arguments['isEnabled'] as bool? ?? false;
        final String state = call.arguments['state'] as String? ?? 'unknown';

        debugPrint('Bluetooth state changed: $state (enabled: $isEnabled)');

        // Call callback if set
        onBluetoothStateChanged?.call(isEnabled);
      }
    });
  }

  // Check if Bluetooth permissions are granted
  Future<bool> hasPermissions() async {
    try {
      final bool hasPermission = await _channel.invokeMethod(
        'checkBluetoothPermissions',
      );
      return hasPermission;
    } catch (e) {
      debugPrint('Error checking Bluetooth permissions: $e');
      return false;
    }
  }

  // Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    try {
      final bool alreadyGranted = await hasPermissions();
      if (alreadyGranted) {
        debugPrint('✅ Bluetooth permissions already granted');
        return true;
      }

      await _channel.invokeMethod('requestBluetoothPermissions');
      await Future.delayed(Duration(milliseconds: Platform.isIOS ? 1000 : 500));

      return await hasPermissions();
    } catch (e) {
      debugPrint('Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  // Check if Bluetooth is enabled (ON/OFF)
  Future<bool> isBluetoothEnabled() async {
    try {
      final bool isEnabled = await _channel.invokeMethod('isBluetoothEnabled');
      return isEnabled;
    } catch (e) {
      debugPrint('Error checking Bluetooth status: $e');
      return false;
    }
  }

  // Get complete Bluetooth status
  Future<BluetoothStatus> getBluetoothStatus() async {
    try {
      final Map<dynamic, dynamic> status = await _channel.invokeMethod(
        'getBluetoothStatus',
      );

      return BluetoothStatus(
        hasPermissions: status['hasPermissions'] as bool? ?? false,
        isEnabled: status['isEnabled'] as bool? ?? false,
        isSupported: status['isSupported'] as bool? ?? true,
        canUse: status['canUse'] as bool? ?? false,
        state: status['state'] as String? ?? 'unknown',
      );
    } catch (e) {
      debugPrint('Error getting Bluetooth status: $e');
      return BluetoothStatus(
        hasPermissions: false,
        isEnabled: false,
        isSupported: false,
        canUse: false,
        state: 'error',
      );
    }
  }

  // Enable Bluetooth (request to turn ON)
  Future<void> enableBluetooth() async {
    try {
      await _channel.invokeMethod('enableBluetooth');
    } catch (e) {
      debugPrint('Error enabling Bluetooth: $e');
    }
  }

  // Check and request permissions if needed
  Future<bool> ensurePermissions() async {
    final bool hasPerms = await hasPermissions();
    if (hasPerms) {
      return true;
    }
    return await requestPermissions();
  }

  // Ensure both permission AND Bluetooth is enabled
  Future<bool> ensureBluetoothReady() async {
    // Step 1: Check/request permissions
    final hasPermission = await ensurePermissions();
    if (!hasPermission) {
      debugPrint('❌ Bluetooth permission denied');
      return false;
    }

    // Step 2: Check if Bluetooth is enabled
    final isEnabled = await isBluetoothEnabled();
    if (!isEnabled) {
      if (Platform.isAndroid) {
        await enableBluetooth();

        // Wait a bit and check again
        await Future.delayed(Duration(seconds: 1));
        return await isBluetoothEnabled();
      } else {
        // iOS: User must enable in Settings
        debugPrint('Please enable Bluetooth in Settings');
        return false;
      }
    }

    debugPrint('✅ Bluetooth is ready');
    return true;
  }

  Future<bool> openSettings() async {
    try {
      if (Platform.isIOS) {
        final bool result = await _channel.invokeMethod('openSettings');
        return result;
      } else {
        // For Android, you might want to use a package like app_settings
        // or implement similar native code
        return false;
      }
    } catch (e) {
      debugPrint('Error opening settings: $e');
      return false;
    }
  }

  //  NEW: Try to open Bluetooth Settings (iOS only)
  Future<bool> openBluetoothSettings() async {
    try {
      if (Platform.isIOS) {
        final bool result = await _channel.invokeMethod(
          'openBluetoothSettings',
        );
        return result;
      } else {
        // Android - use intent or app_settings package
        return false;
      }
    } catch (e) {
      debugPrint('Error opening Bluetooth settings: $e');
      return false;
    }
  }
}

// Bluetooth status model
class BluetoothStatus {
  final bool hasPermissions;
  final bool isEnabled;
  final bool isSupported;
  final bool canUse;
  final String state; // ✅ NEW: iOS Bluetooth state

  BluetoothStatus({
    required this.hasPermissions,
    required this.isEnabled,
    required this.isSupported,
    required this.canUse,
    this.state = 'unknown',
  });

  @override
  String toString() {
    return 'BluetoothStatus(hasPermissions: $hasPermissions, isEnabled: $isEnabled, isSupported: $isSupported, canUse: $canUse, state: $state)';
  }

  // ✅ NEW: Helper methods
  bool get needsPermission => !hasPermissions;
  bool get needsEnable => hasPermissions && !isEnabled;
  bool get isReady => canUse;

  String get statusMessage {
    if (!isSupported) return 'Bluetooth not supported';
    if (!hasPermissions) return 'Bluetooth permission needed';
    if (!isEnabled) return 'Bluetooth is OFF';
    return 'Bluetooth Ready';
  }
}
