import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 16.scale,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset("assets/images/empty_v2.png", width: 250.scale),
          TextWidget(
            text: greeting("Ooop!"),
            wordSpacing: 1,
            color: mainColor50,
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
          TextWidget(
            textAlign: TextAlign.center,
            text: greeting(
              'Nothing to see here yet.\nTry adding some items or check back later!',
            ),
            color: mainColor50.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
