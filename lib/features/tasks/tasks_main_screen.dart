import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/custom_alert_dialog_widget.dart';
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
import 'package:salesforce/features/tasks/presentation/pages/schedule_history/schedule_history_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/task_component/build_options.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedult/team_schedult_screen.dart';
import 'package:salesforce/features/tasks/tasks_main_cubit.dart';
import 'package:salesforce/features/tasks/tasks_main_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class TasksMainScreen extends StatefulWidget {
  const TasksMainScreen({super.key});
  static const String routeName = "taskScreen";
  static const String name = "Tasks";

  @override
  State<TasksMainScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TasksMainScreen> with SingleTickerProviderStateMixin {
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

    // final locationService = GeolocatorLocationService();
    // locationService.checkPermission().then((status) {
    //   if (status == LocationPermissionStatus.denied || status == LocationPermissionStatus.deniedForever) {
    //     throw GeneralException('Location permissions are denied. Please enable them in app settings. $status');
    //   }
    // });
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
    ScheduleOptionData(label: "Refresh Schedules (Today)", icon: Icons.refresh, onTap: _refreshSchedules),
    ScheduleOptionData(
      label: "My Schedule History",
      icon: Icons.checklist,
      onTap: _navigateToScheduleHistory,
      trailing: Icon(Icons.arrow_forward_ios, size: scaleFontSize(14), color: grey),
    ),
    ScheduleOptionData(
      label: "Add New Schedule",
      icon: Icons.add,
      onTap: _navigateToAddSchedule,
      trailing: Icon(Icons.arrow_forward_ios, size: scaleFontSize(14), color: grey),
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
            title: "${greeting("Today")}, ${DateTime.now().toDateNameSortString()}",
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
              MyScheduleScreen(refresh: state.refreshChild, searchText: state.text),
              const TeamSchedultScreen(),
            ],
          ),
          floatingActionButton: showMapCustomer(),
        );
      },
    );
  }

  showMapCustomer() {
    return SizedBox(
      width: 45.scale,
      height: 45.scale,
      child: FloatingActionButton(
        backgroundColor: mainColor,
        onPressed: () => Navigator.pushNamed(context, CustomerScheduleMapScreen.routeName, arguments: true),
        child: const Icon(Icons.group_rounded),
      ),
    );
  }

  _onOption() {
    if (_cubit.state.activeTap != 0) {
      Helpers.showMessage(msg: "This feature isn't available yet", status: MessageStatus.warning);
      return;
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: false,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(scaleFontSize(16)))),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      padding: EdgeInsets.fromLTRB(8.scale, 8.scale, 8.scale, 4.scale),
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
