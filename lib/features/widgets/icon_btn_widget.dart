// import 'package:flutter/material.dart';
// import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
// import 'package:salesforce/core/utils/size_config.dart';
// import 'package:salesforce/theme/app_colors.dart';

// class IconBtnWidget extends StatelessWidget {
//   final VoidCallback onPressed;
//   final IconData? icon;
//   final String iconSvg;
//   final double iconSize;
//   final Widget? child;
//   final double withSvg;
//   final double heightSvg;
//   final Color? backgroundColor;
//   final Color iconColor;
//   final bool flipXIcon;

//   const IconBtnWidget({
//     super.key,
//     required this.onPressed,
//     this.icon,
//     this.iconSize = 20,
//     this.iconSvg = "",
//     this.withSvg = 24,
//     this.heightSvg = 24,
//     this.child,
//     this.flipXIcon = false,
//     this.backgroundColor = boxColor,
//     this.iconColor = primary,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: Transform.flip(
//         flipX: flipXIcon,
//         child: switchIcon(),
//       ),
//       onPressed: onPressed,
//       style: ButtonStyle(
//         backgroundColor: WidgetStatePropertyAll(backgroundColor),
//       ),
//     );
//   }

//   Widget? switchIcon() {
//     if (child != null) {
//       return child;
//     } else if (iconSvg.isNotEmpty) {
//       return SvgWidget(
//         assetName: iconSvg,
//         colorSvg: iconColor,
//         width: withSvg,
//         height: heightSvg,
//       );
//     }
//     return Icon(
//       icon,
//       size: scaleFontSize(iconSize),
//       color: iconColor,
//     );
//   }
// }
