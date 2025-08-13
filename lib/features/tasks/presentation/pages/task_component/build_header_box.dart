import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class BuildHeaderBox extends StatelessWidget {
  const BuildHeaderBox({super.key, this.active = true, this.title = '', this.checkOut = 0, this.nonCheckOut = 0});

  final bool active;
  final String title;
  final int checkOut;
  final int nonCheckOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      key: super.key,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: active ? white : grey20, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(6.scale),
      child: Column(
        children: [
          TextWidget(text: title, fontSize: 15, color: white, fontWeight: FontWeight.bold),
          Expanded(
            child: Row(
              spacing: 6.scale,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: scaleFontSize(14), color: success),
                TextWidget(text: Helpers.toStrings(checkOut), fontSize: 16, fontWeight: FontWeight.bold, color: white),
                SizedBox(width: scaleFontSize(appSpace)),
                Icon(Icons.circle, size: scaleFontSize(14), color: primary),
                TextWidget(
                  text: Helpers.toStrings(nonCheckOut),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
