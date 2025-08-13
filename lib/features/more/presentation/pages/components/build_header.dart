import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class BuildHeader extends StatelessWidget {
  const BuildHeader({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      padding: EdgeInsets.all(4.scale),
      isBoxShadow: false,
      color: grey20.withValues(alpha: .2),
      child: Row(
        spacing: 8.scale,
        children: [
          BtnIconCircleWidget(
            bgColor: mainColor.withValues(alpha: .1),
            onPressed: () {},
            icons: Icon(icon, color: mainColor),
            rounded: appBtnRound,
          ),
          TextWidget(text: greeting(label), fontWeight: FontWeight.bold, fontSize: 16, color: textColor50),
        ],
      ),
    );
  }
}
