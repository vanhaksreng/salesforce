import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ItemPrizeRedemptionCardScreen extends StatelessWidget {
  final List<ItemPrizeRedemptionLine> lines;
  final List<ItemPrizeRedemptionLineEntry> entries;

  const ItemPrizeRedemptionCardScreen({super.key, required this.lines, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final line = lines[index];

        final entryIndex = entries.indexWhere((e) {
          return e.lineNo == line.lineNo && e.itemNo == line.itemNo;
        });

        return Padding(
          padding: EdgeInsets.symmetric(vertical: scaleFontSize(8)),
          child: Column(
            spacing: 8.scale,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 8.scale,
                children: [
                  const ImageNetWorkWidget(imageUrl: "", width: 60, height: 60),
                  Expanded(
                    child: Column(
                      spacing: 8.scale,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: line.itemNo ?? "",
                          fontSize: 12,
                          color: textColor50,
                          fontWeight: FontWeight.bold,
                        ),
                        TextWidget(
                          text: line.description ?? "",
                          fontSize: 14,
                          maxLines: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 8.scale,
                children: [
                  ChipWidget(
                    bgColor: warning.withValues(alpha: .1),
                    child: Row(
                      spacing: 8.scale,
                      children: [
                        Icon(Icons.redeem, color: warning, size: 16.scale),
                        TextWidget(
                          text: line.redemptionType ?? "",
                          color: warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.circle_rounded, size: 4, color: warning),
                  ChipWidget(
                    bgColor: mainColor.withValues(alpha: .1),
                    child: TextWidget(
                      text:
                          "${Helpers.formatNumberLink(line.quantity, option: FormatType.quantity)} ${line.unitOfMeasureCode}",
                      color: mainColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (entryIndex != -1) ...[
                    const Spacer(),
                    ChipWidget(
                      bgColor: primary.withValues(alpha: 0.1),
                      child: TextWidget(
                        text:
                            "${Helpers.formatNumberLink(entries[entryIndex].quantity, option: FormatType.quantity)} ${entries[entryIndex].unitOfMeasureCode ?? ""}",
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const Hr(width: double.infinity),
      itemCount: lines.length,
    );
  }
}
