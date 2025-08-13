import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class SelectComponentWidget extends StatelessWidget {
  const SelectComponentWidget({super.key, required this.isSelectUom, this.uomName, required this.onTap});
  final bool isSelectUom;
  final String? uomName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: scaleFontSize(0)),
          title: TextWidget(text: uomName ?? ""),
          trailing: Icon(!isSelectUom ? Icons.circle_outlined : Icons.check_circle, color: warning, size: 18.scale),
        ),
        const Hr(vertical: 0, width: double.infinity, color: background),
      ],
    );
  }
}
