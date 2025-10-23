import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/color_status_history.dart';
import 'package:salesforce/features/report/domain/entities/so_outstanding_report_model.dart';
import 'package:salesforce/theme/app_colors.dart';

class ReportCardBox extends StatelessWidget {
  const ReportCardBox({super.key, required this.report});
  final SoOutstandingReportModel report;

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
            color: secondary.withValues(alpha: 0.1),
            isBoxShadow: false,
            isRounding: false,
            padding: const EdgeInsets.all(appSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 8.scale,
                      children: [
                        if ((report.customerNo ?? "").isNotEmpty)
                          TextWidget(text: report.customerNo ?? ""),
                        TextWidget(text: report.documentNo ?? ""),
                      ],
                    ),
                    ChipWidget(
                      bgColor: getStatusColor(
                        report.status,
                      ).withValues(alpha: .2),
                      child: TextWidget(
                        text: (report.status ?? "").toUpperCase(),
                        fontSize: 12,
                        color: getStatusColor(report.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextWidget(
                  text: report.customerName ?? "",
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        text: report.description ?? "",
                        fontSize: 15,
                      ),
                    ),
                    TextWidget(
                      color: mainColor,
                      text: report.uom ?? "",
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(appSpace),
            child: Column(
              spacing: scaleFontSize(appSpace),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfo(
                      labelColor: mainColor,
                      value: Helpers.rmZeroFormat(report.totalQty ?? 0),
                      label: "TOTAL QTY",
                    ),
                    Helpers.gapW(appSpace * 2),
                    Flexible(
                      flex: 2,
                      child: Column(
                        spacing: scaleFontSize(appSpace8),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfo(
                                labelColor: primary,
                                value: Helpers.rmZeroFormat(
                                  report.quantityInvoice ?? 0,
                                ),
                                label: "Invoiced",
                              ),

                              _buildInfo(
                                labelColor: error,
                                value: Helpers.rmZeroFormat(
                                  report.outstandingInvQuantity ?? 0,
                                ),
                                label: "Remaining",
                              ),
                            ],
                          ),
                          Hr(width: double.infinity, color: grey20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfo(
                                labelColor: primary,
                                value: Helpers.rmZeroFormat(
                                  report.shipQty ?? 0,
                                ),
                                label: "Shipped",
                              ),

                              _buildInfo(
                                labelColor: error,
                                value: Helpers.rmZeroFormat(
                                  report.outStandingQuantity ?? 0,
                                ),
                                label: "Remaining",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo({
    Color? labelColor,
    String label = "",
    String value = " 0",
  }) {
    return Row(
      spacing: 4.scale,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextWidget(
          text: value,
          fontSize: 16,
          color: labelColor,
          fontWeight: FontWeight.bold,
        ),
        Align(
          alignment: AlignmentGeometry.bottomRight,
          child: TextWidget(color: textColor50, text: label, fontSize: 12),
        ),
      ],
    );
  }
}
