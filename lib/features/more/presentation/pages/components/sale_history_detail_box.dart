import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/row_box_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/circle_icon_widget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/color_status_history.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleHistoryDetailBox extends StatelessWidget {
  const SaleHistoryDetailBox({
    super.key,
    this.header,
    required this.lines,
    this.lineAmount,
  });

  final SalesHeader? header;
  final List<SalesLine> lines;
  final String? lineAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.scale,
      children: [
        _buildHeaderBoxV2(),
        _buildCustomerInfo(),
        // _buildHeaderBox(),
        _buildListItem(),
      ],
    );
  }

  Widget _buildHeaderBoxV2() {
    return BoxWidget(
      padding: EdgeInsets.all(16.scale),
      child: Column(
        spacing: 16.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 4.scale,
                    children: [
                      CircleIconWidget(
                        bgColor: header?.isSync == kStatusYes ? success : error,
                        sizeIcon: scaleFontSize(10),
                        colorIcon: white,
                        icon: header?.isSync == kStatusYes
                            ? Icons.cloud_done
                            : Icons.cloud_off_outlined,
                      ),
                      TextWidget(
                        text: greeting("Local Document No").toUpperCase(),
                        fontSize: 12,
                      ),
                    ],
                  ),
                  TextWidget(
                    fontWeight: FontWeight.bold,
                    text: header?.appId ?? "",
                    fontSize: 16,
                  ),
                ],
              ),
              ChipWidget(
                ishadowColor: false,
                fontSize: 12,
                vertical: 8.scale,
                label: header?.status?.toUpperCase() ?? "",
                colorText: getStatusColor(header?.status),
                bgColor: getStatusColor(header?.status).withValues(alpha: 0.1),
              ),
            ],
          ),
          Hr(width: double.infinity),
          RowBoxTextWidget(
            lable1: greeting("Document No"),
            value1: header?.isSync == "Yes" ? "${header?.no}" : "-",
            label2: greeting("Posting Date"),
            value2: DateTimeExt.parse(
              "${header?.postingDate}",
            ).toDateNameString(),
          ),
          RowBoxTextWidget(
            lable1: greeting("document_date"),
            value1: DateTimeExt.parse(
              "${header?.documentDate}",
            ).toDateNameString(),
            label2: greeting("Req. Shipment Date"),
            value2: DateTimeExt.parse(
              "${header?.requestShipmentDate}",
            ).toDateNameString(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return BoxWidget(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: scale(6),
        children: [
          CircleAvatar(
            backgroundColor: mainColor50,
            child: Icon(Icons.person, color: white, size: 25),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: scaleFontSize(8),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: "Customer Infomation".toUpperCase(),
                      fontSize: 12,
                    ),
                    TextWidget(
                      text: "${header?.customerName}",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                RowBoxTextWidget(
                  lable1: greeting("Customer No"),
                  value1: "${header?.customerNo}",
                  label2: greeting("Phone No"),
                  value2: "${header?.shipToPhoneNo}",
                ),
                Helpers.gapH(8),
                if ((header?.shipToAddress ?? "").isNotEmpty)
                  RowBoxTextWidget(
                    lable1: greeting("Ship To Address"),
                    value1:
                        "${header?.shipToAddress} \n${header?.shipToAddress2}",
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildHeaderBox() {
  //   return BoxWidget(
  //     padding: EdgeInsets.all(16.scale),
  //     child: Column(
  //       spacing: 16.scale,
  //       children: [
  //         Column(
  //           spacing: 4.scale,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 TextWidget(
  //                   fontWeight: FontWeight.bold,
  //                   text: header?.no ?? "",
  //                   fontSize: 18,
  //                 ),
  //                 ChipWidget(
  //                   ishadowColor: false,
  //                   fontSize: 12,
  //                   vertical: 8.scale,
  //                   label: header?.status?.toUpperCase() ?? "",
  //                   colorText: getStatusColor(header?.status),
  //                   bgColor: getStatusColor(
  //                     header?.status,
  //                   ).withValues(alpha: .2),
  //                 ),
  //               ],
  //             ),

  //             RowBoxTextWidget(
  //               lable1: greeting("Customer No").toUpperCase(),
  //               value1: header?.customerNo ?? "",
  //               label2: greeting("Posting Date").toUpperCase(),
  //               value2: DateTimeExt.parse(
  //                 header?.postingDate ?? "",
  //               ).toDateNameString(),
  //             ),
  //           ],
  //         ),
  //         RowBoxTextWidget(
  //           lable1: greeting("customer").toUpperCase(),
  //           value1: header?.customerName ?? "",
  //           label2: greeting("Ship to name").toUpperCase(),
  //           value2: header?.shipToName ?? "",
  //         ),
  //         RowBoxTextWidget(
  //           lable1: greeting("document_date").toUpperCase(),
  //           value1: DateTimeExt.parse(
  //             header?.documentDate ?? "",
  //           ).toDateNameString(),
  //           label2: greeting("ship_date").toUpperCase(),
  //           value2: header?.requestShipmentDate ?? "",
  //         ),
  //         if ((header?.shipToAddress ?? "").isNotEmpty)
  //           RowBoxTextWidget(
  //             lable1: greeting("ship to address").toUpperCase(),
  //             value1: header?.shipToAddress ?? "",
  //           ),
  //         if ((header?.shipToAddress2 ?? "").isNotEmpty)
  //           RowBoxTextWidget(
  //             lable1: greeting("ship to address").toUpperCase(),
  //             value1: header?.shipToAddress2 ?? "",
  //           ),
  //         BoxWidget(
  //           color: grey20,
  //           isBoxShadow: false,
  //           padding: const EdgeInsets.all(appSpace),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               TextWidget(
  //                 text: greeting("total_amount"),
  //                 fontSize: 16,
  //                 color: textColor50,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //               TextWidget(
  //                 text:
  //                     lineAmount ??
  //                     Helpers.formatNumber(
  //                       header?.amount,
  //                       option: FormatType.amount,
  //                     ),
  //                 fontSize: 20,
  //                 color: mainColor,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
            color: Colors.grey.withValues(alpha: 0.2),
            rounding: 6.scale,
            child: Row(
              spacing: 8.scale,
              children: [
                TextWidget(
                  text: "${greeting("Items")} (${lines.length})",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                Spacer(),
                TextWidget(
                  text:
                      lineAmount ??
                      Helpers.formatNumber(
                        header?.amount,
                        option: FormatType.amount,
                      ),
                  fontSize: 20,
                  color: mainColor,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                color: textColor50,
                                text: greeting("Unit Price"),
                              ),
                              TextWidget(
                                fontWeight: FontWeight.bold,
                                color: textColor50,
                                text:
                                    "${Helpers.formatNumber(record.unitPrice, option: FormatType.amount)} / ${record.unitOfMeasure ?? ""}",
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ChipWidget(
                                bgColor: mainColor,
                                radius: 6,
                                label:"${Helpers.formatNumber(record.quantity, option: FormatType.quantity)} ${record.unitOfMeasure ?? ""}",
                              ),
                              TextWidget(
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                                fontSize: 16,
                                text: Helpers.formatNumber(
                                  record.amount,
                                  option: FormatType.amount,
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
