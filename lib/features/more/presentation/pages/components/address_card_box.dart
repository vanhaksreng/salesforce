import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/circle_icon_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class AddressCardBox extends StatelessWidget {
  const AddressCardBox({super.key, this.address, this.onEdit, this.onDelete});
  final CustomerAddress? address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      isBoxShadow: false,
      isBorder: true,
      color: borderClr,
      margin: EdgeInsets.symmetric(vertical: 4.scale),
      padding: const EdgeInsets.all(appSpace),
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextWidget(text: address?.name ?? "", fontWeight: FontWeight.bold),
              ),
              Row(
                spacing: 16.scale,
                children: [
                  CircleIconWidget(
                    icon: Icons.edit,
                    sizeIcon: 20,
                    onPress: onEdit,
                    bgColor: mainColor50.withValues(alpha: .2),
                    colorIcon: mainColor,
                  ),
                  CircleIconWidget(
                    icon: Icons.delete,
                    sizeIcon: 20,
                    onPress: onDelete,
                    bgColor: error.withValues(alpha: .2),
                    colorIcon: error,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  spacing: 8.scale,
                  children: [
                    const SvgWidget(width: 20, height: 16, assetName: klocationOutlineIcon, colorSvg: textColor50),
                    Expanded(child: TextWidget(maxLines: 2, text: address?.address ?? "")),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
