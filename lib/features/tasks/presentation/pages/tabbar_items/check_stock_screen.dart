import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/tab_bar_widget.dart';

import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_competitor_stock/check_item_competitor_stock_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_stock/check_item_stock_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';

class CheckStockScreen extends StatelessWidget {
  static const String routeName = "checkStockScreen";
  CheckStockScreen({super.key, required this.args});

  final CheckStockArgs args;

  final List<Tab> tabBarName = [Tab(text: greeting("items")), Tab(text: greeting("competitor_items"))];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabBarName.length,
      child: Scaffold(
        appBar: AppBarWidget(
          heightBottom: heightBottomSearch,
          title: greeting("check_stock"),
          bottom: TabBarWidget(tabs: tabBarName),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            CheckItemStockScreen(schedule: args.schedule, customerNo: args.customerNo),
            CheckItemCompetitorStockScreen(schedule: args.schedule),
          ],
        ),
      ),
    );
  }
}
