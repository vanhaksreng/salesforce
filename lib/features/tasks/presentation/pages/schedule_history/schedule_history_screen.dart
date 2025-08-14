import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/card_scheduled.dart';
import 'package:salesforce/features/tasks/presentation/pages/schedule_history/schedule_history_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/schedule_history/schedule_history_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ScheduleHistoryScreen extends StatefulWidget {
  const ScheduleHistoryScreen({super.key});

  static const String routeName = "scheduleHistory";

  @override
  State<ScheduleHistoryScreen> createState() => _ScheduleHistoryScreenState();
}

class _ScheduleHistoryScreenState extends State<ScheduleHistoryScreen> {
  final _cubit = ScheduleHistoryCubit();

  late DateTime scheduleDate;

  @override
  void initState() {
    scheduleDate = DateTime.now();
    _cubit.getSchedules(scheduleDate);
    super.initState();
  }

  String _buildTitle() {
    return "${greeting("schedule_history")} - ${scheduleDate.toRelativeDate()}";
  }

  void _onChangeDateHandler() {
    showDatePicker(
      context: context,
      initialDate: scheduleDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: greeting("select_date"),
      cancelText: greeting("cancel"),
      confirmText: greeting("ok"),
    ).then((selectedDate) {
      if (selectedDate != null && selectedDate != scheduleDate) {
        setState(() {
          scheduleDate = selectedDate;
        });
        _cubit.getSchedules(scheduleDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: _buildTitle(),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: scaleFontSize(appSpace)),
            child: BtnIconCircleWidget(
              onPressed: () => _onChangeDateHandler(),
              icons: const Icon(Icons.calendar_month, color: white),
              rounded: appBtnRound,
            ),
          ),
        ],
      ),
      body: BlocBuilder<ScheduleHistoryCubit, ScheduleHistoryState>(
        bloc: _cubit,
        builder: (BuildContext context, ScheduleHistoryState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(ScheduleHistoryState state) {
    final List<SalespersonSchedule> records = state.schedules ?? [];

    if (records.isEmpty) {
      return const EmptyScreen();
    }

    return ListView.builder(
      itemCount: records.length,
      padding: EdgeInsets.only(
        top: scaleFontSize(appSpace8),
        left: scaleFontSize(appSpace),
        right: scaleFontSize(appSpace),
      ),
      itemBuilder: (BuildContext context, int index) {
        final record = records[index];
        return Padding(
          key: ValueKey(record.id),
          padding: EdgeInsets.only(bottom: scaleFontSize(8)),
          child: ScheduleCard(key: ValueKey(record.id), schedule: record, isReadOnly: true),
        );
      },
    );
  }
}
