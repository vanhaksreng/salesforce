import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_term/payment_term_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_term/payment_term_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class PaymentTermScreen extends StatefulWidget {
  const PaymentTermScreen({super.key});

  static const String routeName = "paymentTermTaskScreen";

  @override
  State<PaymentTermScreen> createState() => _PaymentTermScreenState();
}

class _PaymentTermScreenState extends State<PaymentTermScreen> {
  final _cubit = PaymentTermCubit();

  @override
  void initState() {
    _cubit.loadInitialData();
    super.initState();
  }

  void _onSelectedCode(PaymentTerm term) {
    Navigator.pop(context, term);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("Payment Term")),
      body: BlocBuilder<PaymentTermCubit, PaymentTermState>(
        bloc: _cubit,
        builder: (BuildContext context, PaymentTermState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(PaymentTermState state) {
    final records = state.records;

    if (records.isEmpty) {
      return const EmptyScreen();
    }

    return ListView.separated(
      itemCount: records.length,
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final record = records[index];
        return ListTitleWidget(
          label: record.description ?? "",
          subTitle: record.code,
          type: ListTileType.trailingSelect,
          onTap: () => _onSelectedCode(record),
          borderRadius: 0,
          fontWeight: FontWeight.normal,
          isSelected: record.code == "",
        );
      },
      separatorBuilder: (context, index) => const Hr(width: double.infinity),
    );
  }
}
