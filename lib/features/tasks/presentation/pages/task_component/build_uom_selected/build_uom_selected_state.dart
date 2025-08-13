part of 'build_uom_selected_cubit.dart';

class BuildUomSelectedState {
  final bool isLoading;

  final String? uomCode;

  final List<ItemUnitOfMeasure>? itemUom;

  const BuildUomSelectedState({
    this.isLoading = false,
    this.uomCode = "",
    this.itemUom,
  });

  BuildUomSelectedState copyWith({
    bool? isLoading,
    String? uomCode,
    List<ItemUnitOfMeasure>? itemUom,
  }) {
    return BuildUomSelectedState(
      isLoading: isLoading ?? this.isLoading,
      itemUom: itemUom ?? this.itemUom,
      uomCode: uomCode ?? this.uomCode,
    );
  }
}
