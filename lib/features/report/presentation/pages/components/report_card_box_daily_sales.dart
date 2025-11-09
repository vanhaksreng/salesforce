// import 'package:flutter/material.dart';
// import 'package:salesforce/core/constants/app_assets.dart';
// import 'package:salesforce/core/constants/app_styles.dart';
// import 'package:salesforce/core/enums/enums.dart';
// import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
// import 'package:salesforce/core/presentation/widgets/text_widget.dart';
// import 'package:salesforce/core/utils/helpers.dart';
// import 'package:salesforce/core/utils/size_config.dart';
// import 'package:salesforce/features/report/domain/entities/daily_sale_sumary_report_model.dart';
// import 'package:salesforce/localization/trans.dart';
// import 'package:salesforce/theme/app_colors.dart';

// class ModernReportCardBoxDailySales extends StatelessWidget {
//   const ModernReportCardBoxDailySales({super.key, required this.report});

//   final DailySaleSumaryReportModel report;

//   double valueProcess() {
//     final totalSale = Helpers.toDouble(report.salesAmount);
//     final target = Helpers.toDouble(report.target);
//     if (totalSale == 0) return 0.0;
//     return (totalSale / target).clamp(0.0, 1.0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.scale),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24.scale),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: grey20.withOpacity(0.5), width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           _buildSalesMetrics(),
//           _buildProgressSection(),
//           _buildDivider(),
//           _buildSalesDocuments(),
//         ],
//       ),
//     );
//   }

//   // Header with Name and Collection
//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.all(scaleFontSize(appSpace)),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [primary.withOpacity(0.05), Colors.white],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24.scale),
//           topRight: Radius.circular(24.scale),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextWidget(
//                   text: "SALES REPRESENTATIVE",
//                   fontSize: 10,
//                   color: textColor50,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 SizedBox(height: 4.scale),
//                 TextWidget(
//                   text: report.name,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: 12.scale,
//               vertical: 8.scale,
//             ),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [success, success.withOpacity(0.8)],
//               ),
//               borderRadius: BorderRadius.circular(16.scale),
//               boxShadow: [
//                 BoxShadow(
//                   color: success.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 TextWidget(
//                   text: report.collectionAmount,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 SizedBox(height: 2.scale),
//                 TextWidget(
//                   text: greeting("Collection"),
//                   fontSize: 10,
//                   color: Colors.white.withOpacity(0.9),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Sales Metrics (Total Sale & Target)
//   Widget _buildSalesMetrics() {
//     return Padding(
//       padding: EdgeInsets.all(scaleFontSize(appSpace)),
//       child: Row(
//         children: [
//           _buildMetricCard(
//             label: "Total Sale",
//             value: report.salesAmount,
//             color: primary,
//             icon: Icons.trending_up,
//           ),
//           SizedBox(width: 12.scale),
//           _buildMetricCard(
//             label: "Target",
//             value: report.target,
//             color: orangeColor,
//             icon: Icons.flag_outlined,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricCard({
//     required String label,
//     required String value,
//     required Color color,
//     required IconData icon,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(scaleFontSize(appSpace)),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16.scale),
//           border: Border.all(color: color.withOpacity(0.2), width: 1.5),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(6.scale),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8.scale),
//                   ),
//                   child: Icon(icon, size: 16.scale, color: color),
//                 ),
//                 SizedBox(width: 6.scale),
//                 TextWidget(
//                   text: label,
//                   fontWeight: FontWeight.w600,
//                   color: color,
//                   fontSize: 11,
//                 ),
//               ],
//             ),
//             SizedBox(height: 8.scale),
//             TextWidget(
//               text: value,
//               fontSize: 20,
//               color: textColor,
//               fontWeight: FontWeight.bold,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Progress Section
//   Widget _buildProgressSection() {
//     final progress = valueProcess();
//     final percentage = (progress * 100).toInt();

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextWidget(
//                 text: "Target Achievement",
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: textColor50,
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 8.scale,
//                   vertical: 4.scale,
//                 ),
//                 decoration: BoxDecoration(
//                   color: progress >= 1.0
//                       ? success.withOpacity(0.1)
//                       : primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8.scale),
//                 ),
//                 child: TextWidget(
//                   text: "$percentage%",
//                   fontSize: 11,
//                   fontWeight: FontWeight.bold,
//                   color: progress >= 1.0 ? success : primary,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8.scale),
//           Stack(
//             children: [
//               Container(
//                 height: scaleFontSize(10),
//                 decoration: BoxDecoration(
//                   color: grey20,
//                   borderRadius: BorderRadius.circular(scaleFontSize(10)),
//                 ),
//               ),
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 800),
//                 curve: Curves.easeInOut,
//                 height: scaleFontSize(10),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: progress >= 1.0
//                         ? [success, success.withOpacity(0.7)]
//                         : [primary, primary.withOpacity(0.7)],
//                   ),
//                   borderRadius: BorderRadius.circular(scaleFontSize(10)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: (progress >= 1.0 ? success : primary).withOpacity(
//                         0.3,
//                       ),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: FractionallySizedBox(
//                   widthFactor: progress,
//                   alignment: Alignment.centerLeft,
//                   child: Container(),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: scaleFontSize(appSpace)),
//         ],
//       ),
//     );
//   }

//   // Modern Divider
//   Widget _buildDivider() {
//     return Container(
//       height: 1,
//       margin: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.transparent,
//             grey20.withOpacity(0.5),
//             Colors.transparent,
//           ],
//         ),
//       ),
//     );
//   }

//   // Sales Documents Section
//   Widget _buildSalesDocuments() {
//     return Padding(
//       padding: EdgeInsets.all(scaleFontSize(appSpace)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextWidget(
//             text: greeting("Sales Documents"),
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//           SizedBox(height: 12.scale),
//           Row(
//             children: [
//               _buildDocumentCard(
//                 iconName: kReceiptIcon,
//                 title: "Invoice",
//                 qty: report.noOfInvoices,
//                 value: report.invoiceAmount,
//                 color: primary,
//               ),
//               SizedBox(width: 8.scale),
//               _buildDocumentCard(
//                 iconName: kCartIcon,
//                 title: "Order",
//                 qty: report.noOfOrder,
//                 value: report.orderAmount,
//                 color: success,
//               ),
//               SizedBox(width: 8.scale),
//               _buildDocumentCard(
//                 iconName: kCerditIcon,
//                 title: "Credit Memo",
//                 qty: report.noOfCreditMemo,
//                 value: report.creditMemoAmount,
//                 color: orangeColor,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentCard({
//     required String iconName,
//     required String title,
//     required int qty,
//     required String value,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(scaleFontSize(12)),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(16.scale),
//           border: Border.all(color: color.withOpacity(0.2), width: 1),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: EdgeInsets.all(8.scale),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(10.scale),
//               ),
//               child: SvgWidget(
//                 width: 20,
//                 height: 20,
//                 colorSvg: color,
//                 assetName: iconName,
//               ),
//             ),
//             SizedBox(height: 8.scale),
//             TextWidget(
//               text: greeting(title),
//               color: textColor50,
//               fontWeight: FontWeight.w600,
//               fontSize: 11,
//             ),
//             SizedBox(height: 4.scale),
//             TextWidget(
//               text: Helpers.formatNumber(qty, option: FormatType.quantity),
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//             SizedBox(height: 2.scale),
//             TextWidget(
//               text: value,
//               color: textColor50,
//               fontWeight: FontWeight.w500,
//               fontSize: 11,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
