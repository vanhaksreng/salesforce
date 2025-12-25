import 'package:flutter/services.dart';

class QuantityInputFormatter extends TextInputFormatter {
  const QuantityInputFormatter({this.decimalRange = 8});
  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;

    if (text.startsWith('.')) {
      text = '0$text';
    }

    if (text == '0' && newValue.text.length > oldValue.text.length) {
      text = '0.';
    }

    final parts = text.split('.');
    var intPart = parts[0];
    var fracPart = parts.length > 1 ? parts[1] : '';

    if (intPart.length > 1) {
      intPart = intPart.replaceFirst(RegExp(r'^0+'), '');
      if (intPart.isEmpty) intPart = '0';
    }

    if (fracPart.length > decimalRange) {
      fracPart = fracPart.substring(0, decimalRange);
    }

    final newText = parts.length > 1 ? '$intPart.$fracPart' : intPart;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
