import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/stock/domain/repositories/stock_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

part 'build_uom_selected_state.dart';

class BuildUomSelectedCubit extends Cubit<BuildUomSelectedState> {
  BuildUomSelectedCubit() : super(const BuildUomSelectedState(isLoading: true));
  final StockRepository repos = getIt<StockRepository>();

  Future<void> getItemUoms({required String itemNo}) async {
    try {
      final response = await repos.getItemUoms(params: {'item_no': itemNo});
      response.fold(
        (l) => emit(throw Exception(l.toString())),
        (items) => emit(state.copyWith(isLoading: false, itemUom: items)),
      );
    } catch (error) {
      Helpers.showMessage(msg: error.toString(), status: MessageStatus.errors);
    }
  }

  void selectedUom(String uomCode) {
    emit(state.copyWith(uomCode: uomCode));
  }
}
