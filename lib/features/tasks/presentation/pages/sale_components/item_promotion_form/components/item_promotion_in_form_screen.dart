import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_component/qty_input.dart';
import 'package:salesforce/features/tasks/domain/entities/promotion_item_line_entity.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/item_promotion_form/item_promotion_form_screen.dart';
import 'package:salesforce/theme/app_colors.dart';

class ItemPromotionInFormScreen extends StatelessWidget {
  const ItemPromotionInFormScreen({super.key, required this.lines, required this.onChangeQTY, required this.type});

  final String type;
  final List<PromotionItemLineEntity> lines;
  final Function(PromotionItemLineEntity, double) onChangeQTY;

  void buildQty(BuildContext context, PromotionItemLineEntity line) {
    modalBottomSheet(context, child: _builInputQty(context, line));
  }

  bool _haveOwnLine(String lineType) {
    return ['Item', 'G/L Account'].contains(lineType);
  }

  Widget _builInputQty(BuildContext context, PromotionItemLineEntity line) {
    return QtyInput(
      key: const ValueKey("qty"),
      initialQty: Helpers.formatNumber(line.qty, option: FormatType.quantity),
      onChanged: (value) {
        Navigator.of(context).pop();
        onChangeQTY(line, value);
      },
      modalTitle: line.itemName,
      inputLabel: "Quantity count",
    );
  }

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return SizedBox(
        height: 50.scale,
        child: const Center(child: TextWidget(text: "No records")),
      );
    }

    return ListView.separated(
      itemCount: lines.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: appSpace, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return SizedBox(height: 8.scale);
      },
      itemBuilder: (context, lineIndex) {
        final line = lines[lineIndex];

        return BoxWidget(
          key: ValueKey(line.itemNo),
          isBoxShadow: false,
          borderColor: grey20,
          isBorder: true,
          padding: EdgeInsets.all(8.scale),
          child: Row(
            spacing: 8.scale,
            children: [
              if (type != "G/L Account")
                ImageBoxCoverWidget(
                  key: ValueKey(line.itemNo),
                  image: ImageNetWorkWidget(
                    key: ValueKey(line.itemNo),
                    imageUrl: line.itemPicture,
                    width: 50,
                    height: 50,
                  ),
                ),
              Expanded(
                child: Column(
                  spacing: 8.scale,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextWidget(text: line.itemName, fontWeight: FontWeight.bold),
                    Row(
                      spacing: 16.scale,
                      children: [
                        SizedBox(
                          width: 100.scale,
                          child: BtnWidget(
                            borderColor: _haveOwnLine(type)
                                ? grey20.withValues(alpha: 0.1)
                                : getPromotionStatusColor(type).withValues(alpha: 0.5),
                            bgColor: grey20,
                            borderWidth: 0.5,
                            radius: 8,
                            variant: _haveOwnLine(type) ? BtnVariant.primary : BtnVariant.outline,
                            size: BtnSize.xs,
                            textColor: getPromotionStatusColor(type),
                            onPressed: () => !_haveOwnLine(type) ? buildQty(context, line) : null,
                            title: Helpers.formatNumber(line.orderQty, option: FormatType.quantity),
                            fntSize: 14,
                          ),
                        ),
                        TextWidget(text: line.saleUomCode),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
