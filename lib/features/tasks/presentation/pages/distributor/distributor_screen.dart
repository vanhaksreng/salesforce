import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/features/tasks/presentation/pages/distributor/distributor_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/distributor/distributor_state.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class DistributorScreen extends StatefulWidget {
  const DistributorScreen({super.key});

  static const String routeName = "distributorTaskScreen";

  @override
  State<DistributorScreen> createState() => _DistributorScreenState();
}

class _DistributorScreenState extends State<DistributorScreen> {
  final _cubit = DistributorCubit();

  @override
  void initState() {
    _cubit.loadInitialData();
    super.initState();
  }

  void _onSelectedCode(Distributor term) {
    Navigator.pop(context, term);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: "Distributors"),
      body: BlocBuilder<DistributorCubit, DistributorState>(
        bloc: _cubit,
        builder: (BuildContext context, DistributorState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(DistributorState state) {
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
          label: record.name ?? "",
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
