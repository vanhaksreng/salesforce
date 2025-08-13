import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/sale_credit_memo_history_detail/sale_credit_memo_history_detail_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';

class SaleCreditMemoHistoryDetailScreen extends StatefulWidget {
  const SaleCreditMemoHistoryDetailScreen({super.key, required this.documentNo});

  final String documentNo;
  static const String routeName = "SaleCreditMemoHistoryDetailScreen";
  @override
  State<SaleCreditMemoHistoryDetailScreen> createState() => _SaleCreditMemoDetailScreenState();
}

class _SaleCreditMemoDetailScreenState extends State<SaleCreditMemoHistoryDetailScreen> {
  final _cubit = SaleCreditMemoHistoryDetailCubit();

  @override
  void initState() {
    _cubit.getSaleDetails(no: widget.documentNo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("sale_credit_memo_detail")),
      body: BlocBuilder<SaleCreditMemoHistoryDetailCubit, SaleCreditMemoHistoryDetailState>(
        bloc: _cubit,
        builder: (BuildContext context, SaleCreditMemoHistoryDetailState state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(SaleCreditMemoHistoryDetailState state) {
    final record = state.saleDetail;
    if (record == null) {
      return const Center(child: TextWidget(text: "Records is empty."));
    }
    final header = record.header;
    final lines = record.lines;

    return Padding(
      padding: const EdgeInsets.all(appSpace),
      child: SaleHistoryDetailBox(header: header, lines: lines),
    );
  }
}
