import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/row_box_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/color_status_history.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleHistoryDetailBox extends StatelessWidget {
  const SaleHistoryDetailBox({super.key, this.header, required this.lines});
  final PosSalesHeader? header;
  final List<PosSalesLine> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.scale,
      children: [_buildHeaderBox(), _buildListItem()],
    );
  }

  Widget _buildHeaderBox() {
    return BoxWidget(
      padding: EdgeInsets.all(16.scale),
      child: Column(
        spacing: 16.scale,
        children: [
          Column(
            spacing: 4.scale,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    fontWeight: FontWeight.bold,
                    text: header?.no ?? "",
                    fontSize: 18,
                  ),
                  ChipWidget(
                    ishadowColor: false,
                    fontSize: 12,
                    vertical: 8.scale,
                    label: header?.status?.toUpperCase() ?? "",
                    colorText: getStatusColor(header?.status),
                    bgColor: getStatusColor(
                      header?.status,
                    ).withValues(alpha: .2),
                  ),
                ],
              ),
              TextWidget(
                fontWeight: FontWeight.w500,
                color: textColor50,
                text: header?.documentDate ?? "",
              ),
            ],
          ),
          RowBoxTextWidget(
            lable1: greeting("customer").toUpperCase(),
            value1: header?.customerName ?? "",
            label2: greeting("Ship to name").toUpperCase(),
            value2: header?.shipToName ?? "",
          ),
          RowBoxTextWidget(
            lable1: greeting("document_date").toUpperCase(),
            value1: header?.documentDate ?? "",
            label2: greeting("ship_date").toUpperCase(),
            value2: header?.requestShipmentDate ?? "",
          ),
          if ((header?.shipToAddress ?? "").isNotEmpty)
            RowBoxTextWidget(
              lable1: greeting("ship to address").toUpperCase(),
              value1: header?.shipToAddress ?? "",
            ),
          if ((header?.shipToAddress2 ?? "").isNotEmpty)
            RowBoxTextWidget(
              lable1: greeting("ship to address").toUpperCase(),
              value1: header?.shipToAddress2 ?? "",
            ),
          BoxWidget(
            color: grey20,
            isBoxShadow: false,
            padding: const EdgeInsets.all(appSpace),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: greeting("total_amount"),
                  fontSize: 16,
                  color: textColor50,
                  fontWeight: FontWeight.bold,
                ),
                TextWidget(
                  text: header?.amount != null
                      ? Helpers.formatNumber(
                          header?.amount,
                          option: FormatType.amount,
                        )
                      : "0.00",
                  fontSize: 20,
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem() {
    return BoxWidget(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxWidget(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(8.scale),
            isBoxShadow: false,
            color: grey20,
            child: Row(
              spacing: 8.scale,
              children: [
                const ChipWidget(
                  bgColor: mainColor50,
                  radius: 8,
                  vertical: 6,
                  horizontal: 0,
                  child: SvgWidget(
                    assetName: kAddCart,
                    colorSvg: white,
                    width: 15,
                    height: 15,
                  ),
                ),
                TextWidget(
                  text: "${greeting("order_items")} (${lines?.length})",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lines.length,
            padding: const EdgeInsets.only(top: appSpace),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final record = lines[index];
              return Padding(
                padding: EdgeInsets.all(scaleFontSize(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        spacing: 8.scale,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImageBoxCoverWidget(
                            key: ValueKey(record.id),
                            image: ImageNetWorkWidget(
                              key: ValueKey(record.id),
                              imageUrl: record.imgUrl ?? "",
                              width: scaleFontSize(70),
                              height: scaleFontSize(70),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              spacing: 6.scale,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget(
                                  fontSize: 16,
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold,
                                  text: record.description.toString(),
                                ),
                                TextWidget(
                                  fontWeight: FontWeight.w500,
                                  color: textColor50,
                                  text:
                                      "${Helpers.formatNumber(record.unitPrice, option: FormatType.amount)}/${record.unitOfMeasure ?? ""}",
                                ),
                                ChipWidget(
                                  bgColor: mainColor,
                                  label:
                                      "${Helpers.formatNumber(record.quantity, option: FormatType.quantity)} ${record.unitOfMeasure ?? ""}",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextWidget(
                      fontSize: 16,
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      text: Helpers.formatNumber(
                        record.amount,
                        option: FormatType.amount,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Hr(width: double.infinity);
            },
          ),
        ],
      ),
    );
  }
}
