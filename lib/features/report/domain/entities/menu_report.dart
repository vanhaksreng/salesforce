import 'package:flutter/material.dart';
import 'package:salesforce/features/report/main_page_report_screen.dart';

class MenuReport {
  final String title;
  final String? subTitle;
  final String? routeName;
  final ReportArgs? args;
  final IconData? icon;
  final bool show;

  const MenuReport({required this.title, this.show = false, this.subTitle, this.routeName, this.args, this.icon});
}
