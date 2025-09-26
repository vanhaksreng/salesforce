import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/buttom_sheet_filter_widget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/report/presentation/pages/build_selected_saleperson/build_selected_saleperson.dart';
import 'package:salesforce/features/widgets/date_pciker_widget.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleBottomsheetFilter extends StatefulWidget {
  const SaleBottomsheetFilter({
    super.key,
    this.status = "All",
    this.fromDate,
    this.toDate,
    this.onApply,
    this.hasSalePeron = false,
    this.hasStatus = true,
    this.salePersons,
    this.selectDate = "This Week",
  });

  final String status;
  final String selectDate;
  final Salesperson? salePersons;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool hasSalePeron;
  final bool hasStatus;

  final Function(Map<String, dynamic>)? onApply;

  @override
  State<SaleBottomsheetFilter> createState() => _SaleBottomsheetFilterState();
}

class _SaleBottomsheetFilterState extends State<SaleBottomsheetFilter> {
  late final ValueNotifier<String> _selectDateNotifier;

  final ValueNotifier<Salesperson?> _salePersonCodeNotifier =
      ValueNotifier<Salesperson?>(null);
  static const List<String> _listStatus = ['All', 'Approved', 'Open', 'Closed'];

  static const List<String> _listDate = [
    'Today',
    'Yesterday',
    'This Week',
    'Last Week',
    'This Month',
    'Last Month',
  ];

  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  final now = DateTime.now();
  String status = "All";
  bool isFilter = true;

  @override
  void initState() {
    super.initState();
    _salePersonCodeNotifier.value?.code = widget.salePersons?.code ?? "";
    _selectDateNotifier = ValueNotifier<String>(widget.selectDate);
    _selectedFromDate = widget.fromDate ?? now.firstDayOfWeek();
    _selectedToDate = widget.toDate ?? now.endDayOfWeek();
    status = widget.status;
  }

  void _resetFilter() {
    widget.hasSalePeron
        ? _selectDateNotifier.value = "This Month"
        : _selectDateNotifier.value = "This Week";
    _salePersonCodeNotifier.value = null;
    status = "All";
    setState(() {
      _selectedFromDate = now.firstDayOfWeek();
      _selectedToDate = now.endDayOfWeek();
      isFilter = false;
    });
  }

  void _onChangeStatus(String? value) {
    if (value != null) {
      status = value;
    }
    setState(() {});
  }

  void _onPickFrmDate(DateTime? date) {
    if (date != null) {
      setState(() {
        _selectedFromDate = date;
        _selectDateNotifier.value = "";
      });
    }
  }

  void _onPickToDate(DateTime? date) {
    if (date != null) {
      setState(() {
        _selectedToDate = date;
        _selectDateNotifier.value = "";
      });
    }
  }

  bool _buildShowReset() {
    return widget.hasSalePeron
        ? _selectDateNotifier.value != "This Month"
        : _selectDateNotifier.value != "This Week" ||
              _selectedToDate != now.endDayOfWeek() ||
              checkSalePerson() ||
              status != "All";
  }

  bool checkSalePerson() {
    return _salePersonCodeNotifier.value?.code.isNotEmpty ?? false;
  }

  Future<void> _navigatorToSaleperonScreen(BuildContext context) {
    return Navigator.pushNamed(
      context,
      BuildSelectedSaleperson.routeName,
      arguments: BuildSelectedSalepersonArg(
        salePersonCode:
            _salePersonCodeNotifier.value?.code ??
            widget.salePersons?.code ??
            "",
      ),
    ).then((value) {
      if (value == null) return;
      _salePersonCodeNotifier.value = value as Salesperson;
    });
  }

  @override
  void dispose() {
    _selectDateNotifier.dispose();
    _salePersonCodeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ButtomSheetFilterWidget(
      onApply: () => widget.onApply?.call({
        "date": _selectDateNotifier.value,
        "from_date": _selectedFromDate,
        "to_date": _selectedToDate,
        "status": status,
        "salesperson": _salePersonCodeNotifier.value,
        "isFilter": isFilter,
      }),
      onReset: _buildShowReset() ? _resetFilter : null,
      child: Column(
        spacing: 8.scale,
        children: [
          _buildDate(),
          const Hr(width: double.infinity),
          _buildStatusDropdown(),
          _buildSalePerson(),
          Helpers.gapH(scaleFontSize(8)),
          _buildDatePickerSection(),
        ],
      ),
    );
  }

