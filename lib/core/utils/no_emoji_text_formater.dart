import 'package:flutter/services.dart';

class NoEmojiTextInputFormatter extends TextInputFormatter {
  static final _emojiRegex = RegExp(
    r'[\u{1F600}-\u{1F64F}' // Emoticons
    r'\u{1F300}-\u{1F5FF}' // Symbols & Pictographs
    r'\u{1F680}-\u{1F6FF}' // Transport & Map Symbols
    r'\u{1F1E6}-\u{1F1FF}' // Flags
    r'\u{2600}-\u{26FF}' // Misc Symbols
    r'\u{2700}-\u{27BF}' // Dingbats
    r'\u{FE00}-\u{FE0F}' // Variation Selectors
    r'\u{1F900}-\u{1F9FF}' // Supplemental Symbols and Pictographs
    r'\u{1FA70}-\u{1FAFF}' // Symbols and Pictographs Extended-A
    r'\u{200D}]', // Zero Width Joiner
    unicode: true,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text.replaceAll(_emojiRegex, '');
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
