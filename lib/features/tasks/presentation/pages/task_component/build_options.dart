import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class BuildOptions extends StatelessWidget {
  const BuildOptions({super.key, required this.label, required this.onTap, required this.icon, this.trailing});

  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: grey20, width: 1),
            borderRadius: BorderRadius.circular(scaleFontSize(appSpace8)),
          ),
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: scaleFontSize(8)),
          title: TextWidget(text: label, fontWeight: FontWeight.w500),
          minVerticalPadding: scaleFontSize(16),
          leading: BoxWidget(
            rounding: 6,
            color: mainColor.withValues(alpha: 0.7),
            padding: EdgeInsets.all(4.scale),
            isBoxShadow: false,
            child: Icon(icon, color: white, size: 24.scale),
          ),
          trailing: trailing,
        ),
        const Hr(vertical: 0, width: double.infinity, color: background),
      ],
    );
  }
}
