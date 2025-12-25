import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/theme/app_colors.dart';

class Hr extends StatelessWidget {
  final double height;
  final double width;
  final double horizontal;
  final double vertical;
  final Color? color;

  const Hr({
    super.key,
    this.height = 0.5,
    this.width = 230,
    this.horizontal = 0.0,
    this.vertical = 0.0,
    this.color = grey,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('hr'),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        width: width,
        height: height,
        decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(appRounding)),
      ),
    );
  }
}
