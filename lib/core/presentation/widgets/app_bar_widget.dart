import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
    this.title = "",
    this.subtitle,
    this.parentTitle,
    this.bottom,
    this.heightBottom = 0,
    this.backgroundColorLeading = white,
    this.isBackIcon = true,
    this.onBack,
    this.fontSizeTitle = 16,
    this.titleColor = textColor50,
    this.fontWeight = FontWeight.bold,
    this.actions,

    // New gradient parameters
    this.enableGradient = true,
    this.gradientColors = const [Color(0XFF4F46E5), Color(0XFF7C3AED)],
    this.gradientStops = const [0.0, 1.0],
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.gradientCoverage = 0.6, // 60% of AppBar height
  });

  final String title;
  final double heightBottom;
  final double fontSizeTitle;
  final FontWeight fontWeight;
  final Widget? bottom;
  final Widget? subtitle;
  final Color titleColor;
  final Function()? onBack;
  final Color backgroundColorLeading;
  final bool isBackIcon;
  final List<Widget>? actions;
  final String? parentTitle;

  //Gradient properties
  final bool enableGradient;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final double gradientCoverage; // 0.0 to 1.0

  Widget? _leadingWidget(BuildContext context) {
    if (!isBackIcon) {
      return null;
    }

    return InkWell(
      onTap: () {
        if (onBack != null) {
          onBack?.call();
        } else {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace + 5)),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios, size: scaleFontSize(18), color: white),
            Expanded(
              child: TextWidget(
                text: parentTitle ?? "Back",
                fontSize: 16,
                color: white,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _title() {
    return Column(
      spacing: 10.scale,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: title,
          fontWeight: fontWeight,
          fontSize: fontSizeTitle,
          color: white,
        ),
        if (subtitle != null) subtitle ?? const SizedBox.shrink(),
      ],
    );
  }

  double? _leadingWidth() {
    if (!isBackIcon) return null;
    return scaleFontSize(100);
  }

  // Method to create gradient that only affects top portion
  BoxDecoration? _getGradientDecoration() {
    if (!enableGradient || gradientColors == null || gradientColors!.isEmpty) {
      return null;
    }

    // Create colors array with proper stops for top-only gradient
    List<Color> colors = [];
    List<double> stops = [];

    if (gradientStops != null && gradientStops!.isNotEmpty) {
      // Use custom stops if provided
      colors = gradientColors!;
      stops = gradientStops!;
    } else {
      // Auto-generate stops for top-only gradient
      colors = [...gradientColors!];

      // Add the last color again to create solid bottom area
      if (colors.length > 1) {
        colors.add(colors.last);
      }

      // Generate stops
      for (int i = 0; i < gradientColors!.length; i++) {
        stops.add((i / (gradientColors!.length - 1)) * gradientCoverage);
      }
      stops.add(1.0); // Last stop at 100%
    }

    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        stops: stops,
        begin: gradientBegin,
        end: gradientEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: _leadingWidth(),
      centerTitle: isBackIcon,
      leading: _leadingWidget(context),
      title: _title(),
      toolbarHeight: scaleFontSize(65),
      actions: actions,
      backgroundColor: enableGradient ? Colors.transparent : null,
      elevation: enableGradient ? 0 : null,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(heightBottom),
        child: bottom ?? const SizedBox.shrink(),
      ),
      flexibleSpace: _getGradientDecoration() != null
          ? Container(decoration: _getGradientDecoration())
          : null,
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      scaleFontSize(kToolbarHeight) + scaleFontSize(heightBottom),
    );
  }
}
