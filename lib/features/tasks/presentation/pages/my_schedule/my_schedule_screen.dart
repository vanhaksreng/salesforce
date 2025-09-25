import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/card_scheduled.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkin_out/checkin_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/my_schedule/my_schedule_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/my_schedule/my_schedule_state.dart';
import 'package:salesforce/features/tasks/presentation/pages/process/process_screen.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({
    super.key,
    this.refresh = false,
    required this.searchText,
  });

  final String searchText;
  final bool refresh;

  @override
  State<MyScheduleScreen> createState() => MyScheduleScreenState();
}

class MyScheduleScreenState extends State<MyScheduleScreen>
    with MessageMixin, AutomaticKeepAliveClientMixin {
  final _cubit = MyScheduleCubit();
  final ILocationService _location = GeolocatorLocationService();

  late DateTime scheduleDate;
  final String selectedStatus = kStatusCheckIn;
  ActionState action = ActionState.init;
  String? checkInWithLocation;

  final List<String> _listStatus = [
    "All",
    kStatusScheduled,
    kStatusCheckIn,
    kStatusCheckOut,
  ];

  @override
  void initState() {
    super.initState();
    scheduleDate = DateTime.now();
    _cubit.getUserSetup();
    _cubit.getCurrentLocation();
    checkInitWithLocation();
    refreshSchedule();
  }

  @override
  bool get wantKeepAlive => true;

  void refreshSchedule() {
    _cubit.getSchedules(scheduleDate);
    _cubit.getSaleLine(scheduleDate);
  }

  @override
  void didUpdateWidget(MyScheduleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cubit.getSchedules(scheduleDate, text: widget.searchText);
    if (oldWidget.refresh != widget.refresh) {
      refreshSchedule();
    }
  }

  Future<LatLng> getCurrentLocation() async {
    final current = await _location.getCurrentLocation();
    return LatLng(current.latitude, current.longitude);
  }

  _navigateToProcessScreen(SalespersonSchedule schedule, String customerNo) {
    if (schedule.status != kStatusCheckIn) {
      Helpers.showMessage(
        msg: greeting("please_check_in_before_process"),
        status: MessageStatus.warning,
      );
    }

    Navigator.pushNamed(
      context,
      ProcessScreen.routeName,
      arguments: CheckStockArgs(schedule: schedule, customerNo: customerNo),
    ).then((value) {
      if (value == null) {
        return;
      }
      _cubit.getSaleLine(scheduleDate);
    });
  }

  Future<void> checkInitWithLocation() async {
    checkInWithLocation = await _cubit.getSetting(kCheckInWithLocation);
  }

  void _checkInHandler(SalespersonSchedule schedule) async {
    final l = LoadingOverlay.of(context);
    l.show();
    try {
      // Check pending schedules
      await _cubit.pendingScheduleValidate();

      final String useGps = await _cubit.getSetting(kGpsRealTimeTracking);
      if (checkInWithLocation == "Yes" || useGps == kStatusYes) {
        final permStatus = await perm.Permission.locationWhenInUse.status;
        if (!mounted) return;

        if (permStatus != perm.PermissionStatus.granted) {
          l.hide();
          Helpers.showDialogAction(
            context,
            labelAction: "Location Access Required",
            subtitle:
                "As required by your company, the app needs access to your current location. This is essential for tracking your check-in and check-out activities at customer sites.",
            confirmText: "Go to Settings",
            confirm: () async {
              await perm.openAppSettings();
              if (!mounted) return;
              Navigator.pop(context);
            },
            cancelText: "Not Now",
          );
          return;
        }

        if (useGps == kStatusYes) {
          final permStatus1 = await perm.Permission.locationAlways.status;
          if (!mounted) return;

          if (permStatus1 != perm.PermissionStatus.granted) {
            l.hide();
            Helpers.showDialogAction(
              context,
              labelAction: "Background Location Access Needed",
              subtitle:
                  "As required by your company, the app needs access to your location even when running in the background. This is essential for tracking your check-in and check-out activities at customer sites.",
              confirmText: "Go to Settings",
              confirm: () async {
                await perm.openAppSettings();
                if (!mounted) return;
                Navigator.pop(context);
              },
              cancelText: "Not Now",
            );

            return;
          }
        }
      }

      final areaByMeters = Helpers.toDouble(
        await _cubit.getSetting(kCheckedInAreaKey),
      );

      if (areaByMeters > 0) {
        final currentLocation = await getCurrentLocation();
        if (currentLocation.latitude == 0 && currentLocation.longitude == 0) {
          throw GeneralException(
            greeting("Your current location is not available."),
          );
        }

        final double distInMeters = _location.getDistanceBetween(
          schedule.latitude ?? 0,
          schedule.longitude ?? 0,
          currentLocation.latitude,
          currentLocation.longitude,
        );

        if (areaByMeters < distInMeters) {
          throw GeneralException(
            greeting(
              "must_within_store_checkin",
              params: {
                'value': Helpers.formatNumber(
                  areaByMeters,
                  option: FormatType.quantity,
                ),
              },
            ),
          );
        }
      }

      l.hide();

      if (!mounted) return;
      _navigateToCheckInScreen(schedule);
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception {
      l.hide();
      showErrorMessage();
    }
  }

  void checkOutHandler(SalespersonSchedule schedule) async {
    final l = LoadingOverlay.of(context);
    l.show();

    try {
      if (schedule.planned == kStatusYes) {
        final areaByMeters = Helpers.toDouble(
          await _cubit.getSetting(kCheckedOutAreaKey),
        );

        if (areaByMeters > 0) {
          final currentLocation = await getCurrentLocation();
          if (currentLocation.latitude == 0 && currentLocation.longitude == 0) {
            throw GeneralException(
              greeting("Your current location is not available."),
            );
          }

          final double distInMeters = _location.getDistanceBetween(
            schedule.latitude ?? 0,
            schedule.longitude ?? 0,
            currentLocation.latitude,
            currentLocation.longitude,
          );

          if (areaByMeters < distInMeters) {
            throw GeneralException(
              greeting(
                "must_within_store_checkout",
                params: {
                  'value': Helpers.formatNumber(
                    areaByMeters,
                    option: FormatType.quantity,
                  ),
                },
              ),
            );
          }
        }

        await _cubit.initLoadPendingTasks(schedule);

        if (_cubit.state.countCheckStock > 0) {
          throw GeneralException("You missing to complete check stock.");
        }

        if (_cubit.state.countPosm > 0) {
          throw GeneralException("You missing to complete posm.");
        }

        if (_cubit.state.countMerchandising > 0) {
          throw GeneralException("You missing to complete merchandising.");
        }

        if (_cubit.state.countSaleOrder > 0) {
          throw GeneralException("You missing to complete sale order.");
        }

        if (_cubit.state.countSaleInvoice > 0) {
          throw GeneralException("You missing to complete sale invoice.");
        }

        if (_cubit.state.countSaleCreditMemo > 0) {
          throw GeneralException("You missing to complete sale credit memo.");
        }

        if (_cubit.state.countItemPrizeRedeption > 0) {
          throw GeneralException(
            "You missing to complete item prize redemption.",
          );
        }

        if (!await _cubit.hasPermission(kPSkipCheckStock)) {
          if (_cubit.state.checkItemStockRecords.isEmpty) {
            throw GeneralException("You missing to check item stock.");
          }
        }

        if (!await _cubit.hasPermission(kPSkipCheckCompetitorStock)) {
          if (_cubit.state.checkCompetitorItemStockRecords.isEmpty) {
            throw GeneralException(
              "You missing to check competitor's item stock",
            );
          }
        }

        if (!await _cubit.hasPermission(kPSkipCheckPosm)) {
          if (_cubit.state.checkPosmRecords.isEmpty) {
            throw GeneralException("You missing to check posm");
          }
        }

        if (!await _cubit.hasPermission(kPSkipCheckMerchandise)) {
          if (_cubit.state.checkMerchandiseRecords.isEmpty) {
            throw GeneralException("You missing to check merchandise");
          }
        }
      }

      l.hide();
      _navigateToCheckInScreen(schedule);
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception {
      l.hide();
      showErrorMessage();
    }
  }

  void _navigateToCheckInScreen(SalespersonSchedule schedule) {
    if (!mounted) {
      return;
    }

    Navigator.pushNamed(
      context,
      CheckinScreen.routeName,
      arguments: schedule,
    ).then((value) {
      if (value == null) {
        return;
      }

      refreshSchedule();
    });
  }

  double calculateTarget(int checkedOut, int totalTodaySchedule) {
    if (totalTodaySchedule == 0) {
      return 0;
    }

    return (checkedOut / totalTodaySchedule) * 100;
  }

  double culculateTotalSaleByCustomer(String customerNo, String visitNo) {
    double totalSaleInv = _cubit.state.saleLines
        .where((e) {
          return e.customerNo == customerNo &&
              e.sourceNo == visitNo &&
              [kSaleInvoice, kSaleOrder].contains(e.documentType);
        })
        .fold(
          0.0,
          (sum, saleLine) =>
              sum + Helpers.toDouble(saleLine.amountIncludingVatLcy ?? ""),
        );

    double totalSaleCr = _cubit.state.saleLines
        .where((e) {
          return e.customerNo == customerNo &&
              e.sourceNo == visitNo &&
              e.documentType == kSaleCreditMemo;
        })
        .fold(
          0.0,
          (sum, saleLine) =>
              sum + Helpers.toDouble(saleLine.amountIncludingVatLcy ?? ""),
        );

    return totalSaleInv - totalSaleCr;
  }

  Future<void> _onApplyFilter({
    required bool sortByDistance,
    required String selectedStatus,
  }) async {
    Navigator.of(context).pop();
    final l = LoadingOverlay.of(context);
    try {
      l.show();
      await _cubit.getSchedules(scheduleDate);

      if (sortByDistance) {
        _cubit.sortCustomerViaLatlng(
          currentLocation: await getCurrentLocation(),
        );
      }

      if (!mounted) return;
    } catch (e) {
      showErrorMessage();
    } finally {
      l.hide();
    }
  }

  void showModalFilter() {
    modalBottomSheet(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBottomSheet(
            childWidget: TextWidget(
              text: greeting("Filter"),
              color: white,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildFilter(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocBuilder<MyScheduleCubit, MyScheduleState>(
        bloc: _cubit,
        builder: (BuildContext context, MyScheduleState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }
          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(MyScheduleState state) {
    final List<SalespersonSchedule> records = state.schedules;

    return RefreshIndicator(
      color: mainColor50,
      onRefresh: () async => _cubit.loadAppSetting(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(scaleFontSize(appSpace)),
        child: Column(
          spacing: scaleFontSize(appSpace),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: greeting("Today's Performance"),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            Column(
              spacing: scaleFontSize(appSpace),
              children: [
                Row(
                  spacing: scaleFontSize(appSpace),
                  children: [
                    _buildInfo(
                      label: Helpers.formatNumberLink(
                        state.totalVisit,
                        option: FormatType.quantity,
                      ),
                      value: greeting("Visit"),
                      labelColor: success,
                      bgLabelColor: success,
                    ),
                    _buildInfo(
                      label: Helpers.formatNumberLink(
                        state.totalSales,
                        option: FormatType.amount,
                      ),
                      value: greeting("Sales Amt"),
                      labelColor: mainColor,
                      bgLabelColor: mainColor,
                    ),
                  ],
                ),
                Row(
                  spacing: scaleFontSize(appSpace),
                  children: [
                    _buildInfo(
                      label: Helpers.formatNumberLink(
                        (state.totalVisit - state.countCheckOut),
                        option: FormatType.quantity,
                      ),
                      value: greeting("Pending"),
                      labelColor: warning,
                      bgLabelColor: warning,
                    ),
                    _buildInfo(
                      label: Helpers.formatNumberLink(
                        calculateTarget(state.countCheckOut, state.totalVisit),
                        option: FormatType.percentage,
                      ),
                      value: greeting("Target"),
                      labelColor: success,
                      bgLabelColor: success,
                    ),
                  ],
                ),
              ],
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerCustomerVisit(state),
                _listCustomerVisit(records, state),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String gpsDisplay(double distInMeters) {
    final double distInKm = distInMeters / 1000;

    if (distInKm > 1) {
      return "${Helpers.formatNumberLink(distInKm, option: FormatType.quantity)}km";
    }

    return "${Helpers.formatNumberLink(distInMeters, option: FormatType.quantity)}m";
  }

  Widget _listCustomerVisit(
    List<SalespersonSchedule> records,
    MyScheduleState state,
  ) {
    if (records.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 2.5,
        child: EmptyScreen(),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int index) {
        final record = records[index];

        double totalSalesBySchedule = culculateTotalSaleByCustomer(
          record.customerNo ?? "", record.id
        );

        return Padding(
          padding: EdgeInsets.symmetric(vertical: scaleFontSize(4)),
          child: ScheduleCard(
            distance: gpsDisplay(Helpers.toDouble(record.distance)),
            totalSale: totalSalesBySchedule,
            key: ValueKey(record.id),
            onCheckIn: (schedule) => _checkInHandler(schedule),
            onCheckOut: (schedule) => checkOutHandler(schedule),
            onProcess: (schedule) =>
                _navigateToProcessScreen(schedule, record.customerNo ?? ""),
            isLoading: state.isLoadingId == record.id,
            schedule: record,
          ),
        );
      },
    );
  }

  Row _headerCustomerVisit(MyScheduleState state) {
    final isResetActive = state.isSortDistance || state.selectedStatus != "All";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(
          text: greeting("Customer Visits"),
          fontWeight: FontWeight.bold,
        ),
        Badge(
          isLabelVisible: isResetActive,
          child: BtnTextWidget(
            rounded: 4,
            vertical: 4,
            borderColor: grey20,
            bgColor: white,
            horizontal: 4,
            onPressed: () => showModalFilter(),
            child: Row(
              spacing: 4.scale,
              children: [
                TextWidget(text: greeting("Filter")),
                Icon(Icons.sort, size: 16.scale, color: textColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilter() {
    return BlocBuilder<MyScheduleCubit, MyScheduleState>(
      bloc: _cubit,
      builder: (context, state) {
        final isResetActive =
            state.isSortDistance || state.selectedStatus != "All";
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: scaleFontSize(appSpace),
            horizontal: scaleFontSize(8),
          ),
          child: Column(
            spacing: scaleFontSize(appSpace),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: greeting("Sort by Nearly"),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              InkWell(
                onTap: () => _cubit.changeSortBy(!state.isSortDistance),
                child: Column(
                  spacing: 8.scale,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8.scale,
                      children: [
                        Icon(
                          state.isSortDistance
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: state.isSortDistance ? primary : textColor50,
                        ),
                        Expanded(
                          child: Column(
                            spacing: 8.scale,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: greeting("Sort by Distance"),
                                fontWeight: FontWeight.w400,
                              ),
                              TextWidget(
                                text: greeting(
                                  "Sort by distance will sort customer by your current location.",
                                ),
                                color: textColor50,
                                fontSize: 12,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextWidget(
                text: greeting("Status"),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 8.scale,
                runSpacing: 10.scale,
                children: _listStatus.map((status) {
                  bool isHasSelected = state.selectedStatus == status;
                  return BtnTextWidget(
                    rounded: 16,
                    vertical: 8,
                    horizontal: 16,
                    borderColor: grey20,
                    bgColor: isHasSelected ? mainColor : grey20,
                    onPressed: () => _cubit.changeStatus(status),
                    child: TextWidget(
                      text: status,
                      color: isHasSelected ? white : textColor,
                    ),
                  );
                }).toList(),
              ),
              const Hr(width: double.infinity),
              BtnWidget(
                gradient: linearGradient,
                onPressed: () => _onApplyFilter(
                  selectedStatus: state.selectedStatus,
                  sortByDistance: state.isSortDistance,
                ),
                title: greeting("Apply Filter"),
              ),
              BtnWidget(
                bgColor: isResetActive ? error : grey20,
                onPressed: () => _cubit.resetStatus(),
                isDisabled: !isResetActive,
                title: greeting("Reset"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfo({
    required String label,
    required String value,
    Color labelColor = textColor,
    Color bgLabelColor = white,
  }) {
    return Expanded(
      child: BoxWidget(
        color: bgLabelColor.withValues(alpha: 0.05),
        isBorder: true,
        borderColor: grey20,
        padding: EdgeInsets.all(scaleFontSize(appSpace)),
        isBoxShadow: false,
        child: Column(
          spacing: scaleFontSize(8),
          children: [
            TextWidget(
              text: label,
              fontSize: 20,
              color: labelColor,
              fontWeight: FontWeight.bold,
            ),
            TextWidget(
              text: value,
              color: textColor50,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
