import 'package:flutter/material.dart';
import 'package:salesforce/localization/trans.dart';

class DatePcikerWidget extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?> onDateSelected;
  final Widget child;
  final bool isShowPickerDate;

  const DatePcikerWidget({
    Key? key,
    required this.onDateSelected,
    required this.child,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.isShowPickerDate = true,
  }) : super(key: key);

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2010),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 30)),
      helpText: greeting("select_date"),
      cancelText: greeting("cancel"),
      confirmText: greeting("ok"),
      builder: (context, pickerChild) {
        if (pickerChild == null) return const SizedBox.shrink();
        return pickerChild;
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () => isShowPickerDate ? _showDatePicker(context) : null, child: child);
  }
}
