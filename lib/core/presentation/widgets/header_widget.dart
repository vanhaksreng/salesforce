import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    this.icon,
    this.bgIcon = mainColor,
    required this.title,
    required this.subtitle,
    this.child,
  });
  final Widget? icon;
  final Color bgIcon;
  final String title;
  final String subtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      isBoxShadow: false,
      padding: EdgeInsets.all(scaleFontSize(16)),
      child: Column(
        spacing: scaleFontSize(16),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: scaleFontSize(8),
            children: [
              ChipWidget(
                borderColor: Colors.transparent,
                horizontal: 0,
                vertical: 10,
                radius: 10,
                bgColor: bgIcon,
                child: icon,
              ),
              Column(
                spacing: scaleFontSize(4),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  TextWidget(text: subtitle),
                ],
              ),
            ],
          ),
          Hr(width: double.infinity, color: grey20),
          Container(child: child),
        ],
      ),
    );
  }
}
