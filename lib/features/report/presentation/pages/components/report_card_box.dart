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

  double valueProcess() {
    final totalQTY = Helpers.toDouble(report.totalQty);
    final shipQTY = Helpers.toDouble(report.shipQty);
    if (totalQTY == 0) return 0.0;
    return (shipQTY / totalQTY).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      border: Border(left: BorderSide(color: getStatusColor(report.status), width: 4)),
      padding: const EdgeInsets.all(appSpace),
      margin: EdgeInsets.only(bottom: 8.scale),
      child: Column(
        spacing: appSpace8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8.scale,
                children: [
                  if ((report.customerNo ?? "").isNotEmpty)
                    ChipWidget(
                      bgColor: grey20.withAlpha(50),
                      radius: 4,
                      label: report.customerNo ?? "",
                      fontWeight: FontWeight.normal,
                      colorText: textColor50,
                    ),
                  ChipWidget(
                    bgColor: grey20.withAlpha(50),
                    radius: 4,
                    label: report.documentNo ?? "",
                    fontWeight: FontWeight.normal,
                    colorText: textColor50,
                  ),
                ],
              ),
              ChipWidget(
                bgColor: getStatusColor(report.status).withValues(alpha: .2),
                child: TextWidget(
                  text: (report.status ?? "").toUpperCase(),
                  fontSize: 12,
                  color: getStatusColor(report.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          TextWidget(text: report.customerName ?? "", fontSize: 15, fontWeight: FontWeight.bold),
          Row(
            children: [
              Expanded(child: TextWidget(text: report.description ?? "", fontSize: 15)),
              TextWidget(color: mainColor, text: report.uom ?? "", fontSize: 15, fontWeight: FontWeight.w500),
            ],
          ),
          Hr(vertical: 8.scale, width: double.infinity),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfo(labelColor: warning, value: Helpers.rmZeroFormat(report.totalQty ?? 0), label: "TOTAL QTY"),
              _buildInfo(labelColor: primary, value: Helpers.rmZeroFormat(report.shipQty ?? 0), label: "SHIPPED"),
              _buildInfo(
                labelColor: error,
                value: Helpers.rmZeroFormat(report.outStandingQuantity ?? 0),
                label: "REMAINING",
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [mainColor, mainColor50],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds);
              },
              child: LinearProgressIndicator(
                value: valueProcess(),
                backgroundColor: mainColor.withAlpha(50),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _buildInfo({Color? labelColor, String label = "", String value = " 0"}) {
    return Column(
      spacing: 4.scale,
      children: [
        TextWidget(text: value, fontSize: 16, color: labelColor, fontWeight: FontWeight.bold),
        TextWidget(color: textColor50, text: label, fontSize: 12),
      ],
    );
  }
}
