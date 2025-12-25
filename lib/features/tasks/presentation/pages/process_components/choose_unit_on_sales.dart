import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/select_component_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ChooseUnitOnSale extends StatelessWidget {
  ChooseUnitOnSale({
    super.key,
    required this.itemUo,
    required this.defaultUOM,
    required this.checkUOM,
    required this.getUom,
    required this.uomSelected,
  });
  final List<ItemUnitOfMeasure> itemUo;
  final Function(String uomCode) getUom;
  final String uomSelected;
  final String defaultUOM;
  final String checkUOM;

  final ValueNotifier<String> selectUom = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    selectUom.value = checkUOM == "" ? defaultUOM : uomSelected;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: scaleFontSize(appSpace),
      children: [
        const HeaderBottomSheet(
          childWidget: TextWidget(
            text: "Let's select one of Unit.",
            fontSize: 14,
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: selectUom,
          builder: (context, result, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(itemUo.length, (int index) {
                  return SelectComponentWidget(
                    isSelectUom: result == itemUo[index].unitOfMeasureCode,
                    onTap: () {
                      selectUom.value = itemUo[index].unitOfMeasureCode ?? "";
                      getUom(selectUom.value);
                    },
                    uomName: itemUo[index].unitOfMeasureCode,
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}
