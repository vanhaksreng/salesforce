import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/smooth_image_loader.dart';

class BuildLogoHeaderWidget extends StatelessWidget {
  const BuildLogoHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: scaleFontSize(200),
        width: scaleFontSize(250),
        child: Center(child: SmoothImageLoader(imageLocal: kAppLogoAppImage)),
      ),
    );
  }
}
