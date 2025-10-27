import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/no_internet_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/features/tasks/presentation/pages/card_scheduled.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedule_history/team_schedule_history_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedule_history/team_schedule_history_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class TeamScheduleHistoryScreen extends StatefulWidget {
  const TeamScheduleHistoryScreen({super.key});
  static const String routeName = "teamScheduleHistory";

  @override
  TeamScheduleHistoryScreenState createState() =>
      TeamScheduleHistoryScreenState();
}

class TeamScheduleHistoryScreenState extends State<TeamScheduleHistoryScreen> {
  final _cubit = TeamScheduleHistoryCubit();

  @override
  void initState() {
    onInit();
    super.initState();
  }

  Future<void> onInit() async {
    await _cubit.getSalePersonDownline();
    _handleSelectedDownline("");
  }

  Future<void> _handleSelectedDownline(String? dnline) async {
    _cubit.selectDownline(dnline);
    final data = _cubit.state;
    await _cubit.getTeamSchedules(
      param: {
        "downline_code": _cubit.state.downLineCode,
        "visit_date": (data.scheduleDate ?? DateTime.now()).toDateString(),
      },
      isLoadingSchedule: true,
    );
  }

  void _onChangeDateHandler(DateTime scheduleDate) {
    showDatePicker(
      context: context,
      initialDate: scheduleDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: greeting("select_date"),
      cancelText: greeting("cancel"),
      confirmText: greeting("ok"),
    ).then((selectedDate) {
      if (selectedDate != null) {
        _cubit.selectDateTime(selectedDate);
        _cubit.getTeamSchedules(
          param: {
            "downline_code": _cubit.state.downLineCode,
            "visit_date": selectedDate.toDateString(),
          },
          isLoadingSchedule: true,
        );
      }
    });
  }

  String _buildTitle(DateTime scheduleDate) {
    return "${greeting("Team Schedule History")} \n ${scheduleDate.toRelativeDate()}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamScheduleHistoryCubit, TeamScheduleHistoryState>(
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBarWidget(
            title: _buildTitle(state.scheduleDate ?? DateTime.now()),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: scaleFontSize(appSpace)),
                child: BtnIconCircleWidget(
                  onPressed: () => _onChangeDateHandler(
                    state.scheduleDate ?? DateTime.now(),
                  ),
                  icons: const Icon(Icons.calendar_month, color: white),
                  rounded: appBtnRound,
                ),
              ),
            ],
          ),
          body: buildBody(state),
        );
      },
    );
  }

  Widget buildBody(TeamScheduleHistoryState state) {
    return Column(
      children: [
        _buildSalesPersonDownlines(state),
        Hr(width: double.infinity, color: grey20),
        if (state.isLoadingSchedule) ...[
          Expanded(child: LoadingPageWidget()),
        ] else if (state.error == errorInternetMessage) ...[
          Expanded(child: NoInternetScreen()),
        ] else if (state.teamScheduleSalePersons.isEmpty) ...[
          Expanded(child: EmptyScreen()),
        ] else ...[
          _buildListSchedule(state),
        ],
      ],
    );
  }

  Widget _buildListSchedule(TeamScheduleHistoryState state) {
    final teamSchedules = state.teamScheduleSalePersons;
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () => _handleSelectedDownline(state.downLineCode),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: teamSchedules.length,
          shrinkWrap: true,
          itemBuilder: (context, idx) {
            final teamSchedule = teamSchedules[idx];

            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: scaleFontSize(4),
                horizontal: scaleFontSize(16),
              ),
              child: ScheduleCard(
                distance: "N/A",
                totalSale: 0,
                isReadOnly: true,
                onCheckIn: (schedule) {},
                onCheckOut: (schedule) {},
                onProcess: (schedule) {},
                isLoading: false,
                schedule: teamSchedule,
              ),
            );
          },
        ),
      ),
    );
  }

  BoxWidget _buildSalesPersonDownlines(TeamScheduleHistoryState state) {
    final downlines = state.downLines;

    return BoxWidget(
      width: double.infinity,
      rounding: 0,
      isBoxShadow: false,
      color: white,

      padding: EdgeInsets.symmetric(vertical: scaleFontSize(8)),
      height: scaleFontSize(110),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: downlines.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final downline = downlines[index];
          bool isSelected = state.downLineCode == downline.code;

          return _buildDownline(downline, isSelected);
        },
      ),
    );
  }

  Widget _buildDownline(SalePersonGpsModel downline, bool isSelected) {
    return GestureDetector(
      onTap: () => _handleSelectedDownline(downline.code),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scaleFontSize(8)),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? primary : grey,
              radius: scaleFontSize(25),
              child: Padding(
                padding: EdgeInsets.all(scaleFontSize(2)),
                child: downline.code == ""
                    ? Icon(Icons.group)
                    : ImageNetWorkWidget(
                        round: scaleFontSize(55),
                        imageUrl: downline.avatar,
                        width: scaleFontSize(55),
                        height: scaleFontSize(55),
                      ),
              ),
            ),
            Expanded(
              child: SizedBox(
                width: scaleFontSize(60),
                child: ChipWidget(
                  borderColor: isSelected ? primary : Colors.transparent,
                  bgColor: isSelected ? primary : Colors.transparent,
                  horizontal: scaleFontSize(1),
                  vertical: scaleFontSize(0),
                  child: TextWidget(
                    text: downline.name,
                    fontSize: 12,
                    color: isSelected ? white : textColor,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
