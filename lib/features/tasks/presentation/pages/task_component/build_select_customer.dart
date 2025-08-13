import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class BuildSelectCustomer extends StatelessWidget {
  const BuildSelectCustomer({super.key, required this.isSelected, required this.customer, required this.onTap});

  final bool isSelected;
  final Customer customer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      onPress: onTap,
      margin: EdgeInsets.symmetric(vertical: scaleFontSize(2), horizontal: scaleFontSize(appSpace)),
      isBoxShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: scaleFontSize(appSpace),
        children: [
          ImageNetWorkWidget(
            key: ValueKey(customer.no),
            imageUrl: customer.avatar128 ?? "",
            width: 60.scale,
            height: 60.scale,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: scaleFontSize(8),
              children: [
                TextWidget(text: customer.name ?? "", fontWeight: FontWeight.bold, color: textColor),
                ChipWidget(
                  radius: 4,
                  label: customer.no,
                  bgColor: textColor50.withValues(alpha: 0.1),
                  colorText: textColor,
                ),
                Visibility(
                  visible: customer.address != "",
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: scaleFontSize(appSpace8),
                    children: [
                      SvgWidget(
                        colorSvg: mainColor50.withValues(alpha: 0.8),
                        assetName: klocationOutlineIcon,
                        width: 16,
                        height: 16,
                      ),
                      Expanded(
                        child: TextWidget(
                          text: customer.address ?? "",
                          color: textColor50,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: customer.phoneNo != "",
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: scaleFontSize(appSpace8),
                    children: [
                      SvgWidget(
                        colorSvg: mainColor50.withValues(alpha: 0.8),
                        assetName: kPhoneCallOutlineIcon,
                        width: 16,
                        height: 16,
                      ),
                      Expanded(
                        child: TextWidget(text: customer.phoneNo ?? "", maxLines: 2, color: textColor50),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onTap == null
              ? Icon(Icons.check_circle, color: success, size: scaleFontSize(24))
              : Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: scaleFontSize(24),
                  color: isSelected ? primary : grey,
                ),
        ],
      ),

      // child: ListTile(
      //   horizontalTitleGap: 24,
      //   minTileHeight: 60,
      //   leading: ImageNetWorkWidget(
      //     key: ValueKey(customer.no),
      //     imageUrl: customer.avatar128 ?? "",
      //     width: 60.scale,
      //     height: 60.scale,
      //     fit: BoxFit.cover,
      //   ),
      //   title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     spacing: scaleFontSize(3),
      //     children: [
      //       TextWidget(
      //         text: customer.name ?? "",
      //         fontWeight: FontWeight.bold,
      //         color: textColor,
      //       ),
      //       TextWidget(text: customer.no, color: textColor50),
      //       Visibility(
      //         visible: customer.address != "",
      //         child: Row(
      //           spacing: scaleFontSize(appSpace8),
      //           children: [
      //             Icon(Icons.location_on_rounded, color: grey, size: 16.scale),
      //             Expanded(
      //               child: TextWidget(
      //                 text: customer.address ?? "",
      //                 color: textColor50,
      //                 maxLines: 2,
      //                 overflow: TextOverflow.ellipsis,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       Visibility(
      //         visible: customer.phoneNo != "",
      //         child: Row(
      //           spacing: scaleFontSize(appSpace8),
      //           children: [
      //             Icon(Icons.phone_rounded, color: grey, size: 16.scale),
      //             Expanded(
      //               child: TextWidget(
      //                 text: customer.phoneNo ?? "",
      //                 maxLines: 2,
      //                 color: textColor50,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      //   trailing: onTap == null
      //       ? const Icon(
      //           Icons.check_outlined,
      //           color: primary,
      //         )
      //       : Icon(
      //           isSelected ? Icons.check_circle : Icons.circle_outlined,
      //           color: isSelected ? primary : grey,
      //         ),
      // ),
    );
  }
}
