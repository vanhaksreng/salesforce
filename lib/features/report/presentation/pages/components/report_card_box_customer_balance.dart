import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
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
        top: BorderSide(color: mainColor.withValues(alpha: .5), width: 2.scale),
      ),

      margin: EdgeInsets.only(bottom: 8.scale),
      child: Column(
        spacing: appSpace8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxWidget(
            isBoxShadow: false,
            isRounding: false,
            color: secondary.withValues(alpha: 0.1),
            padding: EdgeInsets.all(scaleFontSize(appSpace)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      spacing: scaleFontSize(appSpace8),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: report.name ?? "",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        TextWidget(text: report.no ?? ""),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextWidget(
                          text: Helpers.formatNumberLink(
                            report.balance,
                            option: FormatType.amount,
                          ),
                          color: success,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        TextWidget(text: greeting("Balance")),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(scaleFontSize(appSpace)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                _buildInfo(
                  label: greeting("Collection"),
                  value: Helpers.formatNumberLink(
                    report.collection,
                    option: FormatType.amount,
                  ),
                  valueColor: error,
                ),
              ],
            ),
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
      child: Column(
        spacing: 8.scale,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            fontWeight: FontWeight.w500,
            color: textColor50,
            fontSize: 12,
            text: label.toUpperCase(),
          ),
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
    );
  }
}
