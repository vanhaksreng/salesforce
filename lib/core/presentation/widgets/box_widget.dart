import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class BoxWidget extends StatelessWidget {
  const BoxWidget({
    super.key,
    required this.child,
    this.borderColor = grey,
    this.alignment,
    this.padding,
    this.height,
    this.width,
    this.borderWidth = 1,
    this.rounding = 10,
    this.onPress,
    this.margin,
    this.color = white,
    this.isBoxShadow = true,
    this.blurRadius = 15,
    this.isBorder = false,
    this.topRight = 0,
    this.topLeft = 0,
    this.isRounding = true,
    this.bottomRight = 0,
    this.bottomLeft = 0,
    this.border,
    this.gradient,
    this.onLongPress,
  });

  final Widget child;
  final Color borderColor;
  final Alignment? alignment;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final double borderWidth;
  final double rounding;
  final double topRight;
  final double topLeft;
  final double bottomRight;
  final double bottomLeft;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final bool isBoxShadow;
  final double blurRadius;
  final bool isBorder;
  final bool isRounding;
  final Border? border;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(scaleFontSize(rounding));
    final boxShadow = isBoxShadow
        ? [
            BoxShadow(
              color: grey20,
              blurRadius: blurRadius,
              offset: const Offset(0.5, 0.3),
              spreadRadius: 0,
            ),
          ]
        : null;

    Border? borderCondition() {
      if (isBorder) {
        return Border.all(width: borderWidth, color: borderColor);
      }
      return border;
    }

    // Wrap GestureDetector conditionally to reduce unnecessary layers
    final container = Container(
      alignment: alignment,
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient != null ? null : color,
        borderRadius: isRounding
            ? borderRadius
            : BorderRadius.only(
                topRight: Radius.circular(topRight),
                bottomRight: Radius.circular(bottomRight),
                bottomLeft: Radius.circular(bottomLeft),
                topLeft: Radius.circular(topLeft),
              ),
        border: borderCondition(),
        boxShadow: boxShadow,
      ),
      child: child,
    );

    return onPress == null
        ? container
        : InkWell(onTap: onPress, child: container, onLongPress: onLongPress);
  }
}
