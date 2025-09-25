import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_connect_manager.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_page_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_page_state.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_permission.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_stream_manager.dart';
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
  late final BluetoothConnectionManager _connectionManager;
  late final BluetoothPermissionManager _permissionManager;
  late final BluetoothStreamManager _streamManager;

  @override
  void initState() {
    super.initState();
    _initializeManagers();
    _initializePage();
  }

  @override
  void dispose() {
    _streamManager.dispose();
    _connectionManager.dispose();
    _cubit.close();
    super.dispose();
  }

  // MARK: - Initialization
  void _initializeManagers() {
    _cubit = BluetoothPageCubit();
    _connectionManager = BluetoothConnectionManager();
    _permissionManager = BluetoothPermissionManager();
    _streamManager = BluetoothStreamManager(
      onAdapterStateChange: _handleAdapterStateChange,
      onScanStateChange: _cubit.scaningBluetooth,
      onScanResults: _cubit.handleScanResults,
      onError: showErrorMessage,
    );
  }

  Future<void> _initializePage() async {
    try {
      await _checkInitialState();
      if (await _permissionManager.requestPermissions()) {
        await _initializeBluetooth();
      }
    } catch (e) {
      _handleError('Initialization failed', e);
    }
  }

  Future<void> _checkInitialState() async {
    _cubit.setBluetoothDevice(widget.bluetoothDevice);

    if (!await FlutterBluePlus.isSupported) {
      _cubit.setBluetoothAdapterState(BluetoothAdapterState.unavailable);
      showErrorMessage('Bluetooth is not supported on this device');
      return;
    }

    final state = await FlutterBluePlus.adapterState.first.timeout(
      const Duration(seconds: 3),
    );
    _cubit.setBluetoothAdapterState(state);
    _showStateMessage(state);
  }

  void _showStateMessage(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.on:
        showSuccessMessage(greeting('Bluetooth is enabled'));
      case BluetoothAdapterState.off:
        showWarningMessage(
          greeting(
            'Bluetooth is disabled. Please enable it to scan for devices.',
          ),
        );
      case BluetoothAdapterState.unavailable:
        showErrorMessage('Bluetooth is not available on this device');
      default:
        break;
    }
  }

  Future<void> _initializeBluetooth() async {
    _streamManager.setupStreams();

    if (_cubit.state.adapterState == BluetoothAdapterState.on) {
      await _startScan();
    }
  }

  // MARK: - Device Sorting and Connection Updates
  Future<List<BluetoothDevice>> _sortDevicesByConnection(
    List<BluetoothDevice> devices,
  ) async {
    final List<BluetoothDevice> connectedDevices = [];
    final List<BluetoothDevice> disconnectedDevices = [];

    for (final device in devices) {
      try {
        final connectionState = await device.connectionState.first.timeout(
          const Duration(milliseconds: 500),
        );

        if (connectionState == BluetoothConnectionState.connected) {
          connectedDevices.add(device);
        } else {
          disconnectedDevices.add(device);
        }
      } catch (e) {
        // If we can't get connection state, assume disconnected
        disconnectedDevices.add(device);
      }
    }

    // Sort connected devices by name, then disconnected devices by name
    connectedDevices.sort(
      (a, b) => _getDeviceName(a).compareTo(_getDeviceName(b)),
    );
    disconnectedDevices.sort(
      (a, b) => _getDeviceName(a).compareTo(_getDeviceName(b)),
    );

    return [...connectedDevices, ...disconnectedDevices];
  }

  Future<void> _refreshDeviceList() async {
    final currentDevices = _cubit.state.devices ?? [];
    if (currentDevices.isNotEmpty) {
      final sortedDevices = await _sortDevicesByConnection(currentDevices);
      _cubit.setListBluetoothDevice(sortedDevices);
    }
  }

  // MARK: - Bluetooth Operations
  Future<void> _startScan() async {
    if (_cubit.state.adapterState != BluetoothAdapterState.on) return;

    try {
      await _addBondedDevices();
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 2),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      _handleError('Failed to start scan', e);
    }
  }

  Future<void> _addBondedDevices() async {
    try {
      final bondedDevices = await FlutterBluePlus.bondedDevices;
      final currentDevices = _cubit.state.devices ?? [];

      final newDevices = bondedDevices
          .where(
            (device) =>
                device.platformName.isNotEmpty &&
                !_isDuplicateDevice(device, currentDevices),
          )
          .toList();

      if (newDevices.isNotEmpty) {
        final devices = List<BluetoothDevice>.from(currentDevices)
          ..addAll(newDevices);
        final sortedDevices = await _sortDevicesByConnection(devices);
        _cubit.setListBluetoothDevice(sortedDevices);
      }
    } catch (e) {
      debugPrint('Failed to add bonded devices: $e');
    }
  }

  // Check for duplicate devices based on name similarity and recent IDs
  bool _isDuplicateDevice(
    BluetoothDevice newDevice,
    List<BluetoothDevice> existingDevices,
  ) {
    final newDeviceName = _getDeviceName(newDevice);
    final newDeviceId = newDevice.remoteId.toString();

    for (final existingDevice in existingDevices) {
      final existingName = _getDeviceName(existingDevice);
      final existingId = existingDevice.remoteId.toString();

      // Same device ID - definitely duplicate
      if (newDeviceId == existingId) {
        return true;
      }

      // Same name and similar MAC address pattern (likely randomized MAC)
      if (newDeviceName == existingName &&
          _isSimilarMacAddress(newDeviceId, existingId)) {
        debugPrint(
          'Potential duplicate device detected: $newDeviceName ($newDeviceId vs $existingId)',
        );
        return true;
      }
    }

    return false;
  }

  // Check if MAC addresses are similar (same vendor prefix or pattern)
  bool _isSimilarMacAddress(String mac1, String mac2) {
    // Remove colons and convert to uppercase
    final cleanMac1 = mac1.replaceAll(':', '').toUpperCase();
    final cleanMac2 = mac2.replaceAll(':', '').toUpperCase();

    // Check if first 6 characters (vendor prefix) are the same
    if (cleanMac1.length >= 6 && cleanMac2.length >= 6) {
      final vendor1 = cleanMac1.substring(0, 6);
      final vendor2 = cleanMac2.substring(0, 6);

      // Same vendor and similar pattern might indicate randomized MAC
      if (vendor1 == vendor2) {
        return true;
      }
    }

    return false;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      final result = await _connectionManager.handleConnection(
        device: device,
        onStateUpdate: (state) {
          _cubit.setBluetoothActionState(state);
          if (state == BluetoothConnectionState.connected) {
            _cubit.setBluetoothDevice(device);
            // Refresh the device list to move connected device to top
            _refreshDeviceList();
          } else {
            _cubit.setBluetoothDevice(null);
            // Refresh the device list to move disconnected device down
            _refreshDeviceList();
          }
        },
        onConnectingUpdate: _cubit.setConnectingBluetooth,
        onMessage: (message, isError) {
          isError ? showErrorMessage(message) : showSuccessMessage(message);
        },
      );

      if (result.isSuccess && mounted) {
        Navigator.pop(context, device);
      }
    } catch (e) {
      _handleError('Connection failed', e);
    }
  }

  Future<void> turnOnBluetooth() async {
    try {
      if (await FlutterBluePlus.isSupported) {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      showWarningMessage('Please enable Bluetooth manually from settings');
    }
  }

  // MARK: - Event Handlers
  void _handleAdapterStateChange(BluetoothAdapterState state) {
    _cubit.setBluetoothAdapterState(state);

    switch (state) {
      case BluetoothAdapterState.on:
        showSuccessMessage(greeting('Bluetooth enabled'));
        _startScan();
      case BluetoothAdapterState.off:
        showErrorMessage(greeting('Bluetooth disabled'));
        _cubit.scaningBluetooth(false);
        _clearDevices();
      case BluetoothAdapterState.unavailable:
        showErrorMessage('Bluetooth unavailable');
        _clearDevices();
      default:
        break;
    }
  }

  void _clearDevices() {
    _cubit.state.devices?.clear();
    _cubit.setBluetoothDevice(null);
    _connectionManager.clearAll();
  }

  void _handleError(String message, dynamic error) {
    debugPrint('$message: $error');
    showErrorMessage('$message: ${error.toString()}');
  }

  // MARK: - UI Helpers
  String _getDeviceName(BluetoothDevice device) =>
      device.platformName.isNotEmpty ? device.platformName : 'Unknown Device';

  Color _getButtonColor(bool isConnected) => isConnected ? red : mainColor;
  Color _getBackgroundColor(bool isConnected) => isConnected ? success : white;
  Color _getIconBackgroundColor(bool isConnected) =>
      isConnected ? success.withValues(alpha: 0.6) : primary;
  Color _getTextColor(bool isConnected) => isConnected ? white : textColor;

  IconData _getConnectionIcon(BluetoothConnectionState state) =>
      switch (state) {
        BluetoothConnectionState.connected => Icons.link,
        _ => Icons.link_off,
      };

  Color _getConnectionColor(BluetoothConnectionState state) => switch (state) {
    BluetoothConnectionState.connected => white,
    _ => textColor50,
  };

  String _getConnectionText(BluetoothConnectionState state, bool isConnecting) {
    if (isConnecting) return 'Connecting...';
    return switch (state) {
      BluetoothConnectionState.connected => 'Connected',
      _ => 'Tap to connect',
    };
  }

  // MARK: - Build Methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("Bluetooth"),
        onBack: () => Navigator.pop(context, _cubit.state.connectedDevice),
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(
          onChanged: (value) => _cubit.onSearchBlueTooth(value),
        ),
      ),
      body: BlocBuilder<BluetoothPageCubit, BluetoothPageState>(
        bloc: _cubit,
        builder: (context, state) => _buildBody(state),
      ),
    );
  }

  Widget _buildBody(BluetoothPageState state) {
    if (state.isLoading) {
      return LoadingPageWidget(label: "Scanning Bluetooth...");
    }

    return switch (state.adapterState) {
      BluetoothAdapterState.off => _buildBluetoothOffMessage(),
      BluetoothAdapterState.unavailable => _buildBluetoothUnavailableMessage(),
      _ => _buildContent(state),
    };
  }

  Widget _buildContent(BluetoothPageState state) {
    if ((state.devices?.isEmpty ?? true) && !state.isScanning) {
      return _buildNoDevicesMessage();
    }
    return _buildDeviceList(state);
  }

  Widget _buildBluetoothOffMessage() => _buildCenteredMessage(
    icon: Icons.bluetooth_disabled,
    iconColor: Colors.grey,
    title: 'Bluetooth is turned off',
    subtitle: 'Please enable Bluetooth to scan for devices',
    actionTitle: greeting("Enable Bluetooth"),
    onAction: turnOnBluetooth,
  );

  Widget _buildBluetoothUnavailableMessage() => _buildCenteredMessage(
    icon: Icons.bluetooth_disabled,
    iconColor: Colors.red,
    title: 'Bluetooth not supported',
    subtitle: 'This device does not support Bluetooth',
  );

  Widget _buildNoDevicesMessage() => _buildCenteredMessage(
    icon: Icons.bluetooth_searching,
    iconColor: Colors.grey,
    title: 'No devices found',
    subtitle: 'Pull down to refresh and scan again',
    actionTitle: 'Scan for Devices',
    onAction: _startScan,
  );

  Widget _buildCenteredMessage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? actionTitle,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        spacing: scaleFontSize(20),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: iconColor),
          TextWidget(text: title, fontSize: 18, color: textColor),
          TextWidget(text: subtitle, color: textColor50),
          if (actionTitle != null && onAction != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16)),
              child: BtnWidget(
                gradient: linearGradient,
                onPressed: onAction,
                title: actionTitle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BluetoothPageState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await _startScan();
        await _refreshDeviceList(); // Also refresh the sorting
      },
      child: ListView.builder(
        itemCount: state.devices?.length ?? 0,
        itemBuilder: (context, index) =>
            _buildDeviceListItem(state.devices![index]),
      ),
    );
  }

  Widget _buildDeviceListItem(BluetoothDevice device) {
    return StreamBuilder<BluetoothConnectionState>(
      stream: device.connectionState,
      initialData: BluetoothConnectionState.disconnected,
      builder: (context, snapshot) {
        final connectionState =
            snapshot.data ?? BluetoothConnectionState.disconnected;
        final deviceName = _getDeviceName(device);
        final isConnected =
            connectionState == BluetoothConnectionState.connected;
        final isConnecting = _connectionManager.isConnecting(
          device.remoteId.toString(),
        );
        final retryCount = _connectionManager.getRetryCount(
          device.remoteId.toString(),
        );

        return BoxWidget(
          margin: EdgeInsets.symmetric(
            horizontal: scaleFontSize(16),
            vertical: scaleFontSize(4),
          ),
          isBoxShadow: false,
          color: _getBackgroundColor(isConnected),
          child: ListTile(
            minVerticalPadding: 16,
            leading: _buildDeviceIcon(isConnected, isConnecting),
            title: _buildDeviceTitle(deviceName, isConnected),
            subtitle: _buildDeviceSubtitle(
              device,
              connectionState,
              isConnecting,
              retryCount,
            ),
            trailing: _buildDeviceAction(
              isConnected,
              isConnecting,
              () => _connectToDevice(device),
            ),
            onTap: () => _connectToDevice(device),
          ),
        );
      },
    );
  }

  Widget _buildDeviceIcon(bool isConnected, bool isConnecting) {
    return ChipWidget(
      borderColor: Colors.transparent,
      horizontal: 0,
      vertical: 10,
      radius: 10,
      bgColor: _getIconBackgroundColor(isConnected),
      child: Icon(
        isConnected ? Icons.bluetooth_searching : Icons.bluetooth,
        size: scaleFontSize(20),
        color: white,
      ),
    );
  }

  Widget _buildDeviceTitle(String deviceName, bool isConnected) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleFontSize(6)),
      child: TextWidget(
        text: deviceName,
        fontWeight: FontWeight.bold,
        color: _getTextColor(isConnected),
      ),
    );
  }

  Widget _buildDeviceSubtitle(
    BluetoothDevice device,
    BluetoothConnectionState connectionState,
    bool isConnecting,
    int retryCount,
  ) {
    return Column(
      spacing: scaleFontSize(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          fontSize: 12,
          text: 'ID: ${device.remoteId}',
          color: _getTextColor(
            connectionState == BluetoothConnectionState.connected,
          ),
        ),
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
        // Show device type/info if available
        if (_getDeviceTypeInfo(device).isNotEmpty)
          TextWidget(
            text: _getDeviceTypeInfo(device),
            fontSize: 10,
            color: _getTextColor(
              connectionState == BluetoothConnectionState.connected,
            ).withValues(alpha: .7),
          ),
        if (retryCount > 0)
          TextWidget(
            text: 'Retry attempt: $retryCount/3',
            fontSize: 10,
            color: Colors.orange,
          ),
      ],
    );
  }

  // Get additional device information to help distinguish similar devices
  String _getDeviceTypeInfo(BluetoothDevice device) {
    final deviceName = device.platformName.toLowerCase();

    if (deviceName.contains('airpods') || deviceName.contains('earbud')) {
      return 'Audio • Earbuds';
    } else if (deviceName.contains('speaker') ||
        deviceName.contains('jbl') ||
        deviceName.contains('bose') ||
        deviceName.contains('sony')) {
      return 'Audio • Speaker';
    } else if (deviceName.contains('watch') || deviceName.contains('band')) {
      return 'Wearable • Watch';
    } else if (deviceName.contains('phone') ||
        deviceName.contains('iphone') ||
        deviceName.contains('samsung')) {
      return 'Device • Phone';
    } else if (deviceName.contains('laptop') ||
        deviceName.contains('macbook') ||
        deviceName.contains('pc')) {
      return 'Device • Computer';
    } else if (deviceName.contains('mouse') ||
        deviceName.contains('keyboard')) {
      return 'Input • Peripheral';
    } else if (deviceName.contains('car') || deviceName.contains('auto')) {
      return 'Vehicle • Car Audio';
    }

    return 'Bluetooth Device';
  }

  Widget _buildDeviceAction(
    bool isConnected,
    bool isConnecting,
    VoidCallback onPressed,
  ) {
    if (isConnecting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return BtnTextWidget(
      rounded: 16,
      bgColor: _getButtonColor(isConnected),
      onPressed: onPressed,
      child: TextWidget(
        fontWeight: FontWeight.w500,
        text: isConnected ? "Disconnect" : "Connect",
        color: white,
      ),
    );
  }
}

// MARK: - Supporting Classes
class ConnectionResult {
  final bool isSuccess;
  final String? errorMessage;

  ConnectionResult._({required this.isSuccess, this.errorMessage});

  factory ConnectionResult.success() => ConnectionResult._(isSuccess: true);
  factory ConnectionResult.failure(String message) =>
      ConnectionResult._(isSuccess: false, errorMessage: message);
  factory ConnectionResult.alreadyConnecting() =>
      ConnectionResult._(isSuccess: false, errorMessage: 'Already connecting');
}
