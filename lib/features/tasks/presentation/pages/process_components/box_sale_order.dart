import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_form_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/process/process_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/dot_line_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class BoxSaleOrder extends StatefulWidget {
  const BoxSaleOrder({super.key, required this.item});
  final Item item;

  @override
  State<BoxSaleOrder> createState() => _BoxSaleOrderState();
}

class _BoxSaleOrderState extends State<BoxSaleOrder> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final screenCubit = ProcessCubit();

  void onEditScreen(BuildContext context) {
    Navigator.pushNamed(context, CheckStockFormScreen.routeName).then((value) {
      if (value != null && value is Map<String, dynamic>) {
        screenCubit.getItemUom(itemNo: widget.item.no, uOmCode: widget.item.stockUomCode ?? "");
      }
    });
  }

  @override
  void initState() {
    screenCubit.getItemUom(itemNo: widget.item.no, uOmCode: widget.item.stockUomCode ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ProcessCubit, ProcessState>(
      bloc: screenCubit,
      builder: (context, state) {
        return Stack(
          children: [
            BoxWidget(
              margin: EdgeInsets.only(bottom: scaleFontSize(8)),
              padding: EdgeInsets.all(scaleFontSize(16)),
              isBoxShadow: false,
              child: headerPart(state.itemUom),
            ),
            Positioned(right: 0, top: 0, child: Image.asset(kAppTick, width: 30, height: 25)),
          ],
        );
      },
    );
  }

  Widget footerPart(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: scaleFontSize(appSpace),
          children: const [TextWidget(text: "UNIT", color: primary, fontWeight: FontWeight.bold)],
        ),
      ],
    );
  }

  Widget buildBtnAddCart(BuildContext context) {
    return BoxWidget(
      onPress: () => onEditScreen(context),
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16), vertical: scaleFontSize(8)),
      color: primary,
      rounding: 8,
      child: Row(
        spacing: scaleFontSize(appSpace8),
        children: [
          TextWidget(text: greeting("add_to_cart"), color: white, fontSize: 13, fontWeight: FontWeight.bold),
          const SvgWidget(assetName: kAddCart, width: 16, colorSvg: white, height: 16),
        ],
      ),
    );
  }

  Widget headerPart(ItemUnitOfMeasure? itemUOM) {
    return Row(
      spacing: scaleFontSize(appSpace),
      children: [
        const ImageNetWorkWidget(key: ValueKey("img"), imageUrl: "", width: 70, height: 70),
        Expanded(
          child: Column(
            spacing: 8.scale,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 4.scale,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextWidget(text: widget.item.description ?? "", maxLines: 2, fontWeight: FontWeight.bold),
                  ),
                  ChipWidget(
                    label: "${widget.item.inventory} CAN",
                    fontSize: 10,
                    radius: 8,
                    vertical: 0,
                    borderColor: secondary.withValues(alpha: .3),
                    bgColor: secondary.withValues(alpha: .3),
                    colorText: primary,
                  ),
                ],
              ),
              if (widget.item.description2 != "") TextWidget(text: widget.item.description2 ?? ""),
              const DotLine(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: listTileWidget(
                      "${Helpers.rmZeroFormat(Helpers.toDouble(itemUOM?.qtyPerUnit ?? ""))} / ${itemUOM?.unitOfMeasureCode ?? ""}",
                    ),
                  ),
                  buildBtnAddCart(context),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget listTileWidget(String des) {
    return ListTile(
      minVerticalPadding: 0,
      minLeadingWidth: 16.scale,
      horizontalTitleGap: 0,
      minTileHeight: 18.scale,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.circle, size: 8.scale, color: textColor50.withAlpha(40)),
      title: TextWidget(text: des, fontSize: 13, color: textColor50),
    );
  }
}
