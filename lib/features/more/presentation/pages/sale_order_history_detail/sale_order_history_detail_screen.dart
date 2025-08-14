import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';

class SaleOrderHistoryDetailScreen extends StatefulWidget {
  const SaleOrderHistoryDetailScreen({super.key, required this.documentNo, required this.typeDoc});
  final String documentNo;
  final String typeDoc;
  static const String routeName = "SaleOrderDetailHistoryScreen";

  @override
  State<SaleOrderHistoryDetailScreen> createState() => _SaleOrderDetailScreenState();
}

class _SaleOrderDetailScreenState extends State<SaleOrderHistoryDetailScreen> {
  final _cubit = SaleOrderHistoryDetailCubit();

  @override
  void initState() {
    _cubit.getSaleDetails(no: widget.documentNo);
    super.initState();
  }

  String titleVildate() {
    if (widget.typeDoc == "Invoice") {
      return "Sale Invoice Detail";
    } else if (widget.typeDoc == "Order") {
      return "Sale Order Detail";
    }
    return "Sale Credit Memo Detail";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting(titleVildate())),
      body: BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
        bloc: _cubit,
        builder: (BuildContext context, SaleOrderHistoryDetailState state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(SaleOrderHistoryDetailState state) {
    final record = state.record;
    if (record == null) {
      return const EmptyScreen();
    }
    final header = record.header;
    final lines = record.lines;

    return Padding(
      padding: const EdgeInsets.all(appSpace),
      child: SaleHistoryDetailBox(header: header, lines: lines),
      // saleHistoryCard(header, lines),
    );
  }
}
