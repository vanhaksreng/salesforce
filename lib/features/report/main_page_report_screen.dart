import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/report/domain/entities/menu_report.dart';
import 'package:salesforce/features/report/main_page_report_cubit.dart';
import 'package:salesforce/features/report/main_page_report_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

abstract class ReportArgs {}

class MainPageReportScreen extends StatefulWidget {
  const MainPageReportScreen({super.key});

  @override
  State<MainPageReportScreen> createState() => _MainPageReportScreenState();
}

class _MainPageReportScreenState extends State<MainPageReportScreen> {
  final _cubit = MainPageReportCubit();

  @override
  void initState() {
    super.initState();
    _cubit.initLoadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(isBackIcon: false, title: greeting("report")),
      body: BlocBuilder<MainPageReportCubit, MainPageReportState>(
        bloc: _cubit,
        builder: (context, MainPageReportState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          final reports = state.reports;

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: 8.scale),
            itemCount: reports.length,
            itemBuilder: (context, index) => _buildReportItem(reports[index]),
          );
        },
      ),
    );
  }

  Widget _buildReportItem(MenuReport menu) {
    // if (!menu.show) {
    //   return const SizedBox.shrink();
    // }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleFontSize(2)),
      child: ListTitleWidget(
        leading: Icon(menu.icon, size: 24.scale, color: mainColor),
        subTitle: menu.subTitle ?? "",
        onTap: () => Navigator.pushNamed(context, menu.routeName ?? "", arguments: menu.args),
        label: menu.title,
      ),
    );
  }
}
