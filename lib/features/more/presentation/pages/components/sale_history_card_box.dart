import 'package:flutter/material.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
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
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.scale, 8.scale, 16.scale, 8.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: header.no ?? "",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    ChipWidget(
                      ishadowColor: false,
                      fontSize: 12,
                      vertical: 8.scale,
                      label: header.status?.toUpperCase() ?? "",
                      colorText: getStatusColor(header.status),
                      bgColor: getStatusColor(
                        header.status,
                      ).withValues(alpha: .2),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.scale,
                  children: [
                    TextWidget(
                      text: header.customerName ?? "",
                      fontSize: 14,
                      color: textColor50,
                      fontWeight: FontWeight.w500,
                    ),
                    if ((header.shipToAddress ?? "").isNotEmpty)
                      BoxWidget(
                        rounding: 4,
                        padding: EdgeInsets.all(scale(8)),
                        color: grey20.withValues(alpha: 0.1),
                        isBoxShadow: false,
                        child: TextWidget(
                          text: header.shipToAddress ?? "",
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Hr(width: double.infinity),
          Padding(
            padding: EdgeInsets.fromLTRB(16.scale, 8.scale, 16.scale, 16.scale),
            child: Row(
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
                TextWidget(
                  text: Helpers.formatNumber(
                    header.amount ?? 0.0,
                    option: FormatType.amount,
                  ),
                  fontSize: 20,
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.right,
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
          ),
        ],
      ),
    );
  }
}
