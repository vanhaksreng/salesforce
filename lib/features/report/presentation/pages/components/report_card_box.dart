import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/color_status_history.dart';
import 'package:salesforce/features/report/domain/entities/so_outstanding_report_model.dart';
import 'package:salesforce/theme/app_colors.dart';

class ModernReportCardBox extends StatelessWidget {
  const ModernReportCardBox({super.key, required this.report});

  final SoOutstandingReportModel report;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.scale),
        border: Border.all(color: grey20.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildCustomerInfo(),
          _buildDivider(),
          _buildMetricsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scaleFontSize(12),
        vertical: scaleFontSize(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: "Document No",
                  fontSize: 10,
                  color: textColor50,
                  fontWeight: FontWeight.w500,
                ),
                Helpers.gapH(3.scale),
                TextWidget(
                  text: report.documentNo ?? "N/A",
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Helpers.gapW(8.scale),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.scale,
              vertical: 4.scale,
            ),
            decoration: BoxDecoration(
              color: getStatusColor(report.status),
              borderRadius: BorderRadius.circular(5.scale),
            ),
            child: TextWidget(
              text: (report.status ?? "").toUpperCase(),
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.person_outline,
                color: textColor50,
                size: scaleFontSize(15),
              ),
              Helpers.gapW(6.scale),
              Expanded(
                child: TextWidget(
                  text: report.customerName ?? "N/A",
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (report.description?.isNotEmpty ?? false) ...[
            Helpers.gapH(6.scale),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextWidget(
                    text: report.description ?? "",
                    color: textColor50,
                    fontSize: 12,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Helpers.gapW(6.scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleFontSize(5),
                    vertical: 2.scale,
                  ),
                  decoration: BoxDecoration(
                    color: grey20,
                    borderRadius: BorderRadius.circular(3.scale),
                  ),
                  child: TextWidget(
                    text: report.uom ?? "N/A",
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(
        horizontal: scaleFontSize(12),
        vertical: scaleFontSize(8),
      ),
      color: grey20.withValues(alpha: 0.5),
    );
  }

  Widget _buildMetricsSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        scaleFontSize(12),
        0,
        scaleFontSize(12),
        scaleFontSize(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalQtyCard(),
          Helpers.gapH(6.scale),
          _buildCompactMetricCard(
            title: "Invoiced",
            value: Helpers.rmZeroFormat(report.quantityInvoiced ?? 0),
            used: Helpers.rmZeroFormat(report.quantityInvoiced ?? 0),
            remaining: Helpers.rmZeroFormat(report.outstandingInvQuantity ?? 0),
            icon: Icons.receipt_long_outlined,
          ),
          Helpers.gapH(6.scale),
          _buildCompactMetricCard(
            title: "Shipped",
            value: Helpers.rmZeroFormat(report.shipedQty ?? 0),
            used: Helpers.rmZeroFormat(report.shipedQty ?? 0),
            remaining: Helpers.rmZeroFormat(report.outStandingQuantity ?? 0),
            icon: Icons.local_shipping_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalQtyCard() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scaleFontSize(10),
        vertical: scaleFontSize(8),
      ),
      decoration: BoxDecoration(
        color: grey20.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6.scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            text: "Total Qty",
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: TextWidget(
                text: Helpers.rmZeroFormat(report.totalQty ?? 0),
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetricCard({
    required String title,
    required String value,
    required String used,
    required String remaining,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(scaleFontSize(10)),
      decoration: BoxDecoration(
        color: grey20.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.scale),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 13.scale, color: textColor50),
                    Helpers.gapW(5.scale),
                    TextWidget(
                      text: title,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ],
                ),
                Helpers.gapH(4.scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: TextWidget(
                    text: value,
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Helpers.gapW(10.scale),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: scaleFontSize(8),
                vertical: scaleFontSize(6),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.scale),
                border: Border.all(
                  color: grey20.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWidget(
                    text: "Remaining",
                    fontSize: 9,
                    color: textColor50,
                    fontWeight: FontWeight.w500,
                  ),
                  Helpers.gapH(2.scale),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: TextWidget(
                      text: "$used / $remaining",
                      fontSize: 11,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
