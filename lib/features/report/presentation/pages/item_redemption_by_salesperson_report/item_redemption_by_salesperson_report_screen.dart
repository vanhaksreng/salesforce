import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_bottomsheet_filter.dart';
import 'package:salesforce/features/report/presentation/pages/components/report_card_box_item_redemption.dart';
import 'package:salesforce/features/report/presentation/pages/item_redemption_by_salesperson_report/item_redemption_by_salesperson_report_cubit.dart';
import 'package:salesforce/features/report/presentation/pages/item_redemption_by_salesperson_report/item_redemption_by_salesperson_report_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ItemRedemptionBySalespersonReportScreen extends StatefulWidget {
  const ItemRedemptionBySalespersonReportScreen({super.key});
  static const routeName = "itemRedemptionBySalespersonReportScreen";

  @override
  State<ItemRedemptionBySalespersonReportScreen> createState() => _ItemRedemptionBySalespersonReportScreenState();
}

class _ItemRedemptionBySalespersonReportScreenState extends State<ItemRedemptionBySalespersonReportScreen> {
  final _cubit = ItemRedemptionBySalespersonReportCubit();
  DateTime? initialToDate;
  DateTime? initialFromDate;
  String selectedDate = "This Month";
  Salesperson? salesperson;
  void _showModalFilter(BuildContext context) {
    modalBottomSheet(context, child: _buildFilter());
  }

  Widget _buildFilter() {
    return BlocBuilder<ItemRedemptionBySalespersonReportCubit, ItemRedemptionBySalespersonReportState>(
      bloc: _cubit,
      builder: (context, state) {
        return SaleBottomsheetFilter(
          fromDate: initialFromDate,
          toDate: initialToDate,
          salePersons: salesperson,
          hasSalePeron: true,
          hasStatus: false,
          selectDate: selectedDate,
          onApply: (value) {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("Item Redemption by Salesperson"),
        actions: [
          BlocBuilder<ItemRedemptionBySalespersonReportCubit, ItemRedemptionBySalespersonReportState>(
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
      body: BlocBuilder<ItemRedemptionBySalespersonReportCubit, ItemRedemptionBySalespersonReportState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          // final records = state.records ?? [];
          // if (records.isEmpty) {
          //   return const EmptyScreen();
          // }
          return ListView.builder(
            itemCount: 2,
            padding: const EdgeInsets.all(appSpace),
            itemBuilder: (context, index) {
              return const ReportCardBoxItemRedemption();
            },
          );
        },
      ),
    );
  }
}
