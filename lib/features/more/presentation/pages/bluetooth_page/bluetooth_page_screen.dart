import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_page_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_page_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class BluetoothPageScreen extends StatefulWidget {
  const BluetoothPageScreen({super.key, this.bluetoothDevice});
  static const String routeName = "bluetoothScreen";
  final BluetoothDevice? bluetoothDevice;

  @override
  BluetoothPageScreenState createState() => BluetoothPageScreenState();
}

class BluetoothPageScreenState extends State<BluetoothPageScreen>
    with MessageMixin {
  late final BluetoothPageCubit _cubit;

  // Connection management
  final Map<String, BluetoothCharacteristic> _writeCharacteristics = {};
  final Map<String, StreamSubscription<BluetoothConnectionState>>
  _connectionSubscriptions = {};
  final Map<String, int> _connectionRetryCount = {};
  final Set<String> _connectingDevices = {};

  // Stream subscriptions
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<bool>? _scanningStateSubscription;

  // Constants
  static const Duration _scanTimeout = Duration(seconds: 2);
  static const Duration _connectionTimeout = Duration(seconds: 3);
  static const Duration _connectionRetryDelay = Duration(seconds: 2);
  static const Duration _disconnectDelay = Duration(milliseconds: 500);
  static const int _mtuSize = 512;
  static const int _maxConnectionRetries = 3;

  @override
  void initState() {
    super.initState();
    _cubit = BluetoothPageCubit();
    _initializeBluetoothPage();
  }

  // @override
  // void dispose() {
  //   _cleanupResources();
  //   super.dispose();
  // }

  /// Initialize the entire Bluetooth page
  Future<void> _initializeBluetoothPage() async {
    try {
      await _checkInitialBluetoothState();
      await _initBluetooth();
    } catch (e) {
      debugPrint('Initialization error: $e');
      showErrorMessage('Failed to initialize Bluetooth: $e');
    }
  }

  /// Check initial Bluetooth state and show appropriate messages
  Future<void> _checkInitialBluetoothState() async {
    try {
      _cubit.setBluetoothDevice(widget.bluetoothDevice);

      if (!await FlutterBluePlus.isSupported) {
        _cubit.setBluetoothAdapterState(BluetoothAdapterState.unavailable);
        showErrorMessage('Bluetooth is not supported on this device');
        return;
      }

      // Get current adapter state with timeout
      final currentState = await FlutterBluePlus.adapterState.first.timeout(
        _connectionTimeout,
      );
      _cubit.setBluetoothAdapterState(currentState);

      // Show appropriate feedback
      _showInitialStateMessage(currentState);
    } catch (e) {
      debugPrint('Initial state check error: $e');
      showErrorMessage('Failed to check Bluetooth state: $e');
    }
  }

  /// Show message based on initial Bluetooth state
  void _showInitialStateMessage(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.on:
        showSuccessMessage(greeting('Bluetooth is enabled'));
        break;
      case BluetoothAdapterState.off:
        showWarningMessage(
          greeting(
            'Bluetooth is disabled. Please enable it to scan for devices.',
          ),
        );
        break;
      case BluetoothAdapterState.unavailable:
        showErrorMessage('Bluetooth is not available on this device');
        break;
      default:
        break;
    }
  }

  /// Initialize Bluetooth functionality
  Future<void> _initBluetooth() async {
    try {
      final hasPermissions = await _checkAndRequestPermissions();
      if (!hasPermissions) return;

      _setupBluetoothStreams();

      if (_cubit.state.adapterState == BluetoothAdapterState.on) {
        await _startScan();
      }
    } catch (e) {
      debugPrint('Bluetooth init error: $e');
      showErrorMessage('Failed to initialize Bluetooth: $e');
    }
  }

  /// Check and request necessary permissions
  Future<bool> _checkAndRequestPermissions() async {
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ];

    try {
      final statuses = await permissions.request();
      final deniedPermissions = statuses.entries
          .where((entry) => !entry.value.isGranted)
          .map((entry) => entry.key)
          .toList();

      if (deniedPermissions.isNotEmpty) {
        showWarningMessage(
          'Some permissions were denied. Bluetooth functionality may be limited.',
        );
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Permission error: $e');
      showErrorMessage('Failed to request permissions: $e');
      return false;
    }
  }

  /// Setup Bluetooth event streams
  void _setupBluetoothStreams() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen(
      _handleAdapterStateChange,
      onError: (error) {
        debugPrint('Adapter state error: $error');
        showErrorMessage('Bluetooth adapter error: $error');
      },
    );

    _scanningStateSubscription = FlutterBluePlus.isScanning.listen(
      _cubit.scaningBluetooth,
      onError: (error) {
        debugPrint('Scanning state error: $error');
        showErrorMessage('Scanning state error: $error');
      },
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen(
      _cubit.handleScanResults,
      onError: (error) {
        debugPrint('Scan results error: $error');
        showErrorMessage('Scan error: $error');
      },
    );
  }

  /// Handle Bluetooth adapter state changes
  void _handleAdapterStateChange(BluetoothAdapterState state) {
    _cubit.setBluetoothAdapterState(state);

    switch (state) {
      case BluetoothAdapterState.on:
        showSuccessMessage(greeting('Bluetooth enabled'));
        _startScan();
        break;
      case BluetoothAdapterState.off:
        showErrorMessage(greeting('Bluetooth disabled'));
        _cubit.scaningBluetooth(false);
        _clearDevices();
        break;
      case BluetoothAdapterState.unavailable:
        showErrorMessage('Bluetooth unavailable');
        _clearDevices();
        break;
      default:
        break;
    }
  }

  /// Clear all devices and cleanup connections
  void _clearDevices() {
    _cubit.state.devices?.clear();
    _cubit.setBluetoothDevice(null);
    _cleanupConnectionSubscriptions();
    _connectionRetryCount.clear();
    _connectingDevices.clear();
  }

  /// Start Bluetooth device scan
  Future<void> _startScan() async {
    if (_cubit.state.adapterState != BluetoothAdapterState.on) return;

    try {
      // Get bonded devices first
      await _addBondedDevices();

      // Start scanning for new devices
      await FlutterBluePlus.startScan(
        timeout: _scanTimeout,
        androidUsesFineLocation: true,
      );

      debugPrint('Bluetooth scan started');
    } catch (e) {
      debugPrint('Scan start error: $e');
      showErrorMessage('Failed to start Bluetooth scan: $e');
    }
  }

  /// Add bonded devices to the list
  Future<void> _addBondedDevices() async {
    try {
      final bondedDevices = await FlutterBluePlus.bondedDevices;
      final currentDevices = _cubit.state.devices ?? [];
      final filteredBondedDevices = bondedDevices
          .where(
            (device) =>
                !currentDevices.any((d) => d.remoteId == device.remoteId) &&
                device.platformName.isNotEmpty,
          )
          .toList();

      if (filteredBondedDevices.isNotEmpty) {
        final devices = List<BluetoothDevice>.from(currentDevices);
        devices.addAll(filteredBondedDevices);
        _cubit.setListBluetoothDevice(devices);
        debugPrint('Added ${filteredBondedDevices.length} bonded devices');
      }
    } catch (e) {
      debugPrint('Bonded devices error: $e');
    }
  }

  /// FIXED: Main connection method with proper retry logic
  Future<void> _connectToDevice(BluetoothDevice device) async {
    final deviceId = device.remoteId.toString();
    final deviceName = _getDeviceName(device);

    // Prevent multiple simultaneous connection attempts
    if (_connectingDevices.contains(deviceId)) {
      debugPrint('Connection already in progress for $deviceName');
      return;
    }

    debugPrint('Processing connection request for $deviceName');

    try {
      final connectionState = await device.connectionState.first.timeout(
        const Duration(seconds: 2),
      );

      if (connectionState == BluetoothConnectionState.connected) {
        // Device is connected - disconnect it
        await _performDisconnection(device, deviceName);
      } else {
        // Device is disconnected - connect it
        await _performConnectionWithRetry(device, deviceName);
      }
    } catch (e) {
      debugPrint('Connection state check error for $deviceName: $e');
      await _performConnectionWithRetry(device, deviceName);
    }
  }

  /// FIXED: Connection with proper retry mechanism
  Future<void> _performConnectionWithRetry(
    BluetoothDevice device,
    String deviceName,
  ) async {
    final deviceId = device.remoteId.toString();
    int currentRetry = _connectionRetryCount[deviceId] ?? 0;

    // Check if we've exceeded max retries
    if (currentRetry >= _maxConnectionRetries) {
      showErrorMessage(
        'Failed to connect to $deviceName after $_maxConnectionRetries attempts',
      );
      _connectionRetryCount[deviceId] = 0; // Reset for next time
      return;
    }

    // Set connecting state
    _connectingDevices.add(deviceId);
    _cubit.setConnectingBluetooth(true);

    try {
      // Show retry message if this is not the first attempt
      if (currentRetry > 0) {
        showWarningMessage(
          'Connection failed (attempt $currentRetry/$_maxConnectionRetries). Retrying...',
        );
        await Future.delayed(_connectionRetryDelay);
      }

      // Increment retry count BEFORE attempting connection
      _connectionRetryCount[deviceId] = currentRetry + 1;

      // Attempt the actual connection
      await _attemptConnection(device);

      // Connection successful - reset retry count and update state
      _connectionRetryCount[deviceId] = 0;
      _cubit.setBluetoothDevice(device);
      _cubit.setBluetoothActionState(BluetoothConnectionState.connected);

      // Setup connection monitoring
      _setupConnectionMonitoring(device);

      // Discover services
      await _discoverServices(device);

      showSuccessMessage('Connected to $deviceName');

      // Navigate back with connected device
      if (mounted) {
        Navigator.pop(context, device);
      }
    } catch (e) {
      debugPrint('Connection attempt failed for $deviceName: $e');

      // Check if we should retry
      if (_connectionRetryCount[deviceId]! < _maxConnectionRetries &&
          _isRetryableError(e)) {
        // Don't show error yet, let the retry mechanism handle it
        await _performConnectionWithRetry(device, deviceName);
      } else {
        // Final failure - show error and reset
        await _handleFinalConnectionFailure(device, e);
      }
    } finally {
      _connectingDevices.remove(deviceId);
      _cubit.setConnectingBluetooth(false);
    }
  }

  /// Handle disconnection flow
  Future<void> _performDisconnection(
    BluetoothDevice device,
    String deviceName,
  ) async {
    final deviceId = device.remoteId.toString();

    try {
      // Cancel connection subscription
      await _connectionSubscriptions[deviceId]?.cancel();
      _connectionSubscriptions.remove(deviceId);

      // Small delay before disconnecting
      await Future.delayed(_disconnectDelay);

      // Disconnect device
      await device.disconnect();

      // Update state
      _updateDisconnectedState(device);

      showWarningMessage('Disconnected from $deviceName');
    } catch (e) {
      _updateDisconnectedState(device);
      showErrorMessage('Error disconnecting from $deviceName');
    }
  }

  /// FIXED: Connection attempt with proper timeout and cleanup
  Future<void> _attemptConnection(BluetoothDevice device) async {
    try {
      // Ensure device is disconnected first
      await _ensureDisconnected(device);

      // Connect with timeout
      await device
          .connect(autoConnect: false, mtu: null)
          .timeout(
            _connectionTimeout,
            onTimeout: () => throw TimeoutException(
              'Connection timeout after ${_connectionTimeout.inSeconds}s',
              _connectionTimeout,
            ),
          );

      // Request higher MTU
      await _requestMtu(device);
    } catch (e) {
      await _ensureDisconnected(device);
      rethrow;
    }
  }

  /// Ensure device is properly disconnected
  Future<void> _ensureDisconnected(BluetoothDevice device) async {
    try {
      await device.disconnect();
      await Future.delayed(_disconnectDelay);
    } catch (e) {
      debugPrint('Disconnect error (ignored): $e');
    }
  }

  /// Request MTU with error handling
  Future<void> _requestMtu(BluetoothDevice device) async {
    try {
      await device.requestMtu(_mtuSize);
      debugPrint('MTU set to $_mtuSize for ${_getDeviceName(device)}');
    } catch (e) {
      debugPrint('MTU request failed: $e');
      // Continue without failing - MTU is optional
    }
  }

  /// Setup connection state monitoring
  void _setupConnectionMonitoring(BluetoothDevice device) {
    final deviceId = device.remoteId.toString();

    // Cancel existing subscription
    _connectionSubscriptions[deviceId]?.cancel();

    // Setup new connection monitoring
    _connectionSubscriptions[deviceId] = device.connectionState.listen(
      (state) => _handleConnectionStateChange(device, state),
      onError: (error) {
        debugPrint(
          'Connection state error for ${_getDeviceName(device)}: $error',
        );
        _handleUnexpectedDisconnection(device);
      },
    );
  }

  /// Handle final connection failure
  Future<void> _handleFinalConnectionFailure(
    BluetoothDevice device,
    dynamic error,
  ) async {
    final deviceId = device.remoteId.toString();
    final deviceName = _getDeviceName(device);

    // Reset retry count
    _connectionRetryCount[deviceId] = 0;

    // Clean up resources
    await _cleanupDeviceResources(device);

    // Update state
    _updateDisconnectedState(device);

    // Show error message
    final errorMessage = _getErrorMessage(error, deviceName);
    showErrorMessage(errorMessage);
  }

  /// Determine if error is retryable
  bool _isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return error is TimeoutException ||
        errorString.contains('133') ||
        errorString.contains('android_specific_error') ||
        errorString.contains('gatt_error') ||
        errorString.contains('gatt') ||
        errorString.contains('connection') ||
        errorString.contains('timeout');
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error, String deviceName) {
    if (error.toString().contains('133')) {
      return 'Connection failed: Device communication error. Try moving closer or restart Bluetooth.';
    } else if (error is TimeoutException) {
      return 'Connection failed: Timeout. Device may be out of range or busy.';
    } else {
      return 'Connection failed: Unable to connect to $deviceName';
    }
  }

  /// Clean up device-specific resources
  Future<void> _cleanupDeviceResources(BluetoothDevice device) async {
    final deviceId = device.remoteId.toString();

    await _connectionSubscriptions[deviceId]?.cancel();
    _connectionSubscriptions.remove(deviceId);
    _writeCharacteristics.remove(deviceId);
    _connectingDevices.remove(deviceId);
  }

  /// Update state to disconnected
  void _updateDisconnectedState(BluetoothDevice device) {
    _cubit.setBluetoothActionState(BluetoothConnectionState.disconnected);
    _cubit.setBluetoothDevice(null);
    _cubit.setConnectingBluetooth(false);
  }

  /// Handle unexpected disconnections
  void _handleUnexpectedDisconnection(BluetoothDevice device) {
    final deviceName = _getDeviceName(device);
    final deviceId = device.remoteId.toString();

    _updateDisconnectedState(device);
    _writeCharacteristics.remove(deviceId);
    _connectionSubscriptions[deviceId]?.cancel();
    _connectionSubscriptions.remove(deviceId);
    _connectingDevices.remove(deviceId);

    showWarningMessage('Lost connection to $deviceName');
  }

  /// Clear Bluetooth cache
  Future<void> _clearBluetoothCache(BluetoothDevice device) async {
    try {
      await device.disconnect();
      await Future.delayed(const Duration(milliseconds: 1000));
      debugPrint('Cleared cache for ${_getDeviceName(device)}');
    } catch (e) {
      debugPrint('Cache clear failed: $e');
    }
  }

  /// FIXED: Connection state change handler
  void _handleConnectionStateChange(
    BluetoothDevice device,
    BluetoothConnectionState state,
  ) {
    final deviceName = _getDeviceName(device);

    switch (state) {
      case BluetoothConnectionState.connected:
        if (!_cubit.state.isConnected) {
          _cubit.setBluetoothActionState(BluetoothConnectionState.connected);
          _cubit.setBluetoothDevice(device);
          showSuccessMessage('Connected to $deviceName');
          _discoverServices(device);

          if (mounted) {
            Navigator.pop(context, device);
          }
        }
        break;

      case BluetoothConnectionState.disconnected:
        _handleUnexpectedDisconnection(device);
        break;

      default:
        break;
    }
  }

  /// Discover device services and characteristics
  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      BluetoothCharacteristic? writeCharacteristic;

      // Find the first writable characteristic
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
        debugPrint(
          'Found writable characteristic for ${_getDeviceName(device)}',
        );
      } else {
        showWarningMessage(
          'No writable characteristic found on ${_getDeviceName(device)}',
        );
      }
    } catch (e) {
      debugPrint('Service discovery error: $e');
      showErrorMessage('Service discovery failed: $e');
    }
  }

  /// Cleanup all resources
  Future<void> _cleanupResources() async {
    try {
      // await _cleanupBluetooth();
      _cubit.close();
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  /// Clean up Bluetooth resources
  // Future<void> _cleanupBluetooth() async {
  //   try {
  //     await Future.wait([
  //       _scanSubscription?.cancel() ?? Future.value(),
  //       _adapterStateSubscription?.cancel() ?? Future.value(),
  //       _scanningStateSubscription?.cancel() ?? Future.value(),
  //       FlutterBluePlus.stopScan(),
  //     ]);
  //     _cleanupConnectionSubscriptions();
  //   } catch (e) {
  //     debugPrint('Bluetooth cleanup error: $e');
  //   }
  // }

  /// Clean up all connection subscriptions
  void _cleanupConnectionSubscriptions() {
    for (final subscription in _connectionSubscriptions.values) {
      subscription.cancel();
    }
    _connectionSubscriptions.clear();
  }

  /// Get device name with fallback
  String _getDeviceName(BluetoothDevice device) {
    return device.platformName.isNotEmpty
        ? device.platformName
        : 'Unknown Device';
  }

  /// Turn on Bluetooth
  Future<void> turnOnBluetooth() async {
    try {
      if (await FlutterBluePlus.isSupported) {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      showWarningMessage('Please enable Bluetooth manually from settings');
    }
  }

  // UI Helper methods
  Color _getDeviceStatusColor(bool isConnected) {
    return isConnected ? success : primary;
  }

  IconData _getConnectionIcon(BluetoothConnectionState state) {
    return switch (state) {
      BluetoothConnectionState.connected => Icons.link,
      _ => Icons.link_off,
    };
  }

  Color _getConnectionColor(BluetoothConnectionState state) {
    return switch (state) {
      BluetoothConnectionState.connected => success,
      _ => textColor50,
    };
  }

  String _getConnectionText(BluetoothConnectionState state, bool isConnecting) {
    if (isConnecting) return 'Connecting...';

    return switch (state) {
      BluetoothConnectionState.connected => 'Connected',
      BluetoothConnectionState.disconnected => 'Tap to connect',
      _ => 'Tap to connect',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("Bluetooth"),
        onBack: () => Navigator.pop(context, _cubit.state.connectedDevice),
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(
          onChanged: (value) => debugPrint("Search: $value"),
        ),
      ),
      body: BlocBuilder<BluetoothPageCubit, BluetoothPageState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          if (state.adapterState == BluetoothAdapterState.off) {
            return _buildBluetoothOffMessage();
          }

          if (state.adapterState == BluetoothAdapterState.unavailable) {
            return _buildBluetoothUnavailableMessage();
          }

          if ((state.devices?.isEmpty ?? true) && !state.isScanning) {
            return _buildNoDevicesMessage();
          }

          return _buildDeviceList(state);
        },
      ),
    );
  }

  Widget _buildBluetoothOffMessage() {
    return Center(
      child: Column(
        spacing: scaleFontSize(20),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
          const TextWidget(
            text: 'Bluetooth is turned off',
            fontSize: 18,
            color: textColor,
          ),
          const TextWidget(
            text: 'Please enable Bluetooth to scan for devices',
            color: textColor50,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16)),
            child: BtnWidget(
              gradient: linearGradient,
              onPressed: turnOnBluetooth,
              title: greeting("Enable Bluetooth"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothUnavailableMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_disabled, size: 64, color: Colors.red),
          Helpers.gapH(scaleFontSize(16)),
          const TextWidget(
            text: 'Bluetooth not supported',
            fontSize: 18,
            color: error,
          ),
          const TextWidget(text: 'This device does not support Bluetooth'),
        ],
      ),
    );
  }

  Widget _buildNoDevicesMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_searching, size: 64, color: Colors.grey),
          Helpers.gapH(scaleFontSize(16)),
          const TextWidget(text: 'No devices found', fontSize: 18),
          const TextWidget(
            text: 'Pull down to refresh and scan again',
            color: textColor,
          ),
          Helpers.gapH(scaleFontSize(20)),
          BtnWidget(
            gradient: linearGradient,
            onPressed: _startScan,
            title: 'Scan for Devices',
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BluetoothPageState state) {
    return RefreshIndicator(
      onRefresh: _startScan,
      child: ListView.separated(
        itemCount: state.devices?.length ?? 0,
        itemBuilder: (context, index) =>
            _buildDeviceListItem(state.devices![index], state),
        separatorBuilder: (context, index) => const Hr(width: double.infinity),
      ),
    );
  }

  Widget _buildDeviceListItem(
    BluetoothDevice device,
    BluetoothPageState state,
  ) {
    final deviceId = device.remoteId.toString();
    final retryCount = _connectionRetryCount[deviceId] ?? 0;
    final isConnecting = _connectingDevices.contains(deviceId);

    return StreamBuilder<BluetoothConnectionState>(
      stream: device.connectionState,
      initialData: BluetoothConnectionState.disconnected,
      builder: (context, snapshot) {
        final connectionState =
            snapshot.data ?? BluetoothConnectionState.disconnected;
        final deviceName = _getDeviceName(device);
        final isConnected =
            connectionState == BluetoothConnectionState.connected;

        return ListTile(
          minVerticalPadding: 4,
          leading: ChipWidget(
            borderColor: Colors.transparent,
            horizontal: 1,
            radius: 16,
            bgColor: _getDeviceStatusColor(isConnected).withValues(alpha: 0.1),
            child: Icon(
              isConnecting ? Icons.bluetooth_searching : Icons.bluetooth,
              size: scaleFontSize(20),
              color: _getDeviceStatusColor(isConnected),
            ),
          ),
          title: TextWidget(
            text: deviceName,
            fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
          ),
          subtitle: Column(
            spacing: scaleFontSize(4),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(fontSize: 12, text: 'ID: ${device.remoteId}'),
              Row(
                spacing: scaleFontSize(4),
                children: [
                  Icon(
                    _getConnectionIcon(connectionState),
                    size: 12,
                    color: _getConnectionColor(connectionState),
                  ),
                  TextWidget(
                    text: _getConnectionText(connectionState, isConnecting),
                    fontSize: 12,
                    color: _getConnectionColor(connectionState),
                  ),
                ],
              ),
              if (retryCount > 0)
                TextWidget(
                  text: 'Retry attempt: $retryCount/$_maxConnectionRetries',
                  fontSize: 10,
                  color: Colors.orange,
                ),
            ],
          ),
          trailing: isConnecting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : BtnTextWidget(
                  onPressed: () => _connectToDevice(device),
                  child: TextWidget(
                    text: isConnected ? "Disconnect" : "Connect",
                    color: _getDeviceStatusColor(isConnected),
                  ),
                ),
          onTap: () => _connectToDevice(device),
        );
      },
    );
  }
}
