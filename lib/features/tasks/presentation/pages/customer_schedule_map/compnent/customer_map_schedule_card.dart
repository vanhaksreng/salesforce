import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomerMapScheduleCard extends StatelessWidget {
  final SalespersonSchedule schedule;
  final Customer customer;
  const CustomerMapScheduleCard({super.key, required this.schedule, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      color: grey20.withValues(alpha: 0.1),
      isBoxShadow: false,
      isBorder: true,
      borderColor: grey20,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: scaleFontSize(16)),
      padding: EdgeInsets.all(scaleFontSize(16)),
      child: Column(
        spacing: scaleFontSize(appSpace8),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: scaleFontSize(appSpace8),
            children: [
              ImageNetWorkWidget(imageUrl: customer.avatar128 ?? "", round: 30, width: 60, height: 60),
              Expanded(
                child: Column(
                  spacing: 8.scale,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(fontSize: 16, text: schedule.name ?? "", fontWeight: FontWeight.bold),
                    BoxWidget(
                      padding: const EdgeInsets.all(4),
                      isBoxShadow: false,
                      isBorder: false,
                      rounding: 4,
                      borderColor: Colors.transparent,
                      color: grey.withAlpha(70),
                      child: TextWidget(color: textColor50, text: schedule.customerNo ?? ""),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              spacing: scaleFontSize(8),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: scaleFontSize(appSpace8),
                  children: [
                    ChipWidget(
                      borderColor: primary.withValues(alpha: 0.2),
                      bgColor: warning.withValues(alpha: 0.2),
                      colorText: primary,
                      child: Row(
                        spacing: 6.scale,
                        children: [
                          const SvgWidget(assetName: kAccountOutlineIcon, colorSvg: orangeColor, width: 14, height: 14),
                          TextWidget(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: orangeColor,
                            text: schedule.planned == "Yes" ? "Plan" : "Manual",
                          ),
                        ],
                      ),
                    ),
                    ChipWidget(
                      borderColor: primary.withValues(alpha: 0.2),
                      bgColor: schedule.status == kStatusCheckIn
                          ? success.withValues(alpha: 0.2)
                          : primary.withValues(alpha: 0.2),
                      colorText: primary,
                      child: Row(
                        spacing: 6.scale,
                        children: [
                          _switchICon(schedule),
                          TextWidget(
                            text: _lableText(schedule),
                            fontSize: 12,
                            color: schedule.status == kStatusCheckIn ? success : primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: scaleFontSize(appSpace8),
                    children: [
                      const SvgWidget(assetName: klocationOutlineIcon, width: 20, height: 20, colorSvg: textColor50),
                      Expanded(
                        child: TextWidget(
                          text: schedule.address ?? "",
                          softWrap: true,
                          color: textColor50,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchICon(SalespersonSchedule schedule) {
    if (schedule.status == kStatusCheckIn) {
      return const Icon(color: success, Icons.check_circle_outline_outlined, size: 16);
    }
    return const Icon(color: primary, Icons.calendar_today_outlined, size: 16);
  }

  String _lableText(SalespersonSchedule schedule) {
    if (schedule.startingTime != "") {
      return "${schedule.status ?? ""}  |  ${schedule.startingTime ?? ""}";
    }
    return schedule.status ?? "";
  }
}
