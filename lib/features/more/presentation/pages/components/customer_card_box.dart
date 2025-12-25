import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomerCardBox extends StatelessWidget {
  const CustomerCardBox({
    super.key,
    required this.customer,
    this.onEdit,
    this.onAddAddress,
    required this.distance,
  });
  final Customer customer;
  final String distance;
  final Function(String)? onEdit;
  final Function(String)? onAddAddress;

  Color getColorStatus() {
    switch (customer.inactived) {
      case "Yes":
        return error;
      case "No":
        return success;
      default:
        return grey20;
    }
  }

  Color getColorBttn() {
    switch (customer.inactived) {
      case "Yes":
        return error;
      case "No":
        return success;
      default:
        return grey20;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      padding: const EdgeInsets.all(appSpace),
      margin: EdgeInsets.symmetric(vertical: scaleFontSize(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: scaleFontSize(appSpace),
        children: [
          _buildHeader(),
          if ((customer.address ?? "").isNotEmpty) _buildAddres(),
          _buildFooterBtn(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      spacing: 8.scale,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageNetWorkWidget(
          key: ValueKey(customer.no),
          imageUrl: customer.avatar128 ?? "",
          width: 50.scale,
          height: 50.scale,
        ),
        Expanded(
          child: Column(
            spacing: 4.scale,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: customer.no,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  ChipWidget(
                    bgColor: getColorStatus().withValues(alpha: .2),
                    label: customer.inactived == "No" ? kActive : kInActive,
                    colorText: getColorStatus(),
                  ),
                ],
              ),
              TextWidget(
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                text: customer.name ?? "",
              ),

              TextWidget(
                text: "${greeting("Distance :")}  $distance",
                color: textColor50,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddres() {
    return BoxWidget(
      padding: const EdgeInsets.all(8),
      rounding: 6,
      isBoxShadow: false,
      color: grey20.withValues(alpha: .1),
      child: Row(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SvgWidget(
            assetName: klocationOutlineIcon,
            width: 20,
            colorSvg: textColor50,
            height: 20,
          ),
          Flexible(
            flex: 3,
            child: TextWidget(
              softWrap: true,
              maxLines: 2,
              color: textColor50,
              overflow: TextOverflow.ellipsis,
              text: customer.address ?? "",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBtn() {
    return BtnWidget(
      size: BtnSize.small,
      bgColor: mainColor.withValues(alpha: .2),
      onPressed: () => onEdit?.call(customer.no),
      icon: Row(
        spacing: 8.scale,
        children: [
          const SvgWidget(
            assetName: kEditIcon,
            width: 16,
            height: 16,
            colorSvg: mainColor,
          ),
          TextWidget(text: greeting("edit"), color: mainColor),
        ],
      ),
    );
  }
}
