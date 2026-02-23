import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/app/app_state_handler.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/mixins/default_sale_person_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_bottomsheet_filter.dart';
import 'package:salesforce/features/report/presentation/pages/components/report_card_box_customer_balance.dart';
import 'package:salesforce/features/report/presentation/pages/customer_balance_report/customer_balance_report_cubit.dart';
import 'package:salesforce/features/report/presentation/pages/customer_balance_report/customer_balance_report_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomerBalanceReportScreen extends StatefulWidget {
  const CustomerBalanceReportScreen({super.key});

  static const String routeName = "customerBalanceReportScreen";

  @override
  State<CustomerBalanceReportScreen> createState() =>
      _CustomerBalanceReportScreenState();
}

class _CustomerBalanceReportScreenState
    extends State<CustomerBalanceReportScreen>
    with DefaultSalePersonMixin {
  final _cubit = CustomerBalanceReportCubit();
  DateTime? initialToDate;
  DateTime? initialFromDate;
  String selectedDate = "Today";

  Salesperson? salesperson;

  @override
  void initState() {
    super.initState();
    _onInit();
  }

  void _onInit() async {
    initialFromDate = DateTime.now();
    initialToDate = DateTime.now();
    _cubit.getCustomerBalanceReport(
      param: {
        "from_date": initialFromDate.toString(),
        "to_date": initialToDate.toString(),
      },
    );
  }

  void _onApplyFilter(Map<String, dynamic> param, BuildContext context) {
    if (param["ending_date"] != null) {
      initialFromDate = param["ending_date"];
    } else {
      initialFromDate = null;
    }
    if (param["ending_date"] != null) {
      initialToDate = param["ending_date"];
    } else {
      initialToDate = null;
    }
    if (param["date"] != null) {
      selectedDate = param["date"];
    } else {
      selectedDate = "";
    }
    final String fromDate = initialFromDate != null
        ? DateTimeExt.parse(initialFromDate.toString()).toDateString()
        : "";
    final String toDate = initialToDate != null
        ? DateTimeExt.parse(initialToDate.toString()).toDateString()
        : "";

    if (fromDate.isNotEmpty && toDate.isNotEmpty) {
      param["from_date"] = fromDate;
      param["to_date"] = toDate;
    }
    if (param["salesperson"] != null) {
      salesperson = param["salesperson"];
    }

    param["salesperson_code"] = salesperson?.code;

    param.removeWhere(
      (key, value) => [
        'date',
        'ending_date',
        'isFilter',
        'salesperson',
        'status',
      ].contains(key),
    );

    _cubit.getCustomerBalanceReport(param: param, page: 1);

    Navigator.of(context).pop();
  }

  void _showModalFilter(BuildContext context) {
    modalBottomSheet(context, child: _buildFilter());
  }

  Widget _buildFilter() {
    return BlocBuilder<CustomerBalanceReportCubit, CustomerBalanceReportState>(
      bloc: _cubit,
      builder: (context, state) {
        return SaleBottomsheetFilter(
          fromDate: initialFromDate,
          toDate: initialToDate,
          salePersons: salesperson,
          hasSalePeron: true,
          endDate: initialToDate,
          hasStatus: false,
          typeReport: rCustomerBanlance,
          selectDate: selectedDate,
          onApply: (value) => _onApplyFilter(value, context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("customer_balance"),
        actions: [
          BlocBuilder<CustomerBalanceReportCubit, CustomerBalanceReportState>(
            bloc: _cubit,
            builder: (context, state) {
              return BtnIconCircleWidget(
                onPressed: () => _showModalFilter(context),
                icons: SvgWidget(
                  assetName: kAppOptionIcon,
                  colorSvg: white,
                  padding: EdgeInsets.all(4.scale),
                  width: 18,
                  height: 18,
                ),
                isShowBadge: state.isFilter ?? false,
                rounded: appBtnRound,
              );
            },
          ),
          Helpers.gapW(appSpace),
        ],
      ),
      body: BlocBuilder<CustomerBalanceReportCubit, CustomerBalanceReportState>(
        bloc: _cubit,
        builder: (context, state) {
          final records = state.records ?? [];
          return AppStateHandler(
            isLoading: state.isLoading,
            error: state.error,
            records: records,
            onData: () => ListView.builder(
              itemCount: records.length,
              padding: const EdgeInsets.all(appSpace),
              itemBuilder: (context, index) {
                return ReportCardBoxCustomerBalance(report: records[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
