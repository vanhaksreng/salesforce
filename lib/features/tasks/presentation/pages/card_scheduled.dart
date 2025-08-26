import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/dot_line_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:salesforce/core/constants/app_styles.dart';

class ScheduleCard extends StatelessWidget with MessageMixin {
  final SalespersonSchedule schedule;
  final Function(SalespersonSchedule)? onCheckIn;
  final Function(SalespersonSchedule)? onCheckOut;
  final Function(SalespersonSchedule)? onProcess;
  final bool isLoading;
  final bool isReadOnly;
  final double totalSale;
  final String? distance;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.onCheckIn,
    this.onCheckOut,
    this.isLoading = false,
    this.isReadOnly = false,
    this.onProcess,
    this.totalSale = 0,
    this.distance = "0",
  });

  String _getScheduleTitle(String status) {
    if (status == kStatusCheckIn) {
      return greeting("Checked In");
    }

    if (schedule.status != "Scheduled") {
      return greeting("Checked Out");
    }

    return schedule.planned == "Yes" ? "Plan" : "Manual";
  }

  void _actionHandler(String status) {
    if (status == kStatusCheckIn) {
      onCheckOut?.call(schedule);
    } else {
      onCheckIn?.call(schedule);
    }
  }

  Color getScheduleColor(String status) {
    if (schedule.status == kStatusCheckIn) {
      return warning;
    } else if (schedule.status == kStatusCheckOut) {
      return mainColor;
    }
    return success;
  }

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      isBorder: true,
      borderColor: grey20,
      key: ValueKey(schedule.id),
      isBoxShadow: false,
      padding: EdgeInsets.all(scaleFontSize(16)),
      child: Column(
        spacing: scaleFontSize(appSpace),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 15.scale,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  spacing: 8.scale,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: schedule.name ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.scale,
                            ),
                          ),
                          const TextSpan(text: " - "),
                          TextSpan(text: "$distance"),
                        ],
                      ),
                    ),
                    TextWidget(
                      text: schedule.address ?? "",
                      color: textColor50,
                    ),
                  ],
                ),
              ),
              ChipWidget(
                radius: 6,
                colorText: getScheduleColor(schedule.status ?? ""),
                bgColor: getScheduleColor(
                  schedule.status ?? "",
                ).withValues(alpha: 0.1),
                label: _getScheduleTitle(schedule.status ?? ""),
              ),
            ],
          ),
          BoxWidget(
            rounding: 4,
            color: grey20.withValues(alpha: .1),
            isBoxShadow: false,
            padding: EdgeInsets.all(8.scale),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfo(
                  label: Helpers.formatNumberLink(
                    totalSale,
                    option: FormatType.amount,
                  ),
                  value: "Sales Amt",
                ),
                _buildInfo(
                  label: lableText(schedule.startingTime ?? ""),
                  value: "Check In",
                ),
                _buildInfo(
                  label: lableText(schedule.endingTime ?? ""),
                  value: "Check Out",
                ),
              ],
            ),
          ),
          if (schedule.status != kStatusCheckOut && isReadOnly == false) ...[
            const DotLine(),
            Row(
              spacing: 15.scale,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [switchButton()],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfo({required String label, required String value}) {
    return Column(
      spacing: 4.scale,
      children: [
        TextWidget(text: label, fontWeight: FontWeight.bold),
        TextWidget(text: value, fontSize: 12, color: textColor50),
      ],
    );
  }

  Widget switchICon() {
    if (schedule.status == kStatusCheckIn) {
      return Icon(
        color: getScheduleColor(schedule.status ?? ""),
        Icons.check_circle_outline_outlined,
        size: 16.scale,
      );
    }
    return Icon(
      color: getScheduleColor(schedule.status ?? ""),
      Icons.calendar_today_outlined,
      size: 16,
    );
  }

  String lableText(String time) {
    if (time != "" && time.isNotEmpty) {
      return " ${DateTimeExt.parse(time).toTimeString() != "" ? DateTimeExt.parse(time).toTimeString() : ""}";
    }
    // if (schedule.startingTime != "" && schedule.status == kStatusCheckIn) {
    //   return " ${DateTimeExt.parse(schedule.startingTime ?? "").toTimeString() != "" ? DateTimeExt.parse(schedule.startingTime ?? "").toTimeString() : ""}";
    // } else if (schedule.endingTime != "" &&
    //     schedule.status == kStatusCheckOut) {
    //   return " ${DateTimeExt.parse(schedule.endingTime ?? "").toTimeString() != "" ? DateTimeExt.parse(schedule.endingTime ?? "").toTimeString() : ""}";
    // }
    return "-";
  }

  Widget switchButton() {
    if (schedule.status == kStatusCheckIn) {
      return Flexible(
        flex: 2,
        child: Row(
          spacing: 8.scale,
          children: [
            Expanded(
              child: BtnWidget(
                size: BtnSize.medium,
                bgColor: warning,
                onPressed: () => _actionHandler(schedule.status ?? ""),
                title: greeting("Check Out"),
              ),
            ),
            Expanded(
              child: BtnWidget(
                size: BtnSize.medium,
                gradient: linearGradient,
                onPressed: () => onProcess?.call(schedule),
                title: greeting("Process"),
              ),
            ),
          ],
        ),
      );
    }
    return Expanded(
      child: BtnWidget(
        size: BtnSize.medium,
        bgColor: success,
        onPressed: () => _actionHandler(schedule.status ?? ""),
        title: greeting("Check In"),
      ),
    );
  }

  Widget buildLocationWithPhone({
    String? iconSvg,
    String? label,
    bool isCall = false,
    VoidCallback? onTap,
    FontWeight? fontWeight = FontWeight.normal,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: scaleFontSize(10),
        children: [
          if (iconSvg != null)
            SvgWidget(
              width: 20,
              height: 20,
              assetName: iconSvg,
              colorSvg: textColor50,
            ),
          Expanded(
            child: TextWidget(
              text: label ?? "",
              fontSize: 13,
              color: isCall ? primary : textColor50,
              maxLines: 2,
              fontWeight: fontWeight,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
