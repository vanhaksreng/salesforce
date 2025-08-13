import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({super.key, this.progress = 0.0, this.displayText = "Please wait.."});

  final double progress;
  final String displayText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: PopScope(
        canPop: false,
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Color.fromARGB(0, 0, 0, 0)),
          child: _getBody(progress),
        ),
      ),
    );
  }

  Widget _getBody(double progress) {
    if (progress > 0) {
      return Container(
        height: scaleFontSize(80),
        padding: EdgeInsets.all(scaleFontSize(5)),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayText,
              style: TextStyle(color: primary, fontSize: scaleFontSize(15)),
            ),
            const SizedBox(height: 15),
            ClipRRect(borderRadius: BorderRadius.circular(scaleFontSize(appSpace)), child: _buildProgressBar()),
          ],
        ),
      );
    }

    return _buildLoadingText();
  }

  Widget _buildProgressBar() {
    return SizedBox(
      width: SizeConfig.screenWidth * 0.8,
      height: 15.scale,
      child: LinearProgressIndicator(
        value: (progress / 100).clamp(0.0, 1.0),
        valueColor: const AlwaysStoppedAnimation<Color>(primary),
        backgroundColor: grey,
        minHeight: scaleFontSize(15),
        borderRadius: BorderRadius.circular(scaleFontSize(8)),
      ),
    );
  }

  Widget _buildLoadingText() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(scaleFontSize(appSpace)),
      child: Container(
        alignment: Alignment.center,
        width: 150.scale,
        height: 160.scale,
        decoration: const BoxDecoration(color: white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4.scale,
          children: [
            SizedBox(
              width: 24.scale,
              height: 24.scale,
              child: const CircularProgressIndicator(strokeWidth: 2, color: primary),
            ),
            const TextWidget(text: "Processing...", fontSize: 12),
          ],
        ),
      ),
    );
  }
}
