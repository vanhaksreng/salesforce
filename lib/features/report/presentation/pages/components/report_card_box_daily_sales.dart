import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/report/domain/entities/daily_sale_sumary_report_model.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ReportCardBoxDailySales extends StatelessWidget {
  const ReportCardBoxDailySales({super.key, required this.report});

  final DailySaleSumaryReportModel report;

  double valueProcess() {
    final totalSale = Helpers.toDouble(report.salesAmount);
    final target = Helpers.toDouble(report.target);
    if (totalSale == 0) return 0.0;
    return (totalSale / target).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      margin: EdgeInsets.only(bottom: 8.scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextWidget(
                  text: report.name,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                spacing: 8.scale,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: report.collectionAmount,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: success,
                  ),
                  TextWidget(
                    text: greeting("Collection"),
                    fontSize: 12,
                    color: textColor,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _boxBody(label: "Total Sale", value: report.salesAmount),
              _boxBody(label: "Target", value: report.target),
            ],
          ),
          Helpers.gapH(8),
          LinearProgressIndicator(
            value: valueProcess(),
            valueColor: const AlwaysStoppedAnimation<Color>(primary),
            backgroundColor: grey20,
            minHeight: scaleFontSize(8),
            borderRadius: BorderRadius.circular(scaleFontSize(8)),
          ),
          Hr(
            width: double.infinity,
            vertical: scaleFontSize(appSpace),
            height: 0.3,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: scaleFontSize(8),
            children: [
              TextWidget(
                text: greeting("Sales Documents"),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBoxInfo(
                    iconName: kReceiptIcon,
                    title: "Invoice",
                    qty: report.noOfInvoices,
                    value: report.invoiceAmount,
                  ),
                  _buildBoxInfo(
                    iconName: kCartIcon,
                    title: "Order",
                    colorIcon: success,
                    qty: report.noOfOrder,
                    value: report.orderAmount,
                  ),
                  _buildBoxInfo(
                    iconName: kCerditIcon,
                    colorIcon: orangeColor,
                    title: "Credit Memo",
                    qty: report.noOfCreditMemo,
                    value: report.creditMemoAmount,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoxInfo({
    required String iconName,
    required String title,
    required int qty,
    required String value,
    Color colorIcon = primary,
  }) {
    return Expanded(
      child: Column(
        spacing: scaleFontSize(8),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8.scale,
            children: [
              SvgWidget(
                width: 18,
                height: 18,
                colorSvg: colorIcon,
                assetName: iconName,
              ),
              TextWidget(
                text: greeting(title),
                color: textColor50,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          TextWidget(
            text: Helpers.formatNumber(qty, option: FormatType.quantity),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          TextWidget(
            text: value,
            color: textColor50,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _boxBody({required String label, required String value}) {
    return Expanded(
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            fontWeight: FontWeight.w600,
            color: textColor50,
            text: label,
          ),
          TextWidget(
            text: value,
            fontSize: 20,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
