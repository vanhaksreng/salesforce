import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/domain/entities/app_args.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/presentation/pages/build_uom_selected/build_uom_selected_cubit.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class BuildUomSelected extends StatefulWidget {
  const BuildUomSelected({super.key, required this.arg});

  final BuildUomArg arg;

  @override
  State<BuildUomSelected> createState() => _BuildUomSelectedState();
}

class _BuildUomSelectedState extends State<BuildUomSelected> {
  final _cubit = BuildUomSelectedCubit();

  @override
  void initState() {
    _cubit.getItemUoms(itemNo: widget.arg.itemNo);
    _cubit.selectedUom(widget.arg.uomCode);
    super.initState();
  }

  void _onSelectedUomCode(ItemUnitOfMeasure itemUom) {
    _cubit.selectedUom(itemUom.unitOfMeasureCode ?? "");
    widget.arg.onChanged?.call(itemUom.unitOfMeasureCode ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildUomSelectedCubit, BuildUomSelectedState>(
      bloc: _cubit,
      builder: (context, state) {
        final itemUoms = state.itemUom ?? [];
        return Column(
          spacing: scaleFontSize(appSpace),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _headerInput(),
            ListView.separated(
              itemCount: itemUoms.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final itemUom = itemUoms[index];
                return ListTitleWidget(
                  onTap: () => _onSelectedUomCode(itemUom),
                  label: itemUom.unitOfMeasureCode ?? '',
                  borderRadius: 0,
                  isSelected: state.uomCode == itemUom.unitOfMeasureCode,
                  type: ListTileType.trailingSelect,
                );
              },
              separatorBuilder: (context, index) => const Hr(width: double.infinity),
            ),
          ],
        );
      },
    );
  }

  Widget _headerInput() {
    return HeaderBottomSheet(
      childWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(text: widget.arg.modalTitle ?? "", fontSize: 14, color: white, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
