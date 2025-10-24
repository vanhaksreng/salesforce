import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
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
      margin: EdgeInsets.only(bottom: 12.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [grey20.withValues(alpha: 0.3), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.scale),
          topRight: Radius.circular(20.scale),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: "DOCUMENT NO",
                    fontSize: 10,
                    color: textColor50,
                    fontWeight: FontWeight.w600,
                  ),
                  Helpers.gapH(4.scale),
                  TextWidget(
                    text: report.documentNo ?? "N/A",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.scale,
                  vertical: 6.scale,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      getStatusColor(report.status),
                      getStatusColor(report.status).withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.scale),
                  boxShadow: [
                    BoxShadow(
                      color: getStatusColor(
                        report.status,
                      ).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextWidget(
                  text: (report.status ?? "").toUpperCase(),
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.scale),
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.scale),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: mainColor,
                  size: scaleFontSize(18),
                ),
              ),
              Helpers.gapW(8.scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: report.customerName ?? "N/A",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (report.description?.isNotEmpty ?? false) ...[
            Helpers.gapH(appSpace8),
            TextWidget(
              text: report.description ?? "",
              color: textColor50,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }

  // Modern Divider
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            grey20.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // Metrics Section with Modern Cards
  Widget _buildMetricsSection() {
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: scaleFontSize(appSpace8),
            children: [
              _buildTotalQtyCard(),
              _buildMetricCard(
                title: "Invoiced",
                value: Helpers.rmZeroFormat(report.quantityInvoiced ?? 0),
                remaining:
                    "${Helpers.rmZeroFormat(report.quantityInvoiced ?? 0)}/${Helpers.rmZeroFormat(report.outstandingInvQuantity ?? 0)}",
                color: primary,
                icon: Icons.receipt_long_outlined,
              ),

              _buildMetricCard(
                title: "Shipped",
                value: Helpers.rmZeroFormat(report.shipedQty ?? 0),
                remaining:
                    "${Helpers.rmZeroFormat(report.shipedQty ?? 0)}/${Helpers.rmZeroFormat(report.outStandingQuantity ?? 0)}",
                color: Colors.grey.shade700,
                icon: Icons.local_shipping_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalQtyCard() {
    return BoxWidget(
      rounding: appSpace,
      isBorder: true,
      isBoxShadow: false,
      borderColor: mainColor.withValues(alpha: 0.2),
      gradient: LinearGradient(
        colors: [
          mainColor.withValues(alpha: 0.1),
          mainColor.withValues(alpha: 0.05),
        ],

        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: EdgeInsets.all(scaleFontSize(appSpace + 8)),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            text: "TOTAL QTY",
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
          Helpers.gapH(8.scale),
          TextWidget(
            text: Helpers.rmZeroFormat(report.totalQty ?? 0),
            fontSize: 28,
            color: mainColor,
            fontWeight: FontWeight.bold,
          ),
          Helpers.gapH(4.scale),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.scale,
              vertical: 4.scale,
            ),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(8.scale),
            ),
            child: TextWidget(
              text: report.uom ?? "N/A",
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String remaining,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: BoxWidget(
        isBoxShadow: false,
        color: color.withValues(alpha: 0.05),
        rounding: appSpace,
        isBorder: true,
        borderColor: color.withValues(alpha: 0.2),
        padding: EdgeInsets.all(scaleFontSize(appSpace)),

        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16.scale, color: color),
                    Helpers.gapW(4.scale),
                    TextWidget(
                      text: title,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ],
                ),
                Container(
                  width: 6.scale,
                  height: 6.scale,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Helpers.gapH(8.scale),
            TextWidget(
              text: value,
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            Helpers.gapH(4.scale),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 8.scale,
                vertical: 4.scale,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.scale),
                border: Border.all(
                  color: error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  TextWidget(
                    text: "Remaining",
                    fontSize: 9,
                    color: textColor50,
                    fontWeight: FontWeight.w600,
                  ),
                  TextWidget(
                    text: remaining,
                    fontSize: 13,
                    color: error,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
