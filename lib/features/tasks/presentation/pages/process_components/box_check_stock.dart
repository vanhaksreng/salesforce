import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/dot_line_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class BoxCheckStock extends StatelessWidget {
  const BoxCheckStock({
    super.key,
    required this.description,
    required this.stockUomCode,
    this.description2 = "",
    this.qtyStock = "",
    this.onUpdateQty,
    this.onEditScreen,
    this.status = "",
    this.imgUrl = "",
  });

  final String qtyStock;
  final String status;
  final Function(double value)? onUpdateQty;
  final Function()? onEditScreen;

  final String description;
  final String description2;
  final String stockUomCode;
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BoxWidget(
          margin: EdgeInsets.only(bottom: scaleFontSize(8)),
          padding: EdgeInsets.all(scaleFontSize(16)),
          isBoxShadow: false,
          child: Column(
            spacing: scaleFontSize(appSpace8),
            children: [_headerPart(), const DotLine(), _footerPart(context)],
          ),
        ),
        Positioned(
          top: 20.scale,
          right: 0.scale,
          child: Transform.rotate(
            angle: 0.7,
            child: TextWidget(text: status, fontSize: 12, color: textColor50),
          ),
        ),
      ],
    );
  }

  Widget _footerPart(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: scaleFontSize(appSpace),
          children: [
            InkWell(
              onTap: () {
                if (status.isEmpty) {
                  onUpdateQty?.call(Helpers.toDouble(qtyStock));
                }
              },
              child: Container(
                width: 80.scale,
                height: 30.scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(scaleFontSize(5)),
                  border: Border.all(color: primary, width: 0.2),
                  color: status.isNotEmpty ? grey20 : null,
                ),
                child: TextWidget(
                  text: qtyStock,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                  color: _onChangeColor(),
                ),
              ),
            ),
            TextWidget(text: stockUomCode, color: _onChangeColor(), fontWeight: FontWeight.bold),
          ],
        ),
        _buildBtnDetail(),
      ],
    );
  }

  Color _onChangeColor() {
    if (status.isEmpty) {
      return primary;
    }

    return textColor50;
  }

  Widget _buildBtnDetail() {
    return TextButton(
      onPressed: () => onEditScreen?.call(),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(grey20),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.scale))),
      ),
      child: Row(
        spacing: 6.scale,
        children: [
          SvgWidget(assetName: kEditIcon, width: 12.scale, height: 12.scale),
          TextWidget(text: greeting("edit_details"), color: primary),
        ],
      ),
    );
  }

  Widget _headerPart() {
    return Row(
      spacing: scaleFontSize(appSpace),
      children: [
        ImageBoxCoverWidget(
          key: super.key,
          image: ImageNetWorkWidget(key: super.key, imageUrl: imgUrl, width: 70.scale, height: 70.scale),
        ),
        Expanded(
          child: Column(
            spacing: 2.scale,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(text: description, color: textColor50, fontWeight: FontWeight.bold),
              TextWidget(text: description2),
              _listTileWidget("${greeting("last_stock_holding")}  N/A"),
              _listTileWidget("${greeting("current_stock_holding")}  N/A"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _listTileWidget(String des) {
    return ListTile(
      minVerticalPadding: 0,
      minLeadingWidth: 16.scale,
      horizontalTitleGap: 0,
      minTileHeight: 18.scale,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.circle, size: 8.scale, color: warning.withValues(alpha: .8)),
      title: TextWidget(text: des, fontSize: 13, color: warning),
    );
  }
}
