import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
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
    await _cubit.getTeamSchedules("2025-09-30");
  }

  Future<void> _handleSelectedDownline(SalePersonGpsModel dnline) async {
    _cubit.selectDownline(dnline);
    final downLine = _cubit.state.downLine;
    await _cubit.getTeamSchedules(
      "2025-09-30",
      param: {"downline_code": downLine?.code},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("Team Schedule History")),
      body: BlocBuilder<TeamScheduleHistoryCubit, TeamScheduleHistoryState>(
        bloc: _cubit,

        builder: (BuildContext context, TeamScheduleHistoryState state) {
          if (state.isLoading) {
            return LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(TeamScheduleHistoryState state) {
    return Column(
      children: [_buildSalesPersonDownlines(state), _buildListSchedule(state)],
    );
  }

  Widget _buildListSchedule(TeamScheduleHistoryState state) {
    final teamSchedules = state.teamScheduleSalePersons;
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: teamSchedules.length,
        shrinkWrap: true,
        itemBuilder: (context, idx) {
          final teamSchedule = teamSchedules[idx];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: scaleFontSize(4)),
            child: ScheduleCard(
              distance: 100.toString(),
              totalSale: 100,
              onCheckIn: (schedule) {},
              onCheckOut: (schedule) {},
              onProcess: (schedule) {},
              isLoading: false,
              schedule: teamSchedule,
            ),
          );
        },
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
          bool isSelected = state.downLine == downline;

          return _buildDownline(downline, isSelected);
        },
      ),
    );
  }

  Widget _buildDownline(SalePersonGpsModel downline, bool isSelected) {
    return GestureDetector(
      onTap: () => _handleSelectedDownline(downline),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scaleFontSize(4)),
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
                  borderColor: isSelected ? primary : primary20,
                  bgColor: isSelected ? primary : primary20,
                  horizontal: scaleFontSize(2),
                  vertical: scaleFontSize(2),
                  child: TextWidget(
                    text: downline.name,
                    fontSize: 10,
                    color: isSelected ? white : primary,
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
