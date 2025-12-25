import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class BuildCustomerBoxAddress extends StatelessWidget {
  const BuildCustomerBoxAddress({super.key, required this.onTap, required this.csAddress, required this.isSelected});
  final VoidCallback onTap;
  final CustomerAddress csAddress;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: scaleFontSize(0)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                textAlign: TextAlign.start,
                TextSpan(
                  children: [
                    TextSpan(
                      text: csAddress.name ?? " ",
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14.scale),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.scale),
                        child: Icon(Icons.circle, color: grey, size: 10.scale),
                      ),
                    ),
                    TextSpan(
                      text: " (${csAddress.customerNo})",
                      style: TextStyle(color: textColor50, fontSize: 14.scale),
                    ),
                  ],
                ),
              ),
              Row(
                spacing: scaleFontSize(appSpace8),
                children: [
                  Icon(Icons.location_on_rounded, color: grey, size: 16.scale),
                  Expanded(
                    child: TextWidget(
                      text: csAddress.address ?? "",
                      color: textColor50,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                spacing: scaleFontSize(appSpace8),
                children: [
                  Icon(Icons.phone_rounded, color: grey, size: 16.scale),
                  Expanded(
                    child: TextWidget(text: csAddress.phoneNo ?? "", maxLines: 2, color: textColor50),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(!isSelected ? Icons.circle_outlined : Icons.check_circle, color: warning, size: 18.scale),
        ),
        const Hr(vertical: 0, width: double.infinity, color: background),
      ],
    );
  }
}
