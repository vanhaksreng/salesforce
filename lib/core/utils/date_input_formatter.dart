import 'package:flutter/services.dart';
import 'package:salesforce/core/utils/helpers.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digits
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 8 digits (YYYYMMDD)
    if (digits.length > 8) digits = digits.substring(0, 8);

    String year = '';
    String month = '';
    String day = '';

    if (digits.length >= 4) {
      year = digits.substring(0, 4);
    } else if (digits.isNotEmpty) {
      year = digits;
    }

    if (digits.length == 4 && _isAddNew(oldValue, newValue)) {
      year = "$year-";
    }

    if (digits.length > 4) {
      month = digits.substring(4, digits.length.clamp(5, 6));

      if (month.length == 1 && Helpers.toInt(month) > 1) {
        month = month.padLeft(2, '0');
      }

      // Only correct month if 2 digits entered
      if (month.length == 2) {
        int m = int.tryParse(month) ?? 1;
        if (m > 12) m = 12;
        if (m < 1) m = 1;

        month = m.toString().padLeft(2, '0');

        if (_isAddNew(oldValue, newValue)) {
          month = "$month-";
        }
      }
    }

    if (digits.length > 6) {
      day = digits.substring(6, digits.length.clamp(7, 8));

      if (day.length == 1 && Helpers.toInt(day) > 3) {
        day = day.padLeft(2, '0');
      }

      // Only correct day if 2 digits entered
      if (day.length == 2) {
        final monthDigits = digits.substring(4, digits.length.clamp(5, 6));
        final yearDigits = digits.substring(0, 4);

        int y = int.tryParse(yearDigits) ?? 1;
        int m = int.tryParse(monthDigits) ?? 1;
        int d = int.tryParse(day) ?? 1;
        int maxDay = _getDaysInMonth(y, m);
        if (d > maxDay) d = maxDay;
        if (d < 1) d = 1;
        day = d.toString().padLeft(2, '0');
      }
    }

    StringBuffer buffer = StringBuffer();
    if (year.isNotEmpty) buffer.write(year);
    if (year.length == 4 && (month.isNotEmpty || day.isNotEmpty)) {
      buffer.write('-');
    }

    if (month.isNotEmpty) buffer.write(month);
    if (month.length == 2 && day.isNotEmpty) buffer.write('-');
    if (day.isNotEmpty) buffer.write(day);

    String formatted = buffer.toString();
    if (formatted.length > 10) formatted = formatted.substring(0, 10);

    // Set cursor at the end
    int selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) return 29;
      return 28;
    }

    if ([4, 6, 9, 11].contains(month)) return 30;

    return 31;
  }

  bool _isAddNew(TextEditingValue oldValue, TextEditingValue newValue) {
    return oldValue.text.length < newValue.text.length;
  }
}
