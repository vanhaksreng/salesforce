import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/report/domain/entities/stock_request_report_model.dart';
import 'package:salesforce/features/report/presentation/pages/stock_request_details_report/stock_request_details_report_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ReportCardBoxStockRequest extends StatelessWidget {
  const ReportCardBoxStockRequest({super.key, required this.report});

  final StockRequestReportModel report;

  Color getColor() {
    if (report.header?.status == "Closed") {
      return error;
    } else if (report.header?.status == "Open") {
      return primary;
    } else if (report.header?.status == "Rejected") {
      return grey;
    }
    return success;
  }

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      padding: const EdgeInsets.all(appSpace),
      margin: EdgeInsets.only(bottom: 8.scale),
      child: Column(
        spacing: scaleFontSize(appSpace),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(text: report.header?.title ?? "", fontSize: 18, fontWeight: FontWeight.bold),
              ChipWidget(
                colorText: getColor(),
                bgColor: getColor().withValues(alpha: .1),
                label: report.header?.status ?? "Unknow",
              ),
            ],
          ),
          Row(
            spacing: 16.scale,
            children: [
              _buildInfo(
                value: greeting("posting_date").toUpperCase(),
                label: report.header?.postingDate ?? "",
                valueFontSize: 12,
                labelFontSize: 14,
                height: 80,
                labelFontWeight: FontWeight.bold,
                valueFontWeight: FontWeight.w600,
                labelColor: primary,
                valueColor: textColor50,
              ),
              _buildInfo(
                value: greeting("document_date").toUpperCase(),
                valueFontSize: 12,
                labelFontSize: 14,
                height: 80,
                labelFontWeight: FontWeight.bold,
                valueFontWeight: FontWeight.w600,
                valueColor: textColor50,
                labelColor: success,
                label: report.header?.documentDate ?? "",
              ),
            ],
          ),
          Row(
            spacing: 5.scale,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfo(
                valueColor: primary,
                label: greeting("request_qty"),
                value: Helpers.rmZeroFormat(
                  report.lines!.fold<double>(
                    0,
                    (sum, line) => sum + (double.tryParse(line.requestQuantity ?? "0") ?? 0),
                  ),
                ),
              ),
              _buildInfo(
                valueColor: success,
                label: greeting("accepted_qty"),
                value: Helpers.rmZeroFormat(
                  report.lines!.fold<double>(0, (sum, line) => sum + (double.tryParse(line.quantity ?? "0") ?? 0)),
                ),
              ),
              _buildInfo(
                valueColor: orangeColor,
                label: greeting("shipped_qty"),
                value: Helpers.rmZeroFormat(
                  report.lines!.fold<double>(
                    0,
                    (sum, line) => sum + (double.tryParse(line.quantityShipped ?? "0") ?? 0),
                  ),
                ),
              ),
              _buildInfo(
                valueColor: success,
                label: greeting("recieved"),
                value: Helpers.rmZeroFormat(
                  report.lines!.fold<double>(
                    0,
                    (sum, line) => sum + (double.tryParse(line.quantityShipped ?? "0") ?? 0),
                  ),
                ),
              ),
            ],
          ),
          BtnWidget(
            onPressed: () {
              _navigateToDetails(report, context);
            },
            variant: BtnVariant.outline,
            title: greeting("view_detail"),
            size: BtnSize.medium,
            textColor: getColor(),
            borderColor: getColor(),
            suffixIcon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  _navigateToDetails(StockRequestReportModel report, BuildContext context) {
    Navigator.pushNamed(context, StockRequestDetailsReportScreen.routeName, arguments: StockRequestArg(report: report));
  }

  _buildInfo({
    Color? valueColor,
    String label = "",
    String value = " 0",
    double labelFontSize = 11,
    double valueFontSize = 20,
    double? height,
    Color labelColor = textColor50,
    FontWeight valueFontWeight = FontWeight.bold,
    FontWeight labelFontWeight = FontWeight.w600,
    FormatType? type,
  }) {
    return Expanded(
      child: BoxWidget(
        isBorder: true,
        height: scaleFontSize(height ?? 90),
        padding: EdgeInsets.all(8.scale),
        borderColor: grey20.withValues(alpha: .2),
        color: grey20.withValues(alpha: .1),
        isBoxShadow: false,
        child: Column(
          spacing: 8.scale,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: type == FormatType.quantity ? Helpers.formatNumber(value, option: type!) : value,
              fontSize: valueFontSize,
              color: valueColor,
              fontWeight: valueFontWeight,
            ),
            TextWidget(
              color: labelColor,
              fontWeight: labelFontWeight,
              text: label.toUpperCase(),
              fontSize: labelFontSize,
            ),
          ],
        ),
      ),
    );
  }
}
