import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ButtomSheetFilterWidget extends StatelessWidget {
  const ButtomSheetFilterWidget({
    super.key,
    this.widgetStartDate,
    this.widgetToDate,
    this.widgetDropDown,
    this.widgetBtnApply,
    this.widgetResetFilter,
    this.widgetSalesperson,
  });

  final Widget? widgetResetFilter;
  final Widget? widgetStartDate;
  final Widget? widgetToDate;
  final Widget? widgetDropDown;
  final Widget? widgetBtnApply;
  final Widget? widgetSalesperson;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderBottomSheet(
            childWidget: TextWidget(
              text: greeting("filter_options"),
              color: white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [_changeOption()],
          ),
          _datePicker(),
          changeButton(),
        ],
      ),
    );
  }

  Widget changeButton() {
    if (widgetResetFilter == null) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.scale),
          child: widgetBtnApply ?? const SizedBox(),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.scale),
      child: Row(
        children: [
          Expanded(child: widgetResetFilter ?? const SizedBox()),
          const SizedBox(width: 8),
          Expanded(child: widgetBtnApply ?? const SizedBox()),
        ],
      ),
    );
  }

  Widget _changeOption() {
    if (widgetSalesperson != null) {
      return _selectSalesperson();
    }
    return _selectStatus();
  }

  Widget _selectStatus() {
    return Padding(
      padding: EdgeInsets.all(8.scale),
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: greeting("status"), fontSize: 16, fontWeight: FontWeight.bold),
          BoxWidget(
            isBoxShadow: false,
            isBorder: true,
            padding: EdgeInsets.symmetric(horizontal: 8.scale),
            child: widgetDropDown ?? Container(),
          ),
        ],
      ),
    );
  }

  Column _selectSalesperson() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(textAlign: TextAlign.left, text: greeting("saleperson")),
        Container(
          height: 40.scale,
          padding: EdgeInsets.symmetric(horizontal: 8.scale),
          decoration: BoxDecoration(
            border: Border.all(color: grey, width: 1),
            color: white,
            borderRadius: BorderRadius.circular(4.scale),
          ),
          child: widgetSalesperson,
        ),
      ],
    );
  }

  Widget _datePicker() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.scale,
          children: [
            TextWidget(text: greeting("date_range"), fontSize: 16, fontWeight: FontWeight.bold),
            widgetStartDate ?? Container(),
            TextWidget(text: greeting("to"), fontSize: 14, color: textColor50),
            widgetToDate ?? Container(),
          ],
        ),
      ),
    );
  }
}
