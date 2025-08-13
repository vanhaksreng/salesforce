import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key, required this.tabs, this.controller, this.onTap});

  final TabController? controller;
  final List<Widget> tabs;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.scale,
      color: background,
      child: TabBar(
        controller: controller,
        onTap: onTap,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: tabs,
        indicatorColor: mainColor,
        labelColor: mainColor,
        indicatorPadding: EdgeInsets.zero,
        dividerColor: secondary.withValues(alpha: 0.3),
        labelStyle: TextStyle(fontSize: scaleFontSize(14), fontWeight: FontWeight.bold, color: textColor50),
      ),
    );
  }
}
