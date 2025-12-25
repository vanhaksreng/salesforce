import 'package:flutter/cupertino.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:salesforce/core/constants/app_styles.dart';

class RectBorderWidget extends StatelessWidget {
  final Widget widget;
  const RectBorderWidget({required this.widget, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      child: Container(
        decoration: BoxDecoration(borderRadius: const BorderRadius.all(appRounding), color: info.withValues(alpha: 20)),
        width: double.infinity,
        height: scaleFontSize(40),
        padding: EdgeInsets.all(scaleFontSize(appSpace)),
        child: Align(alignment: Alignment.centerLeft, child: widget),
      ),
    );
  }
}
