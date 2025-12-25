import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/report/domain/entities/item_inventory_report_model.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ModernReportCardBoxInventory extends StatelessWidget {
  const ModernReportCardBoxInventory({super.key, required this.report});

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

  IconData getStatusIcon() {
    final inventory = Helpers.toDouble(report.inventory);

    if (inventory <= 0) {
      return Icons.error_outline;
    } else if (inventory <= 10) {
      return Icons.warning_amber_rounded;
    } else if (inventory <= 50) {
      return Icons.info_outline;
    }
    return Icons.check_circle_outline;
  }

  String validateInventory() {
    if (report.inventory == "" || Helpers.toDouble(report.inventory) < 0) {
      return "0";
    }
    return report.inventory ?? "";
  }

  double getStockPercentage() {
    final inventory = Helpers.toDouble(report.inventory);
    if (inventory <= 0) return 0.0;
    if (inventory <= 10) return 0.2;
    if (inventory <= 50) return 0.6;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.scale),
        border: Border.all(color: grey20, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [_buildHeader(), _buildDivider(), _buildFooter()],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxWidget(
            color: getColor(),
            rounding: 4.scale,
            width: 4.scale,
            height: 50.scale,
            child: SizedBox.shrink(),
          ),
          Helpers.gapW(12.scale),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: report.description ?? "N/A",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                Helpers.gapH(4.scale),
                TextWidget(
                  text: report.no ?? "N/A",
                  color: textColor50,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ],
            ),
          ),
          Helpers.gapW(12.scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextWidget(
                text: Helpers.formatNumber(
                  validateInventory(),
                  option: FormatType.quantity,
                ),
                fontSize: 24,
                color: mainColor,
                fontWeight: FontWeight.bold,
              ),
              TextWidget(
                text: report.stockUomCode ?? "",
                fontSize: 11,
                color: textColor50,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      color: grey20,
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      child: Row(
        children: [
          BoxWidget(
            isBoxShadow: false,
            rounding: 8.scale,
            color: grey20.withValues(alpha: 0.5),
            padding: EdgeInsets.symmetric(
              horizontal: 10.scale,
              vertical: 6.scale,
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgWidget(
                  height: 14,
                  width: 14,
                  assetName: klocationOutlineIcon,
                  colorSvg: textColor50,
                ),
                Helpers.gapW(6.scale),
                TextWidget(
                  text: report.locationCode ?? "N/A",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ],
            ),
          ),
          Helpers.gapW(8.scale),
          // Status Badge
          BoxWidget(
            isBoxShadow: false,
            padding: EdgeInsets.symmetric(
              horizontal: 10.scale,
              vertical: 6.scale,
            ),
            isBorder: true,
            borderColor: getColor().withValues(alpha: 0.1),
            color: getColor().withValues(alpha: 0.1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(getStatusIcon(), size: 14.scale, color: getColor()),
                Helpers.gapW(6.scale),
                TextWidget(
                  text: getStatusSafe(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: getColor(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
