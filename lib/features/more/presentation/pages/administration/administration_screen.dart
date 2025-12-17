import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
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
import 'package:salesforce/features/more/presentation/pages/administration/form_connection_printer/form_connect_printer.dart';
import 'package:salesforce/features/more/presentation/pages/administration/form_connection_printer/list_device_connection.dart';
import 'package:salesforce/features/more/presentation/pages/imin_device/printer_test_page.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});
  static const String routeName = "administration";

  @override
  AdministrationScreenState createState() => AdministrationScreenState();
}

class AdministrationScreenState extends State<AdministrationScreen>
    with MessageMixin {
  final _cubit = AdministrationCubit();

  @override
  void initState() {
    super.initState();
    _cubit.checkBluetoothStatus();
    _cubit.checkListenIOSBluetooth();
    _cubit.startScanning(context);
    _cubit.initialize();
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
  }

  Future<void> checkIminDevice() async {
    await _cubit.checkIminDevice();
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
      floatingActionButton:
          BlocBuilder<AdministrationCubit, AdministrationState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.isIminDevice) return SizedBox.shrink();
              return FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: mainColor,
                child: Icon(Icons.add, color: white),
                onPressed: () => _pushToFormPrinter(context, state),
              );
            },
          ),
    );
  }

  Future<Null> _pushToFormPrinter(
    BuildContext context,
    AdministrationState state,
  ) {
    return Navigator.pushNamed(
      context,
      FormConnectPrinter.routeName,
      arguments: state.devicePrinter,
    ).then((value) {
      if (value == null) return;
      final action = value as ActionState;
      if (Helpers.shouldReload(action)) {
        _cubit.getDevicePrinter();
      }
    });
  }

  Widget _buildBody(AdministrationState state) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16)),
      children: [
        _buildDashboardHeader(state),
        Helpers.gapH(8),
        if (!state.isIminDevice)
          _buildBluetoothPrintingSection(state)
        else
          _buildAPKDeploymentSection(state),
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
    );
  }

  Widget _buildBluetoothPrintingSection(AdministrationState state) {
    return BlocBuilder<AdministrationCubit, AdministrationState>(
      bloc: _cubit,
      builder: (context, state) {
        return HeaderWidget(
          title: "Print via Bluetooth",
          subtitle: "Manage wireless printing operations",
          bgIcon: primary,
          icon: Icon(Icons.bluetooth, color: white),
          child: BluetoothDeviceList(
            devices: state.devicePrinter,
            selectedDevice: state.selectedDevice,
            onDelete: (DevicePrinter device) async {
              Helpers.showDialogAction(
                context,
                labelAction: "Deletee",
                subtitle: "Do you want to delete ${device.deviceName}",
                confirm: () async {
                  Navigator.pop(context);
                  await _cubit.deletePrinter(device: device);
                },
              );
            },
            connectingDeviceId: state.connectingDeviceId,
            onDeviceTap: (DevicePrinter device) async {
              // _cubit.s(device);
            },
            onConnect: (DevicePrinter device) async {
              await _cubit.connectToPrinter(device);
            },

            onDisconnect: (DevicePrinter device) async {
              await _cubit.disconnectFromPrinter(device);
            },
          ),
        );
      },
    );
  }

  Widget _buildAPKDeploymentSection(AdministrationState state) {
    return HeaderWidget(
      title: "iMin Printer",
      subtitle: "Built-in thermal printer management",
      bgIcon: warning,
      icon: Icon(Icons.print, color: white),
      child: Column(
        spacing: scaleFontSize(appSpace),
        children: [
          _buildDeviceInfo(state.deviceInfo),

          BtnWidget(
            onPressed: () => _cubit.testIminPrinter(),
            title: "Test Print",
            gradient: linearGradient,
            suffixIcon: Icon(Icons.print),
          ),
        ],
      ),
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

  // bool _isDeviceConnected(BluetoothInfo? device) {
  //   return device != null && device.name.isNotEmpty;
  // }

  // String _getConnectedDeviceCount(BluetoothInfo? device) {
  //   return _isDeviceConnected(device) ? "1" : "0";
  // }

  void _showComingSoonMessage() {
    Navigator.pushNamed(context, PrinterTestScreen.routeName);
    // showErrorMessage("APK deployment feature coming soon!");
  }
}
