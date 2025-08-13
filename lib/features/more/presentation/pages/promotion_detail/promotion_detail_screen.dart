import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/promotion_detail/promotion_detail_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/promotion_detail/promotion_detail_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class PromotionDetailScreen extends StatefulWidget {
  const PromotionDetailScreen({Key? key, required this.arg}) : super(key: key);
  static const String routeName = "promotionDetailMoreScreen";

  final ItemPromotionHeader arg;

  @override
  PromotionDetailScreenState createState() => PromotionDetailScreenState();
}

class PromotionDetailScreenState extends State<PromotionDetailScreen> {
  final _cubit = PromotionDetailCubit();

  Color getPromotionStatusColor(String? type) {
    if (type == "Item") {
      return success;
    } else if (type == "Category") {
      return warning;
    } else if (type == "Group") {
      return success.withValues(alpha: 0.5);
    } else if (type == "G/L Account") {
      return red;
    } else if (type == "Brand") {
      return red.withValues(alpha: 0.5);
    } else {
      return primary;
    }
  }

  // bool _haveOwnLine(String lineType) {
  //   return ['Item', 'G/L Account'].contains(lineType);
  // }

  @override
  void initState() {
    _cubit.getPromotionLines(widget.arg.no ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting('Item Promotion Mix')),
      body: BlocBuilder<PromotionDetailCubit, PromotionDetailState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(PromotionDetailState state) {
    return ListView(
      children: [
        _buildHeaderPomotion(),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: state.linesTemplate.length,
          padding: EdgeInsets.symmetric(horizontal: 15.scale),
          itemBuilder: (context, index) {
            final template = state.lines[index];
            return BoxWidget(
              key: ValueKey(template.type),
              border: Border(left: BorderSide(width: 4, color: getPromotionStatusColor(template.type))),
              margin: EdgeInsets.symmetric(vertical: 8.scale),
              child: Column(
                key: ValueKey(template.type),
                children: [
                  BoxWidget(
                    key: ValueKey(template.type),
                    isBoxShadow: false,
                    rounding: 8,
                    isRounding: false,
                    bottomLeft: 0,
                    bottomRight: 0,
                    topLeft: 8,
                    topRight: 8,
                    width: double.infinity,
                    padding: const EdgeInsets.all(appSpace),
                    margin: EdgeInsets.only(bottom: 8.scale),
                    child: _buildHeadItems(template),
                  ),
                  // PromotionDetailItem(
                  //   key: ValueKey("template${template.type}"),
                  //   type: template.type,
                  //   lines: template.lines,
                  // ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeadItems(ItemPromotionLine template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.scale,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8.scale,
              children: [
                Icon(Icons.circle, size: 12, color: getPromotionStatusColor(template.type)),
                TextWidget(text: template.type ?? "", fontSize: 15, fontWeight: FontWeight.bold),
              ],
            ),
            ChipWidget(
              bgColor: getPromotionStatusColor(template.type).withValues(alpha: 0.2),
              child: Row(
                spacing: 8.scale,
                children: [
                  TextWidget(
                    text: template.promotionType ?? "",
                    fontSize: 10,
                    color: getPromotionStatusColor(template.type),
                    fontWeight: FontWeight.w700,
                  ),
                  Icon(Icons.circle, size: 4.scale, color: getPromotionStatusColor(template.type)),
                  TextWidget(
                    text: "Qty : ${Helpers.formatNumber(template.quantity, option: FormatType.quantity)}",
                    fontSize: 12,
                    color: getPromotionStatusColor(template.type),
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Hr(width: double.infinity),
        TextWidget(text: template.description ?? "", fontSize: 12),
      ],
    );
  }

  Widget _buildHeaderPomotion() {
    return BoxWidget(
      margin: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: 8.scale),
      width: double.infinity,
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: widget.arg.no ?? "", fontSize: 16, fontWeight: FontWeight.bold),
          TextWidget(fontSize: 14, text: widget.arg.description ?? ""),
        ],
      ),
    );
  }
}
