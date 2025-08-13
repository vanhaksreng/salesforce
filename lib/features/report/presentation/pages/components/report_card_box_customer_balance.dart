import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/dot_line_widget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/text_row_shape.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/report/domain/entities/customer_balance_report.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ReportCardBoxCustomerBalance extends StatelessWidget {
  const ReportCardBoxCustomerBalance({super.key, required this.report});
  final CustomerBalanceReport report;

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      border: Border(
        left: BorderSide(color: mainColor.withValues(alpha: .5), width: 4.scale),
      ),
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      margin: EdgeInsets.only(bottom: 8.scale),
      child: Column(
        spacing: appSpace8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: report.name ?? "", fontWeight: FontWeight.bold, fontSize: 20),
          TextWidget(text: report.no ?? ""),
          Hr(width: double.infinity, vertical: scaleFontSize(8)),
          Row(
            spacing: 8.scale,
            children: [
              _buildInfo(
                label: greeting("invoice"),
                value: report.noOfInvoices ?? "",
                valueColor: textColor,
                value1Color: textColor,
                value1: report.salesAmount ?? "",
              ),
              _buildInfo(
                label: greeting("credit_memo"),
                value: report.noOfCreditMemo ?? "",
                valueColor: textColor,
                value1: report.salesCreditMemoAmount ?? "",
                value1Color: textColor,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: scaleFontSize(8)),
            child: const DotLine(),
          ),
          TextShapeRow(
            label: greeting("Collection "),
            valueColor: error,
            labelColor: textColor,
            valueFontWeight: FontWeight.w600,
            valueFontSize: 16,
            value: Helpers.formatNumberLink(report.collection, option: FormatType.amount),
          ),
          TextShapeRow(
            label: greeting("Balance"),
            valueColor: success,
            labelColor: textColor,
            labelFontWeight: FontWeight.bold,
            value: Helpers.formatNumberLink(report.balance, option: FormatType.amount),
          ),
        ],
      ),
    );
  }

  _buildInfo({
    Color? value1Color = textColor50,
    Color? valueColor = primary,
    String label = "",
    String value = " 0",
    String value1 = "0",
    FormatType type = FormatType.quantity,
  }) {
    return Expanded(
      child: BoxWidget(
        isBorder: false,
        padding: EdgeInsets.all(15.scale),
        borderColor: primary.withValues(alpha: .2),
        color: primary.withValues(alpha: .1),
        isBoxShadow: false,
        child: Column(
          spacing: 8.scale,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(fontWeight: FontWeight.w600, color: textColor50, text: label.toUpperCase()),
            TextWidget(
              text: Helpers.formatNumber(value, option: type),
              fontSize: 20,
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
            TextWidget(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              text: Helpers.formatNumberLink(value1, option: FormatType.amount),
              color: value1Color,
            ),
          ],
        ),
      ),
    );
  }
}
