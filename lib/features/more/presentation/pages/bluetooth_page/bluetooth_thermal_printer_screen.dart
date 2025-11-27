import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class BluetoothThermalPrinterScreen extends StatefulWidget {
  const BluetoothThermalPrinterScreen({super.key, this.connectedMac});
  static const String routeName = "bluetoothThermalPrinterScreen";
  final String? connectedMac;

  @override
  BluetoothThermalPrinterScreenState createState() =>
      BluetoothThermalPrinterScreenState();
}

class BluetoothThermalPrinterScreenState
    extends State<BluetoothThermalPrinterScreen>
    with MessageMixin {
  List<BluetoothInfo> devices = [];
  bool connected = false;
  bool isConnecting = false;
  bool isScanning = false;
  String statusMessage = "";
  String? connectedMac;
  String searchQuery = "";
  String? connectingMac;

  @override
  void initState() {
    super.initState();
    _initializePrinter();
  }

  Future<bool> _requestBluetoothPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 31) {
        // Android 12+ permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();

        return statuses.values.every((status) => status.isGranted);
      } else if (androidInfo.version.sdkInt >= 23) {
        // Android 6-11 permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetooth,
          Permission.location,
        ].request();

        return statuses.values.every((status) => status.isGranted);
      }
    }
    return true;
  }

  Future _initializePrinter() async {
    try {
      setState(() => isScanning = true);

      // Request permissions first
      final hasPermission = await _requestBluetoothPermissions();

      if (!hasPermission) {
        setState(() {
          statusMessage =
              "Bluetooth permissions denied. Please enable them in Settings.";
          isScanning = false;
        });

        // Show dialog to open settings
        if (mounted) {
          Helpers.showDialogAction(
            context,
            labelAction: "Permission Required",
            subtitle:
                "Please enable Bluetooth permissions in Settings to use the printer.",
            confirmText: "Open Settings",
            canCancel: true,
            confirm: () {
              Navigator.pop(context);
              openAppSettings();
            },
          );
        }
        return;
      }

      await checkExistingConnection();
      await scanDevices();

      // Auto-connect if previously stored MAC is found
      if (!connected && devices.isNotEmpty) {
        final storedMac = await _getStoredConnectedMac();
        final device = devices.firstWhere(
          (d) => d.macAdress == storedMac,
          orElse: () => devices.first,
        );
        await connect(device.macAdress);
      }
    } catch (e) {
      setState(() => statusMessage = "Failed to initialize: $e");
    } finally {
      setState(() => isScanning = false);
    }
  }

  // MARK: - Connection Check
  Future<void> checkExistingConnection() async {
    try {
      final isConnected = await PrintBluetoothThermal.connectionStatus;
      if (!isConnected) return;

      final storedMac = await _getStoredConnectedMac();
      if (storedMac != null) {
        setState(() {
          connected = true;
          connectedMac = storedMac;
          statusMessage = "Already connected to printer";
        });
      } else {
        await PrintBluetoothThermal.disconnect;
      }
    } catch (e) {
      debugPrint("Error checking connection: $e");
    }
  }

  Future<void> scanDevices() async {
    try {
      setState(() => isScanning = true);

      bool? isBluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;

      if (isBluetoothOn == false) {
        setState(() => isScanning = false);
        if (!mounted) return;
        if (Platform.isAndroid) {
          Helpers.showDialogAction(
            context,
            labelAction: "Bluetooth is Off",
            subtitle: "Do you want to enable Bluetooth?",
            confirmText: "Yes,Trun on",
            cancelText: "No,Cancel",
            canCancel: true,
            confirm: () async {
              Navigator.pop(context);
              try {
                await FlutterBluePlus.turnOn();
                await Future.delayed(Duration(seconds: 1));
                scanDevices();
              } catch (e) {
                showErrorMessage("Failed to enable Bluetooth: $e");
              }
            },
          );
        } else if (Platform.isIOS) {
          Helpers.showDialogAction(
            context,
            labelAction: "Bluetooth is Off",
            subtitle: "Please enable Bluetooth in Settings or Control Center.",
            canCancel: true,
            confirm: () {
              Navigator.pop(context);
              AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
            },
          );
        }
        return;
      }

      // Proceed with scanning
      final result = await PrintBluetoothThermal.pairedBluetooths;
      setState(() => devices = result);

      if (devices.isEmpty) {
        setState(
          () => statusMessage =
              "No paired devices found. Please pair your printer first.",
        );
      }
    } catch (e) {
      setState(() => statusMessage = "Failed to scan devices: $e");
    } finally {
      setState(() => isScanning = false);
    }
  }

  // MARK: - Connect
  Future<void> connect(String mac) async {
    if (connectingMac != null) return;

    setState(() {
      connectingMac = mac;
      statusMessage = "Connecting...";
    });

    try {
      if (connected) {
        await PrintBluetoothThermal.disconnect;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: mac,
      ).timeout(const Duration(seconds: 10), onTimeout: () => false);

      if (!result) throw Exception("Connection failed");

      await Future.delayed(const Duration(milliseconds: 500));
      final isStillConnected = await PrintBluetoothThermal.connectionStatus;
      if (!isStillConnected) throw Exception("Lost connection");

      await _saveConnectedMac(mac);
      setState(() {
        connected = true;
        connectedMac = mac;
        statusMessage = "Connected";
      });

      // optional: send reset/test command
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      await PrintBluetoothThermal.writeBytes(generator.reset());
    } catch (e) {
      setState(() {
        connected = false;
        connectedMac = null;
        statusMessage = "Connection failed: $e";
      });
    } finally {
      setState(() => connectingMac = null);
    }
  }

  // MARK: - Disconnect
  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      await _clearConnectedMac();
      setState(() {
        connected = false;
        connectedMac = null;
        statusMessage = "Disconnected";
      });
    } catch (e) {
      debugPrint("Disconnect error: $e");
    }
  }

  // MARK: - SharedPreferences
  Future<void> _saveConnectedMac(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('connected_printer_mac', mac);
  }

  Future<String?> _getStoredConnectedMac() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('connected_printer_mac');
  }

  Future<void> _clearConnectedMac() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('connected_printer_mac');
  }

  // MARK: - UI
  List<BluetoothInfo> get filteredDevices {
    if (searchQuery.isEmpty) return devices;
    return devices
        .where(
          (d) =>
              d.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              d.macAdress.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("Bluetooth Printer"),
        onBack: () => Navigator.pop(context, connectedMac),
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(
          onChanged: (value) => setState(() => searchQuery = value),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isScanning) {
      return const LoadingPageWidget(label: "Scanning Bluetooth Printers...");
    }

    if (filteredDevices.isEmpty) {
      return _buildNoDevicesMessage();
    }

    return RefreshIndicator(
      onRefresh: scanDevices,
      child: ListView.builder(
        itemCount: filteredDevices.length,
        itemBuilder: (context, i) => _buildDeviceListItem(filteredDevices[i]),
      ),
    );
  }

  Widget _buildNoDevicesMessage() => _buildCenteredMessage(
    icon: Icons.bluetooth_searching,
    iconColor: Colors.grey,
    title: searchQuery.isEmpty ? 'No devices found' : 'No matching devices',
    subtitle: searchQuery.isEmpty
        ? 'Pull down to refresh or pair devices in system settings'
        : 'Try a different search term',
    actionTitle: 'Scan for Devices',
    onAction: scanDevices,
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scaleFontSize(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: iconColor),
            TextWidget(
              text: title,
              fontSize: 18,
              color: textColor,
              textAlign: TextAlign.center,
            ),
            TextWidget(
              text: subtitle,
              color: textColor50,
              textAlign: TextAlign.center,
            ),
            if (actionTitle != null && onAction != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: scaleFontSize(16)),
                child: BtnWidget(
                  gradient: linearGradient,
                  onPressed: onAction,
                  title: actionTitle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceListItem(BluetoothInfo device) {
    final isConnected = connectedMac == device.macAdress;
    final deviceName = device.name.isNotEmpty ? device.name : 'Unknown Device';

    return BoxWidget(
      margin: EdgeInsets.symmetric(
        horizontal: scaleFontSize(16),
        vertical: scaleFontSize(4),
      ),
      isBoxShadow: false,
      color: isConnected ? primary : white,
      child: ListTile(
        leading: Icon(
          isConnected ? Icons.print : Icons.print_outlined,
          color: isConnected ? white : primary,
        ),
        title: TextWidget(
          text: deviceName,
          fontWeight: FontWeight.bold,
          color: isConnected ? white : textColor,
        ),
        subtitle: TextWidget(
          text: 'MAC: ${device.macAdress}',
          color: isConnected ? white : textColor50,
        ),
        trailing: connectingMac == device.macAdress
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : BtnTextWidget(
                bgColor: isConnected ? Colors.red : primary,
                onPressed: () async => isConnected
                    ? await disconnect()
                    : await connect(device.macAdress),
                child: TextWidget(
                  text: isConnected ? "Disconnect" : "Connect",
                  color: white,
                ),
              ),
      ),
    );
  }
}
