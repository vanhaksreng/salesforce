import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/generate_pdf_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/custom_alert_dialog_widget.dart';
import 'package:salesforce/core/presentation/widgets/custom_speed_dial.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';
import 'package:salesforce/features/tasks/domain/entities/task_dtos.dart';
import 'package:salesforce/features/tasks/presentation/pages/add_schedule/add_schedule_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_schedule_map/customer_schedule_map_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/my_schedule/my_schedule_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sales_person_map/sales_person_map_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/schedule_history/schedule_history_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/task_component/build_options.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedule_history/team_schedule_history_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedult/team_schedult_screen.dart';
import 'package:salesforce/features/tasks/tasks_main_cubit.dart';
import 'package:salesforce/features/tasks/tasks_main_state.dart';
import 'package:salesforce/grok_print.dart';
import 'package:salesforce/infrastructure/printer/bluetooth/bluetooth_printer_handler.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/testprint.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class TasksMainScreen extends StatefulWidget {
  const TasksMainScreen({super.key});
  static const String routeName = "taskScreen";
  static const String name = "Tasks";

  @override
  State<TasksMainScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TasksMainScreen>
    with SingleTickerProviderStateMixin, GeneratePdfMixin {
  late TabController _tabController;

  late DateTime scheduleDate;
  String? text;
  late TasksMainCubit _cubit;
  late User? _auth;

  @override
  void initState() {
    super.initState();
    _auth = getAuth();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabHandler);
    scheduleDate = DateTime.now();
    _cubit = context.read<TasksMainCubit>();
    _initLoad();
  }

  void _initLoad() async {
    await _cubit.getUserSetup();

    final option = await _cubit.getSetting(kScheduleOptionKey);
    if (option == "Forward old Schedule to the Current Date") {
      await _cubit.checkPendingOldSchedule();

      _showOldScheduleDialogs();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showOldScheduleDialogs() {
    if (!_cubit.state.hasPendingOldSchedule) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialogBuilderWidget(
        subTitle: "You have pending old schedule to complete",
        labelAction: "Warning",
        confirm: () {
          Navigator.of(context).pop();
          _moveOldScheduleToCurrentDate();
        },
        confirmText: "Yes, Move it to today",
        canCancel: false,
      ),
    );
  }

  void _moveOldScheduleToCurrentDate() async {
    final l = LoadingOverlay.of(context);
    l.show();
    await _cubit.moveOldScheduleToCurrentDate();
    l.hide();
  }

  void _checkAppVersion() {
    //TODO : impliment next time
    if (mounted) {
      Helpers.showDialogAction(
        context,
        labelAction: "New version available",
        subtitle: _cubit.state.appVersion?.description ?? "",
        confirm: () async {
          if (!mounted) return;
          Navigator.pop(context, true);
          final url = Uri.parse("${_cubit.state.appVersion!.appUrl}");
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            Helpers.showMessage(msg: 'No application found to open this link.');
          }
        },
      );
    }
  }

  void _onTabHandler() {
    _cubit.setActiveTap(_tabController.index);
  }

  late final List<ScheduleOptionData> options = [
    ScheduleOptionData(
      label: "Refresh Schedules (Today)",
      icon: Icons.refresh,
      onTap: _refreshSchedules,
    ),
    ScheduleOptionData(
      label: "My Schedule History",
      icon: Icons.checklist,
      onTap: _navigateToScheduleHistory,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: scaleFontSize(14),
        color: grey,
      ),
    ),
    ScheduleOptionData(
      label: "Team Schedule History",
      icon: Icons.group_add_sharp,
      onTap: () =>
          Navigator.pushNamed(context, TeamScheduleHistoryScreen.routeName),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: scaleFontSize(14),
        color: grey,
      ),
    ),
    ScheduleOptionData(
      label: "Add New Schedule",
      icon: Icons.add,
      onTap: _navigateToAddSchedule,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: scaleFontSize(14),
        color: grey,
      ),
    ),
  ];

  void _navigateToScheduleHistory() {
    Navigator.pop(context);
    Navigator.pushNamed(context, ScheduleHistoryScreen.routeName);
  }

  // void _onSearch(String value) {
  //   _cubit.setText(value);
  // }

  void _navigateToAddSchedule() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AddScheduleScreen.routeName).then((value) {
      if (Helpers.shouldReload(value)) {
        _cubit.refreshSchedules();
      }
    });
  }

  void _refreshSchedules() async {
    Navigator.pop(context);
    _cubit.setRefreshChild();
  }

  String welcomeMessage(String name) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "${greeting("Good Morning")}, $name";
    } else if (hour >= 12 && hour < 17) {
      return "${greeting("Good Afternoon")}, $name";
    } else if (hour >= 17 && hour < 21) {
      return "${greeting("Good Evening")}, $name";
    } else {
      return "${greeting("Good Night")}, $name";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksMainCubit, TasksMainState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBarWidget(
            isBackIcon: false,
            fontWeight: FontWeight.w600,
            titleColor: white,
            fontSizeTitle: 22,
            heightBottom: 30,
            title:
                "${greeting("Today")}, ${DateTime.now().toDateNameSortString()}",
            subtitle: TextWidget(
              text: welcomeMessage(_auth?.userName ?? ""),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: white,
            ),
            actions: [
              Visibility(
                visible: state.activeTap == 0,
                child: BtnIconCircleWidget(
                  onPressed: () => _cubit.refreshSchedules(),
                  icons: const Icon(Icons.refresh, color: white),
                  rounded: appBtnRound,
                ),
              ),
              SizedBox(width: scaleFontSize(6)),
              BtnIconCircleWidget(
                onPressed: () => _onOption(),
                icons: SvgWidget(
                  assetName: kAppOptionIcon,
                  colorSvg: white,
                  padding: EdgeInsets.all(4.scale),
                  width: 18,
                  height: 18,
                ),
                rounded: appBtnRound,
              ),
              SizedBox(width: scaleFontSize(appSpace)),
            ],
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              MyScheduleScreen(
                refresh: state.refreshChild,
                searchText: state.text,
              ),
              const TeamSchedultScreen(),
            ],
          ),
          // floatingActionButton: optionView(),
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            child: IconButton(
              icon: Icon(Icons.print),
              onPressed: () => _runDiagnostics(context),
            ),
          ),
        );
      },
    );
  }

  // Future<void> _runDiagnostics(BuildContext context) async {
  //   final List<Map<String, dynamic>> foundDevices = [];

  //   // Check 1: Handler registered
  //   // devices.add('✓ Handler is registered');

  //   // Helpers.showMessage(msg: 'Handler is registered');
  //   // Check 2: Try to scan
  //   try {
  //     await BluetoothPrinterHandler.scanDevices();

  //     // Listen for discovered devices
  //     BluetoothPrinterHandler.setDeviceFoundCallback((device) {
  //       print('Found: ${device['name']} - ${device['address']}');

  //       if (!BluetoothPrinterHandler.isConnected &&
  //           device['name'] == "XP-P323B-E1FE") {
  //         BluetoothPrinterHandler.connectDevice(device['address']);
  //       }
  //     });

  //     // await BluetoothPrinterHandler.connectDevice(
  //     //   "EF1E250B-0E58-9D8E-AA25-D59004BE2971",
  //     // );

  //     // final previewData = await ThermalPrintHelper.createReceiptImage(
  //     //   companyNameKhmer: 'ប្លូតិចឡូជី',
  //     //   companyNameEnglish: 'BLUE TECHNOLOGY CO., LTD',
  //     //   items: [
  //     //     {'name': 'Item 1', 'qty': '2', 'price': '5.00', 'amount': '10.00'},
  //     //     {'name': 'Item 2', 'qty': '1', 'price': '3.50', 'amount': '3.50'},
  //     //   ],
  //     //  method: PrintMethod.gsv
  //     //   // useAlternativeMethod: false, // Default

  //     // );

  //     // if (!context.mounted) return;

  //     // showDialog(
  //     //   context: context,
  //     //   builder: (context) => PrintPreviewDialog(
  //     //     previewData: previewData,
  //     //     onPrint: () async {
  //     //       // await platform.invokeMethod('printRaw', {
  //     //       //   'data': previewData.printCommands,
  //     //       // });

  //     //      await BluetoothPrinterHandler.printRaw(previewData.printCommands);
  //     //     },
  //     //   ),
  //     // );

  //     // BluetoothPrinterHandler.printRaw(previewData);

  //     //EF1E250B-0E58-9D8E-AA25-D59004BE2971
  //     //EF1E250B-0E58-9D8E-AA25-D59004BE2971

  //     // messages.add('✓ Scan command sent successfully');
  //     // Helpers.showMessage(msg: 'Scan command sent successfully');
  //   } catch (e) {
  //     Helpers.showMessage(msg: '✗ Scan failed: $e');
  //     messages.add('✗ Scan failed: $e');
  //   }
  // }

  Future<void> _runDiagnostics(BuildContext context) async {
    if (BluetoothPrinterHandler.isConnected) {
      await testPrint();
      return;
    }

    final List<Map<String, dynamic>> foundDevices = [];

    // Declare BEFORE usage
    StateSetter? dialogSetState;

    // Start scanning
    await BluetoothPrinterHandler.scanDevices();

    // Listen for discovered devices
    BluetoothPrinterHandler.setDeviceFoundCallback((device) {
      if (!foundDevices.any((d) => d['address'] == device['address'])) {
        foundDevices.add(device);
      }
    });

    await Future.delayed(const Duration(seconds: 2));

    // Stop scan BEFORE opening dialog
    // await BluetoothPrinterHandler.stopScan();

    if (!context.mounted) {
      return;
    }

    // Show dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Available Printers"),
          content: StatefulBuilder(
            builder: (context, setState) {
              dialogSetState = setState;

              return SizedBox(
                width: 300,
                height: 300,

                child: foundDevices.isEmpty
                    ? const Center(child: Text("Scanning..."))
                    : ListView.builder(
                        itemCount: foundDevices.length,
                        itemBuilder: (context, index) {
                          final dev = foundDevices[index];
                          return ListTile(
                            key: ValueKey(dev['address']),
                            leading: const Icon(Icons.print),
                            title: Text(dev['name'] ?? 'Unknown'),
                            subtitle: Text(dev['address'] ?? ''),
                            onTap: () {
                              Navigator.pop(context);
                              connectPrint(dev['address'], dev['name']);
                            },
                          );
                        },
                      ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> connectPrint(String address, String name) async {
    if (!BluetoothPrinterHandler.isConnected) {
      await BluetoothPrinterHandler.connectDevice(address);

      Helpers.showMessage(
        msg: "Connected to printer at $name",
        status: MessageStatus.success,
      );
    }
  }

  Future<void> testPrint() async {
    try {
      // await BluetoothPrinterHandler.disconnect();
      // await BluetoothPrinterHandler.connectDevice(address);

      Helpers.showMessage(msg: "Test print", status: MessageStatus.success);

      // final buffer = StringBuffer();
      // buffer.writeln("ប្លូតិចឡូជី");
      // buffer.writeln("BLUE TECHNOLOGY CO., LTD");
      // buffer.writeln('Hello, សួរស្ដី');
      // buffer.writeln();
      // buffer.writeln('Description    Qty  Price  Amount');
      // buffer.writeln('--------------------------------');
      // buffer.writeln('--------------------------------');
      // buffer.write('អរគុណ - Thank You!');

      // Uint8List utf8Bytes = Uint8List.fromList(utf8.encode(buffer.toString()));

      // ESC/POS: enable UTF-8
      // final Uint8List initUtf8 = Uint8List.fromList([0x1B, 0x74, 0x00]);

      // // Combine both
      // final Uint8List finalBytes = Uint8List.fromList([
      //   ...initUtf8,
      //   ...utf8Bytes,
      // ]);

      // Send to printer
      // await BluetoothPrinterHandler.printRaw(utf8Bytes);

      final pngBytes = await captureKhmerReceipt(context);

      Helpers.showMessage(msg: "KKKK", status: MessageStatus.success);

      await BluetoothPrinterHandler.printImage(pngBytes);

      Helpers.showMessage(
        msg: "Print Successful",
        status: MessageStatus.success,
      );

      // await BluetoothPrinterHandler.disconnect();
    } catch (e) {
      print(e);
      Helpers.showMessage(msg: "Print Error: $e", status: MessageStatus.errors);
    }
  }

  optionView() {
    return CustomSpeedDial(
      children: [
        SpeedDialChild(
          icon: Icons.group_rounded,
          onTap: () => pushToSalePersonMap(),
          label: greeting("SalePersons"),
        ),
        SpeedDialChild(
          icon: Icons.person,
          onTap: () => pushToCustomerMap(),
          label: greeting("Customers"),
        ),
      ],
    );
  }

  Future<Object?> pushToCustomerMap() {
    return Navigator.pushNamed(
      context,
      CustomerScheduleMapScreen.routeName,
      arguments: true,
    );
  }

  Future<Object?> pushToSalePersonMap() {
    return Navigator.pushNamed(
      context,
      SalesPersonMapScreen.routeName,
      arguments: true,
    );
  }

  _onOption() {
    if (_cubit.state.activeTap != 0) {
      Helpers.showMessage(
        msg: "This feature isn't available yet",
        status: MessageStatus.warning,
      );
      return;
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: false,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(scaleFontSize(16)),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                HeaderBottomSheet(
                  childWidget: TextWidget(
                    text: greeting("choose_option_below."),
                    color: white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  children: options.asMap().entries.map((entry) {
                    final option = entry.value;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        8.scale,
                        8.scale,
                        8.scale,
                        4.scale,
                      ),
                      child: BuildOptions(
                        key: ValueKey(entry.key),
                        onTap: option.onTap,
                        icon: option.icon,
                        label: greeting(option.label),
                        trailing: option.trailing,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget builderThemCalendar(context, child) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: white,
        datePickerTheme: const DatePickerThemeData(
          headerBackgroundColor: primary,
          headerForegroundColor: white,
          backgroundColor: white,
        ),
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      child: child!,
    );
  }
}
