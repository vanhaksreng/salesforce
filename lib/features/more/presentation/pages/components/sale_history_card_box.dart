import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/circle_icon_widget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/features/more/presentation/pages/components/color_status_history.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleHistoryCardBox extends StatelessWidget {
  final SalesHeader header;
  final VoidCallback? onTap;
  final VoidCallback? onTapShare;

  const SaleHistoryCardBox({
    super.key,
    required this.header,
    this.onTap,
    this.onTapShare,
  });

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      margin: EdgeInsets.symmetric(vertical: 4.scale),
      border: Border(
        left: BorderSide(color: getStatusColor(header.status), width: 4.scale),
      ),
      onPress: onTap,
      width: double.infinity,
      padding: EdgeInsets.all(8),
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        bgColor: header.isSync == kStatusYes ? success : error,
                        sizeIcon: scaleFontSize(10),
                        colorIcon: white,
                        icon: header.isSync == kStatusYes
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
                    text: header.appId ?? "",
                    fontSize: 16,
                  ),
                ],
              ),
              ChipWidget(
                ishadowColor: false,
                fontSize: 12,
                vertical: 8.scale,
                label: header.status?.toUpperCase() ?? "",
                colorText: getStatusColor(header.status),
                bgColor: getStatusColor(header.status).withValues(alpha: 0.1),
              ),
            ],
          ),
          Hr(width: double.infinity),

          TextWidget(
            text: "${header.customerName ?? ""} ",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardBox(greeting("Customer No"), header.customerNo ?? ""),
              _cardBox(greeting("Document No"), header.no ?? ""),
            ],
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6.scale,
              vertical: 8.scale,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.scale),
              color: getStatusColor(header.status).withValues(alpha: 0.1),
            ),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: greeting('Total Amount'),
                  fontSize: 15,
                  color: getStatusColor(header.status),
                ),
                TextWidget(
                  fontSize: 16,
                  color: getStatusColor(header.status),
                  text: Helpers.formatNumber(
                    header.totalAmtLine ?? 0.0,
                    option: FormatType.amount,
                  ),
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          if ((header.shipToAddress ?? "").isNotEmpty)
            Row(
              children: [
                Icon(Icons.location_pin, size: 18),
                TextWidget(text: "${header.shipToAddress}", fontSize: 15),
              ],
            ),
          const Hr(width: double.infinity),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 6.scale,
                children: [
                  Icon(Icons.date_range, size: 16.scale, color: textColor50),
                  TextWidget(
                    text: DateTimeExt.parse(
                      header.postingDate,
                    ).toDateNameString(),
                    color: textColor50,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              InkWell(
                onTap: onTapShare,
                child: Row(
                  spacing: 4.scale,
                  children: [
                    Icon(Icons.share, color: mainColor, size: 14.scale),
                    TextWidget(
                      fontWeight: FontWeight.w400,
                      text: greeting("Share"),
                      color: mainColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBox(String label, String value) {
    return Container(
      padding: EdgeInsets.all(6.scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.scale),
        color: Colors.grey.withValues(alpha: 0.1),
      ),
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: label, fontSize: 14, color: Colors.grey),
          TextWidget(text: value, fontSize: 14, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
