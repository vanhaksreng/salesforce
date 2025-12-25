// import 'package:flutter/material.dart';
// import 'package:salesforce/core/presentation/widgets/text_widget.dart';
// import 'package:salesforce/core/utils/size_config.dart';
// import 'package:salesforce/theme/app_colors.dart';

// class ReportRow extends StatelessWidget {
//   const ReportRow({
//     super.key,
//     this.label = '',
//     this.value = "",
//     this.fontSize = 14,
//     this.leftTextColor = textColor,
//     this.isUnderLine = false,
//     this.letfFontWeight = FontWeight.w600,
//   });
//   final String label;
//   final String value;
//   final Color leftTextColor;
//   final bool isUnderLine;
//   final FontWeight letfFontWeight;
//   final double fontSize;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.scale),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           TextWidget(
//             fontWeight: letfFontWeight,
//             text: label,
//             color: textColor50,
//           ),
//           TextWidget(
//             text: value,
//             fontSize: fontSize,
//             color: leftTextColor,
//             decoration: isUnderLine ? TextDecoration.underline : null,
//             fontWeight: FontWeight.bold,
//           ),
//         ],
//       ),
//     );
//   }
// }
