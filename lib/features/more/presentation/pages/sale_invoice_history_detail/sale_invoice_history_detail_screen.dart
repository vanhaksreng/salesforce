import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/sale_invoice_history_detail/sale_invoice_history_detail_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleInvoiceHistoryDetailScreen extends StatefulWidget {
  const SaleInvoiceHistoryDetailScreen({super.key, required this.documentNo});

  final String documentNo;
  static const String routeName = "SaleInvoiceHistoryDetailScreen";

  @override
  State<SaleInvoiceHistoryDetailScreen> createState() => _SaleInvoiceDetailScreenState();
}

class _SaleInvoiceDetailScreenState extends State<SaleInvoiceHistoryDetailScreen> {
  final _cubit = SaleInvoiceHistoryDetailCubit();

  @override
  void initState() {
    _cubit.getSaleDetails(no: widget.documentNo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(title: greeting("sale_invoice_details")),
      body: BlocBuilder<SaleInvoiceHistoryDetailCubit, SaleInvoiceHistoryDetailState>(
        bloc: _cubit,
        builder: (BuildContext context, SaleInvoiceHistoryDetailState state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(SaleInvoiceHistoryDetailState state) {
    final record = state.record;
    if (record == null) {
      return const EmptyScreen();
    }
    final header = record.header;
    final lines = record.lines;

    return Padding(
      padding: const EdgeInsets.all(appSpace),
      child: SaleHistoryDetailBox(header: header, lines: lines),
    );
  }
}
