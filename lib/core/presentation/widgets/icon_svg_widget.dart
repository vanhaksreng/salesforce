import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconSvgWidget extends StatelessWidget {
  const IconSvgWidget({
    super.key,
    required this.assetName,
    this.size,
    this.colorFilter,
    this.fit = BoxFit.contain,
    required this.onPressed,
  });

  final String assetName;
  final double? size;
  final ColorFilter? colorFilter;
  final BoxFit fit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        assetName,
        fit: fit,
        width: size,
        height: size,
        colorFilter: colorFilter,
      ),
    );
  }
}
