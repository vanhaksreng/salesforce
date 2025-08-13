import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class HeaderScheduleReport extends StatelessWidget {
  const HeaderScheduleReport({super.key, required this.formDate, required this.toDate});
  final String formDate;
  final String toDate;

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      height: 45,
      margin: const EdgeInsets.all(appSpace),
      padding: const EdgeInsets.symmetric(vertical: appSpace8),
      width: double.infinity,
      gradient: linearGradient,
      // color: searchBgColor,
      // borderColor: borderClr,
      isBorder: false,
      isBoxShadow: false,
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 20.scale, color: white),
          TextWidget(
            text: " $formDate to ${toDate}",
            color: white,
            // fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}