  Widget _buildDate() {
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(8)),
      child: ValueListenableBuilder(
        valueListenable: _selectDateNotifier,
        builder: (context, selectedDate, _) {
          return Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 8.scale,
            runSpacing: 10.scale,
            children: _listDate.map((itemDate) {
              final bool isHasSelected = selectedDate == itemDate;
              return BtnTextWidget(
                rounded: 16,
                vertical: 8,
                horizontal: 16,
                borderColor: grey20,
                bgColor: isHasSelected ? mainColor : grey20,
                onPressed: () {
                  DateTime now = DateTime.now();
                  DateTime from, to;

                  switch (itemDate) {
                    case "Today":
                      from = now.startOfDay;
                      to = now.endOfDay;
                      break;
                    case "Yesterday":
                      from = now.subtract(const Duration(days: 1)).startOfDay;
                      to = now.subtract(const Duration(days: 1)).endOfDay;
                      break;
                    case "Last Week":
                      final lastWeekEnd = now.firstDayOfWeek().subtract(
                        const Duration(days: 1),
                      );

                      from = lastWeekEnd.firstDayOfWeek();
                      to = lastWeekEnd.endDayOfWeek();
                      break;
                    case "This Month":
                      from = now.firstDayOfMonth();
                      to = now.endDayOfMonth();
                      break;
                    case "Last Month":
                      from = now.addMonths(-1).firstDayOfMonth();
                      to = now.addMonths(-1).endDayOfMonth();
                      break;
                    default:
                      from = now.firstDayOfWeek();
                      to = now.endDayOfWeek();
                  }

                  _selectDateNotifier.value = itemDate;

                  setState(() {
                    _selectedFromDate = from;
                    _selectedToDate = to;
                  });
                },
                child: TextWidget(
                  text: itemDate,
                  color: isHasSelected ? white : textColor,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildSalePerson() {
    if (!widget.hasSalePeron) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      child: ValueListenableBuilder(
        valueListenable: _salePersonCodeNotifier,
        builder: (context, value, _) {
          return Column(
            spacing: 8.scale,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: greeting("sales_person"),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              BoxWidget(
                height: 45.scale,
                onPress: () => _navigatorToSaleperonScreen(context),
                isBoxShadow: false,
                color: grey20,
                padding: EdgeInsets.symmetric(horizontal: 16.scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text:
                          _salePersonCodeNotifier.value?.name ??
                          widget.salePersons?.name ??
                          "Select Sales Person",
                    ),
                    Icon(Icons.arrow_right, size: 16.scale, color: textColor50),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown() {
    if (widget.hasStatus == false) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: greeting("status"),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          BoxWidget(
            isBorder: true,
            borderColor: grey20,
            isBoxShadow: true,
            color: white,
            padding: EdgeInsets.symmetric(horizontal: 16.scale),
            child: DropdownButton<String>(
              value: status,
              isExpanded: true,
              elevation: 0,
              dropdownColor: white,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(8.scale),
              items: _listStatus
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: TextWidget(
                        text: item,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => _onChangeStatus(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.scale,
        children: [
          TextWidget(
            text: greeting("date_range"),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          DatePcikerWidget(
            initialDate: _selectedFromDate ?? DateTime.now(),
            onDateSelected: (date) => _onPickFrmDate(date),
            child: _buildDateDisplay(date: _selectedFromDate, label: "from"),
          ),
          TextWidget(text: greeting("to"), fontSize: 14, color: textColor50),
          DatePcikerWidget(
            initialDate: _selectedToDate ?? DateTime.now(),
            onDateSelected: (date) => _onPickToDate(date),
            child: _buildDateDisplay(date: _selectedToDate, label: "to"),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDisplay({required DateTime? date, required String label}) {
    return BoxWidget(
      rounding: 8,
      isBoxShadow: true,
      isBorder: true,
      borderColor: grey20,
      color: white,
      padding: EdgeInsets.symmetric(horizontal: 16.scale, vertical: 13.scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            fontWeight: FontWeight.w500,
            text: date?.toDateNameString() ?? "",
          ),
          Icon(size: 16.scale, Icons.calendar_month, color: textColor50),
        ],
      ),
    );
  }
}
