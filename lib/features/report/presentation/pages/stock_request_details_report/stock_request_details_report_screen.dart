import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/row_box_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/report/domain/entities/stock_request_report_model.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class StockRequestArg {
  final StockRequestReportModel report;

  StockRequestArg({required this.report});
}

class StockRequestDetailsReportScreen extends StatefulWidget {
  const StockRequestDetailsReportScreen({super.key, required this.args});

  static const routeName = 'stockRequestDetailsReportScreen';
  final StockRequestArg args;

  @override
  State<StockRequestDetailsReportScreen> createState() => _StockRequestDetailsReportScreenState();
}

class _StockRequestDetailsReportScreenState extends State<StockRequestDetailsReportScreen> {
  @override
  void initState() {
    super.initState();
  }

  String? totalCalculate(StockRequestReportModel report) {
    return report.lines
        ?.fold<double>(0, (sum, e) => sum + (double.tryParse(e.quantity ?? "0") ?? 0))
        .toInt()
        .toString();
  }

  Color _getColor() {
    final report = widget.args.report.header;
    if (report?.status == "Closed") {
      return error;
    } else if (report?.status == "Open") {
      return primary;
    } else if (report?.status == "Rejected") {
      return grey;
    }
    return success;
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.args.report;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(title: greeting("stock_request_details")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(appSpace),
          child: Column(
            children: [
              _buildHeader(report),
              BoxWidget(
                padding: const EdgeInsets.all(appSpace),

                child: Column(
                  spacing: scaleFontSize(appSpace),
                  children: [
                    BoxWidget(
                      rounding: 6,
                      padding: EdgeInsets.all(scaleFontSize(8)),
                      isBoxShadow: false,
                      color: grey20.withValues(alpha: .2),
                      child: Row(
                        spacing: 8.scale,
                        children: const [TextWidget(text: 'Product Lines', fontSize: 16, fontWeight: FontWeight.bold)],
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: report.lines?.length ?? 0,
                      itemBuilder: (context, index) {
                        final line = report.lines![index];
                        return BoxWidget(
                          margin: EdgeInsets.only(bottom: 8.scale),
                          isBoxShadow: false,
                          borderColor: grey.withValues(alpha: .3),
                          padding: EdgeInsets.all(scaleFontSize(8)),
                          isBorder: true,
                          child: Column(
                            children: [
                              Row(
                                spacing: scaleFontSize(appSpace),
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    spacing: 6.scale,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        text: line.description ?? "N/A",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      ChipWidget(
                                        radius: 4,
                                        bgColor: grey20.withValues(alpha: 0.2),
                                        colorText: textColor50,
                                        label: line.itemNo ?? "N/A",
                                      ),
                                    ],
                                  ),
                                  ChipWidget(
                                    bgColor: mainColor50.withValues(alpha: 0.1),
                                    radius: 4,
                                    label: line.unitOfMeasure ?? "N/A",
                                    fontWeight: FontWeight.bold,
                                    colorText: mainColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: appSpace),
                              _buildFooterItem(line),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterItem(StockRequestReportLine line) {
    return Row(
      spacing: scaleFontSize(appSpace),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfo(
          valueColor: primary,
          label: greeting("request_qty"),
          value: line.requestQuantity!.isEmpty ? "0" : line.requestQuantity.toString(),
        ),
        _buildInfo(
          valueColor: success,
          label: greeting("accepted_qty"),
          value: line.quantity!.isEmpty ? "0" : line.quantity.toString(),
        ),
        _buildInfo(
          valueColor: orangeColor,
          label: greeting("shipped_qty"),
          value: line.quantityShipped!.isEmpty ? "0" : line.quantityShipped.toString(),
        ),
        _buildInfo(
          valueColor: success,
          label: greeting("recieved"),
          value: line.quantityReceived!.isEmpty ? "0" : line.quantityShipped.toString(),
        ),
      ],
    );
  }

  Widget _buildHeader(StockRequestReportModel report) {
    return BoxWidget(
      padding: const EdgeInsets.all(appSpace),
      margin: EdgeInsets.only(bottom: 8.scale),
      child: Column(
        spacing: scaleFontSize(appSpace),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: report.header?.title ?? "", fontSize: 18, fontWeight: FontWeight.bold),
              ChipWidget(
                label: report.header?.status ?? "",
                colorText: _getColor(),
                bgColor: _getColor().withValues(alpha: 0.1),
              ),
            ],
          ),
          RowBoxTextWidget(
            value1: DateTimeExt.parse(report.header?.postingDate).toDateNameString(),
            lable1: "Posting Date".toUpperCase(),
            label2: "Document".toUpperCase(),
            value2: DateTimeExt.parse(report.header?.documentDate).toDateNameString(),
          ),
          Hr(vertical: 8.scale, width: double.infinity),
          Row(
            spacing: scaleFontSize(appSpace),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfo(
                valueFontSize: 22,
                labelFontSize: 14,
                height: 70,
                valueColor: mainColor,
                label: greeting("total_items"),
                value: report.lines?.length.toString() ?? "0",
              ),
              _buildInfo(
                height: 70,
                labelFontSize: 14,
                valueFontSize: 22,
                valueColor: mainColor,
                label: greeting("total_quantity"),
                value: (totalCalculate(report)) ?? "0",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo({
    Color? valueColor,
    String label = "",
    String value = " 0",
    double labelFontSize = 10,
    double valueFontSize = 18,
    double? height,
    Color labelColor = textColor50,
    FontWeight valueFontWeight = FontWeight.bold,
    FontWeight labelFontWeight = FontWeight.w600,
    FormatType type = FormatType.quantity,
  }) {
    return Expanded(
      child: BoxWidget(
        isBorder: true,
        height: scaleFontSize(height ?? 65),
        padding: EdgeInsets.all(8.scale),
        borderColor: grey20.withValues(alpha: .2),
        color: grey20.withValues(alpha: .1),
        isBoxShadow: false,
        child: Column(
          spacing: 8.scale,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: Helpers.formatNumber(value, option: type),
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
