import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/row_box_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/header_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/domain/entities/device_info.dart';
import 'package:salesforce/features/more/presentation/pages/administration/administration_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/administration/administration_state.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_thermal_printer_screen.dart';
import 'package:salesforce/features/more/presentation/pages/imin_device/printer_test_page.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});
  static const String routeName = "administration";

  @override
  AdministrationScreenState createState() => AdministrationScreenState();
}

class AdministrationScreenState extends State<AdministrationScreen>
    with MessageMixin {
  late final AdministrationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AdministrationCubit();
    _initializeScreen();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _cubit.checkInforDevice();
    await checkIminDevice();
    await _refreshBluetoothDevices();
  }

  Future<void> checkIminDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    await _cubit.checkIminDevice(deviceInfo);
  }

  Future<String?> _getStoredConnectedMac() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('connected_printer_mac');
  }

  Future<void> _refreshBluetoothDevices() async {
    String? storedMac = await _getStoredConnectedMac();
    print('storedMac=============${storedMac}');
    if ((storedMac ?? "").isEmpty) {
      return;
    }
    final connectedDevices = await PrintBluetoothThermal.pairedBluetooths;

    final device = connectedDevices
        .where((e) => e.macAdress == storedMac)
        .first;

    _cubit.checkBluetoothDevie(device);
  }

  Future<void> _navigateToBluetoothPage(BluetoothInfo? currentDevice) async {
    final result = await Navigator.pushNamed(
      context,
      BluetoothThermalPrinterScreen.routeName,
      arguments: currentDevice,
    );
    if (result == null) return;

    await _refreshBluetoothDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("Administration")),
      body: BlocBuilder<AdministrationCubit, AdministrationState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) return const LoadingPageWidget();
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(AdministrationState state) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16)),
      children: [
        _buildDashboardHeader(state),
        Helpers.gapH(8),
        _buildAdminOptions(state),
        Helpers.gapH(8),
      ],
    );
  }

  Widget _buildDashboardHeader(AdministrationState state) {
    return HeaderWidget(
      title: "Administration Dashboard",
      subtitle: "Manage printing and APK distribution",
      bgIcon: mainColor,
      icon: Icon(
        Icons.check_circle_rounded,
        size: scaleFontSize(24),
        color: white,
      ),
      child: _buildQuickStats(state),
    );
  }

  Widget _buildQuickStats(AdministrationState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          value: _getConnectedDeviceCount(state.bluetoothDevice),
          label: "Connected Devices",
          color: success,
        ),
        // _buildStatCard(value: "0", label: "Print job today", color: mainColor),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: BoxWidget(
        isBoxShadow: false,
        color: color.withValues(alpha: 0.1),
        padding: EdgeInsets.all(scaleFontSize(8)),
        child: RowBoxTextWidget(
          crossAxisAlignment1: CrossAxisAlignment.center,
          lable1: value,
          value1: label.toUpperCase(),
          label1FontWeight: FontWeight.bold,
          fontSizeLable: 18,
          fontSizeValue: 12,
          lable1Color: color,
          value1Color: textColor50,
          value1FontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildAdminOptions(AdministrationState state) {
    return Column(
      children: [
        if (!state.isIminDevice)
          _buildBluetoothPrintingSection(state)
        else
          _buildAPKDeploymentSection(state),
      ],
    );
  }

  Widget _buildBluetoothPrintingSection(AdministrationState state) {
    return HeaderWidget(
      title: "Print via Bluetooth",
      subtitle: "Manage wireless printing operations",
      bgIcon: primary,
      icon: Icon(Icons.bluetooth, color: white),
      child: Column(
        spacing: scaleFontSize(appSpace),
        children: [
          _buildBluetoothConnectionStatus(state.bluetoothDevice),

          BtnWidget(
            onPressed: () => _navigateToBluetoothPage(state.bluetoothDevice),
            title: "Manage Bluetooth Printing",
            gradient: linearGradient,
            suffixIcon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _buildAPKDeploymentSection(AdministrationState state) {
    return HeaderWidget(
      title: "Individual via APK",
      subtitle: "Distribute applications to individual devices",
      bgIcon: warning,
      icon: Icon(Icons.mobile_friendly, color: white),
      child: Column(
        children: [
          _buildDeviceInfo(state.deviceInfo),
          BtnWidget(
            onPressed: _showComingSoonMessage,
            title: "Running on iMin",
            gradient: linearGradient,
            suffixIcon: const Icon(Icons.upload),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothConnectionStatus(BluetoothInfo? bluetoothDevice) {
    if (!_isDeviceConnected(bluetoothDevice)) {
      return _buildDisconnectedStatus();
    }
    return _buildConnectedDeviceInfo(bluetoothDevice!);
  }

  Widget _buildDisconnectedStatus() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: textColor50.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor50.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bluetooth_disabled, size: 18, color: textColor50),
            const SizedBox(width: 8),
            TextWidget(
              text: "No device connected",
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceInfo(BluetoothInfo bluetoothDevice) {
    return _buildInfoCard(
      title: "Connected Printers",
      deviceName: bluetoothDevice.name.isNotEmpty
          ? bluetoothDevice.name
          : "Unknown Device",
      deviceId: bluetoothDevice.macAdress ?? "Unknown",
    );
  }

  Widget _buildDeviceInfo(DeviceInfo? deviceInfo) {
    return _buildInfoCard(
      title: "Device Info",
      deviceName: deviceInfo?.appName ?? "Unknown",
      deviceId: "Version: ${deviceInfo?.version ?? 'N/A'}",
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String deviceName,
    required String deviceId,
  }) {
    return BoxWidget(
      width: double.infinity,
      padding: EdgeInsets.all(scaleFontSize(8)),
      isBorder: true,
      color: success.withValues(alpha: 0.08),
      borderColor: success.withValues(alpha: 0.3),
      isBoxShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: title,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: success,
          ),
          Row(
            children: [
              Icon(Icons.circle, color: success, size: scaleFontSize(10)),
              const SizedBox(width: 8),
              Expanded(
                child: TextWidget(
                  text: deviceName,
                  color: success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: scaleFontSize(18)),
            child: TextWidget(text: deviceId, color: success, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // MARK: - Helper Methods

  bool _isDeviceConnected(BluetoothInfo? device) {
    return device != null && device.name.isNotEmpty;
  }

  String _getConnectedDeviceCount(BluetoothInfo? device) {
    return _isDeviceConnected(device) ? "1" : "0";
  }

  void _showComingSoonMessage() {
    Navigator.pushNamed(context, PrinterTestScreen.routeName);
    // showErrorMessage("APK deployment feature coming soon!");
  }
}
