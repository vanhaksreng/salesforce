import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/process_dtos.dart';
import 'package:salesforce/theme/app_colors.dart';

class BoxProcess extends StatelessWidget {
  const BoxProcess({super.key, required this.process, required this.onTap});
  final ProcessDtos process;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!process.show) {
      return const SizedBox.shrink();
    }
    return BoxWidget(
      onPress: onTap,
      borderColor: borderClr,
      padding: const EdgeInsets.all(appSpace),
      isBorder: true,
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChipWidget(
            radius: 8,
            vertical: 8,
            bgColor: mainColor.withValues(alpha: 0.1),
            key: ValueKey(process.icon),
            child: SvgWidget(colorSvg: mainColor, assetName: process.icon),
          ),
          TextWidget(text: process.title, fontSize: 16, fontWeight: FontWeight.bold),
          Expanded(
            child: TextWidget(text: process.subTitle, maxLines: 2, color: textColor50, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
