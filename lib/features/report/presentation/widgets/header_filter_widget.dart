import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class HeaderFilterWidget extends StatelessWidget {
  const HeaderFilterWidget({
    super.key,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    this.startDate,
    this.endDate,
  });

  final Function(DateTime value) onStartDateSelected;
  final Function(DateTime value) onEndDateSelected;
  final DateTime? startDate;
  final DateTime? endDate;

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _onChangeDateHandler(BuildContext context, bool isStartDate, DateTime? initialDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: greeting("select_date"),
      cancelText: greeting("cancel"),
      confirmText: greeting("ok"),
    );

    if (selectedDate != null) {
      if (isStartDate) {
        onStartDateSelected(selectedDate);
      } else {
        onEndDateSelected(selectedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8.scale,
      children: [
        buildDate(date: _formatDate(startDate), onTap: () => _onChangeDateHandler(context, true, startDate)),
        const TextWidget(maxLines: 1, overflow: TextOverflow.ellipsis, text: " To "),
        buildDate(date: _formatDate(endDate), onTap: () => _onChangeDateHandler(context, false, endDate)),
      ],
    );
  }

  ListTitleWidget buildDate({required String date, required VoidCallback onTap}) {
    return ListTitleWidget(
      onTap: onTap,
      minTileHeight: scaleFontSize(45),
      leading: TextWidget(text: date, textAlign: TextAlign.center),
      textColor: primary,
      trailing: const Icon(Icons.arrow_drop_down_sharp, size: 18, color: textColor50),
    );
  }
}
