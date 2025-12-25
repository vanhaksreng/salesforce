import 'package:flutter/material.dart';

import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/quantity_input_formatter.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/text_btn_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class QtyInput extends StatefulWidget {
  const QtyInput({
    super.key,
    required this.initialQty,
    required this.onChanged,
    this.modalTitle,
    this.inputLabel,
    this.onClose,
    this.infoText = "",
    this.errorMsg = "",
  });

  final String infoText;
  final String errorMsg;
  final String? inputLabel;
  final String? modalTitle;
  final String initialQty;
  final Function(double value)? onChanged;
  final VoidCallback? onClose;

  @override
  State<QtyInput> createState() => _QtyInputState();
}

class _QtyInputState extends State<QtyInput> {
  late final TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _controller = TextEditingController(text: widget.initialQty);
    _controller.addListener(() {
      _formKey.currentState?.validate();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: scaleFontSize(appSpace),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _headerInput(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
          child: Column(
            spacing: appSpace8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: scaleFontSize(8)),
              if (widget.infoText.isNotEmpty) TextWidget(text: widget.infoText, color: warning),
              _buildTextInputQty(),
              if (widget.errorMsg.isNotEmpty) TextWidget(text: widget.errorMsg, color: red),
              SizedBox(height: scale(appSpace)),
              SafeArea(
                child: BtnWidget(
                  onPressed: () => widget.onChanged?.call(Helpers.toDouble(_controller.text)),
                  bgColor: warning,
                  title: greeting("update"),
                ),
              ),
              SizedBox(height: scaleFontSize(16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerInput() {
    return HeaderBottomSheet(
      childWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            text: widget.modalTitle ?? "", //greeting('Quantity Count')
            fontSize: 14,
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputQty() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        return Form(
          key: _formKey,
          autovalidateMode: _switchValidateMode(value.text.isNotEmpty),
          child: TextFormFieldWidget(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            label: widget.inputLabel ?? "",
            hintText: greeting('quantity'),
            controller: _controller,
            filled: false,
            autofocus: true,
            decorationColor: warning,
            inputFormatters: const [QuantityInputFormatter(decimalRange: 8)],
            isDefaultTextForm: true,
            suffixIcon: _switchConditionSuffixICon(_controller.text),
            hintColor: warning.withValues(alpha: 0.2),
            hintFontWeight: FontWeight.normal,
            textAlign: TextAlign.center,
            textFontWeight: FontWeight.bold,
            textColor: primary,
            focusedBorder: _buildOutlineInputBorder(),
            enabledBorder: _buildOutlineInputBorder(),
          ),
        );
      },
    );
  }

  AutovalidateMode _switchValidateMode(bool autovalidate) {
    if (!autovalidate) {
      return AutovalidateMode.disabled;
    }
    return AutovalidateMode.always;
  }

  Widget _switchConditionSuffixICon(String value) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return TextBtnWidget(colorBtn: textColor50, onTap: () => _controller.clear(), titleBtn: greeting("clear"));
  }

  OutlineInputBorder _buildOutlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(scaleFontSize(5))),
      borderSide: const BorderSide(width: 0.2, color: secondary),
    );
  }
}
