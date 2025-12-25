import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/no_emoji_text_formater.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:salesforce/core/utils/helpers.dart';

class TextFormFieldWidget extends TextFormField {
  TextFormFieldWidget({
    super.key,
    required TextEditingController controller,
    super.keyboardType,
    super.onFieldSubmitted,
    super.onSaved,
    super.onChanged,
    super.onTap,
    super.readOnly = false,
    super.obscureText = false,
    super.obscuringCharacter = '•',
    super.validator,
    super.maxLength,
    super.maxLines,
    // super.inputFormatters,
    super.focusNode,
    super.textAlign = TextAlign.start,
    super.autofocus = false,
    List<TextInputFormatter>? inputFormatters,
    EdgeInsetsGeometry? contentPadding,
    Widget? prefix,
    Color hintColor = textColor50,
    FontWeight? hintFontWeight,
    double? hintFontSize,
    Color? fillColor,
    InputBorder? border,
    Color? textColor,
    FontWeight? textFontWeight,
    double? textFontSize,
    Widget? suffixIcon,
    InputBorder? enabledBorder,
    InputBorder? focusedBorder,
    Function(PointerDownEvent)? onTapOutside,
    Widget? prefixIcon,
    bool? isDense,
    Widget? suffix,
    bool isDefaultTextForm = false,
    bool? filled,
    TextDecoration decoration = TextDecoration.none,
    Color? decorationColor,
    String label = "",
    String? hintText,
    this.isOption = false,
    FloatingLabelBehavior? floatingLabelBehavior,
    this.isRequired = false,
  }) : super(
         inputFormatters: [NoEmojiTextInputFormatter(), ...?inputFormatters],
         controller: controller,
         onTapOutside:
             onTapOutside ??
             (event) => FocusManager.instance.primaryFocus?.unfocus(),
         style: TextStyle(
           decoration: decoration,
           decorationColor: decorationColor,
           color: textColor,
           fontWeight: textFontWeight,
           fontSize: scaleFontSize(textFontSize ?? 14),
           fontFamily: Helpers.getFontFamily(controller.text),
         ),
         decoration: _buildInputDecoration(
           isDefaultTextForm: isDefaultTextForm,
           contentPadding: contentPadding,
           prefix: prefix,
           hintColor: hintColor,
           hintFontWeight: hintFontWeight,
           hintFontSize: hintFontSize,
           fillColor: fillColor,
           border: border,
           suffixIcon: suffixIcon,
           enabledBorder: enabledBorder,
           focusedBorder: focusedBorder,
           prefixIcon: prefixIcon,
           isDense: isDense,
           suffix: suffix,
           filled: filled,
           label: label,
           floatingLabelBehavior: floatingLabelBehavior,
           hintText: hintText,
           focusNode: focusNode ?? FocusNode(),
           readOnly: readOnly,
           isOption: isOption,
           isRequired: isRequired,
         ),
       );

  final bool isOption;
  final bool isRequired;

  static InputDecoration _buildInputDecoration({
    required bool isDefaultTextForm,
    required FocusNode focusNode,
    EdgeInsetsGeometry? contentPadding,
    Widget? prefix,
    Color? hintColor,
    FontWeight? hintFontWeight,
    double? hintFontSize,
    Color? fillColor,
    InputBorder? border,
    Widget? suffixIcon,
    InputBorder? enabledBorder,
    InputBorder? focusedBorder,
    Widget? prefixIcon,
    FloatingLabelBehavior? floatingLabelBehavior,
    bool? isDense,
    Widget? suffix,
    bool? filled,
    String label = "",
    String? hintText,
    bool readOnly = false,
    bool isOption = false,
    bool isRequired = false,
  }) {
    final defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: primary.withValues(alpha: 0.5),
        width: scaleFontSize(1),
      ),
      borderRadius: BorderRadius.circular(scaleFontSize(8)),
    );

    final defaultPadding = EdgeInsets.fromLTRB(
      scaleFontSize(8),
      scaleFontSize(10),
      scaleFontSize(8),
      scaleFontSize(10),
    );

    String star = (isRequired && label.isNotEmpty) ? "*" : "";

    return InputDecoration(
      alignLabelWithHint: true,
      maintainHintSize: true,
      floatingLabelBehavior: floatingLabelBehavior,
      constraints: BoxConstraints(
        minWidth: scaleFontSize(45),
        minHeight: scaleFontSize(45),
      ),
      contentPadding: isDefaultTextForm ? defaultPadding : contentPadding,
      border: isDefaultTextForm ? defaultBorder : border,
      enabledBorder: isDefaultTextForm ? defaultBorder : enabledBorder,
      focusedBorder: isDefaultTextForm ? defaultBorder : focusedBorder,
      filled: filled,
      fillColor: readOnly && !isOption
          ? primary.withValues(alpha: 0.03)
          : fillColor,
      prefix: prefix,
      suffix: suffix,
      hintText: hintText,
      hintStyle: TextStyle(
        fontWeight: hintFontWeight,
        color: hintColor,
        fontSize: scaleFontSize(hintFontSize ?? 14),
      ),
      labelText: greeting(label) + star,
      labelStyle: TextStyle(color: textColor50, fontSize: scaleFontSize(12)),
      floatingLabelStyle: TextStyle(
        color: primary,
        fontSize: scaleFontSize(15),
      ),
      errorStyle: TextStyle(
        fontFamily: Helpers.getFontFamily(label),
        color: error,
        fontSize: 0,
      ),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: EdgeInsets.symmetric(
                horizontal: scaleFontSize(appSpace),
              ),
              child: prefixIcon,
            )
          : null,
      isDense: isDense,
    );
  }
}
