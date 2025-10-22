import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/features/report/presentation/pages/build_selected_saleperson/build_selected_saleperson_cubit.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class BuildSelectedSalepersonArg {
  final String salePersonCode;
  final Function(String personCode)? onChanged;
  final VoidCallback? onClose;

  BuildSelectedSalepersonArg({
    required this.salePersonCode,
    this.onChanged,
    this.onClose,
  });
}

class BuildSelectedSaleperson extends StatefulWidget {
  const BuildSelectedSaleperson({super.key, required this.arg});
  final BuildSelectedSalepersonArg arg;
  static const routeName = "buildSalePersonScreen";

  @override
  State<BuildSelectedSaleperson> createState() =>
      _BuildSelectedSalepersonState();
}

class _BuildSelectedSalepersonState extends State<BuildSelectedSaleperson> {
  final _cubit = BuildSelectedSalepersonCubit();

  @override
  void initState() {
    onInitData();
    super.initState();
  }

  Future<void> onInitData() async {
    await _cubit.getSalespersons();
    _cubit.selectedSalePersonCode(widget.arg.salePersonCode);
  }

  void _onSelectedSalePersonCode(Salesperson? salePerson) {
    _cubit.selectedSalePersonCode(salePerson?.code ?? "");
    Navigator.pop(context, salePerson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("sales_person")),
      body:
          BlocBuilder<
            BuildSelectedSalepersonCubit,
            BuildSelectedSalepersonState
          >(
            bloc: _cubit,
            builder: (context, state) {
              final salepersons = state.salespersons ?? [];
              return ListView.separated(
                itemCount: salepersons.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final salePerson = salepersons[index];
                  return ListTitleWidget(
                    onTap: () => _onSelectedSalePersonCode(salePerson),
                    label: salePerson.name ?? '',
                    borderRadius: 0,
                    leading: ImageNetWorkWidget(
                      imageUrl: salePerson.avatar ?? "",
                    ),
                    subTitleFontSize: 12,
                    subTitle: salePerson.code,
                    isSelected: state.salePersonCode == salePerson.code,
                    type: ListTileType.trailingSelect,
                  );
                },
                separatorBuilder: (context, index) =>
                    const Hr(width: double.infinity),
              );
            },
          ),
    );
  }
}
