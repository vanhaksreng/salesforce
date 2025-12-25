import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class BuildInputStock extends StatelessWidget {
  const BuildInputStock({super.key, required this.onTap, required this.qtyController, this.isEdit = true});
  final VoidCallback onTap;
  final bool isEdit;
  final TextEditingController qtyController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.scale,
      height: 30.scale,
      child: TextFormFieldWidget(
        decorationColor: primary,
        hintText: "0",
        readOnly: true,
        hintColor: primary,
        autofocus: true,
        fillColor: isEdit ? white : primary.withValues(alpha: 0.2),
        hintFontWeight: FontWeight.bold,
        decoration: isEdit ? TextDecoration.underline : TextDecoration.none,
        textAlign: TextAlign.center,
        textFontWeight: FontWeight.bold,
        textColor: primary,
        onTap: isEdit ? onTap : null,
        contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        controller: qtyController,
        focusedBorder: buildOutlineInputBorder(),
        enabledBorder: buildOutlineInputBorder(),
      ),
    );
  }

  OutlineInputBorder buildOutlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(scaleFontSize(5))),
      borderSide: const BorderSide(width: 0.2, color: primary),
    );
  }
}
