import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class ReportCardBoxItemRedemption extends StatelessWidget {
  const ReportCardBoxItemRedemption({super.key});

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      border: const Border(left: BorderSide(color: success, width: 4)),
      padding: const EdgeInsets.all(appSpace),
      margin: const EdgeInsets.only(bottom: appSpace),
      child: Column(
        spacing: appSpace8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ChipWidget(radius: 4, label: "12122112", colorText: textColor50, bgColor: grey20.withValues(alpha: 0.2)),
              ChipWidget(label: "Pending", colorText: success, bgColor: success.withValues(alpha: 0.1)),
            ],
          ),
          const TextWidget(text: "Item Prize Redempption", fontSize: 16, fontWeight: FontWeight.bold),
          const TextWidget(text: "Premium Reward Package", color: textColor50),
          Hr(vertical: 8.scale, color: grey, width: double.infinity),
          Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
            children: [
              TableRow(
                children: [
                  TextWidget(
                    text: "Salesperson".toUpperCase(),
                    textAlign: TextAlign.start,
                    color: textColor50,
                    fontWeight: FontWeight.w600,
                  ),
                  TextWidget(
                    text: " Collected".toUpperCase(),
                    color: textColor50,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                  ),
                  TextWidget(
                    text: "Status".toUpperCase(),
                    color: textColor50,
                    textAlign: TextAlign.end,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const TableRow(
                children: [
                  TextWidget(text: "Jonh Smith", textAlign: TextAlign.start, fontWeight: FontWeight.bold),
                  TextWidget(
                    text: "Empty",
                    color: textColor50,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.bold,
                  ),
                  TextWidget(
                    text: "FOC Give away",
                    color: textColor50,
                    textAlign: TextAlign.end,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
