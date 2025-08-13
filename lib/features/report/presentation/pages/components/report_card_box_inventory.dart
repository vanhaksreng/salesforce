import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/report/domain/entities/item_inventory_report_model.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ReportCardBoxInventory extends StatelessWidget {
  const ReportCardBoxInventory({super.key, required this.report});

  final ItemInventoryReportModel report;

  Color getColor() {
    final inventory = Helpers.toDouble(report.inventory);

    if (inventory <= 0) {
      return error;
    } else if (inventory <= 10) {
      return warning;
    } else if (inventory <= 50) {
      return primary;
    }
    return success;
  }

  String getStatusSafe() {
    try {
      final inventory = Helpers.toDouble(report.inventory);

      if (inventory <= 0) {
        return greeting("out_of_stock");
      } else if (inventory <= 10) {
        return greeting("Low Stock");
      } else if (inventory <= 50) {
        return greeting("Medium Stock");
      } else {
        return greeting("In Stock");
      }
    } catch (e) {
      return greeting("status_unknown");
    }
  }

  String validateInventory() {
    if (report.inventory == "" || Helpers.toDouble(report.inventory) < 0) {
      return "0";
    }
    return report.inventory ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      border: Border(left: BorderSide(color: getColor(), width: 4)),
      padding: const EdgeInsets.all(appSpace),
      margin: EdgeInsets.only(bottom: 8.scale),
      child: Column(
        spacing: appSpace8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  spacing: 8.scale,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(text: report.description ?? "", fontSize: 16, fontWeight: FontWeight.w600),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(text: report.no ?? "", color: textColor50, fontWeight: FontWeight.w500),
                        TextWidget(
                          text:
                              "${Helpers.formatNumber(validateInventory(), option: FormatType.quantity)} ${report.stockUomCode}",
                          fontSize: 16,
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 8.scale,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ChipWidget(
                bgColor: grey20,
                child: Row(
                  spacing: 8.scale,
                  children: [
                    const SvgWidget(height: 16, assetName: klocationOutlineIcon, colorSvg: textColor),
                    TextWidget(text: report.locationCode ?? ""),
                  ],
                ),
              ),
              ChipWidget(label: getStatusSafe(), colorText: getColor(), bgColor: getColor().withValues(alpha: .2)),
            ],
          ),
        ],
      ),
    );
  }
}
