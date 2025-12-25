import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/stock/domain/repositories/stock_repository.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_box/stock_state.dart';
import 'package:salesforce/injection_container.dart';

class StockCubit extends Cubit<StockState> with MessageMixin {
  StockCubit() : super(const StockState(isLoading: false));
  final StockRepository repos = getIt<StockRepository>();

  Future<void> getItems({int page = 1, bool isLoading = true}) async {
    try {
      final oldItems = state.items ?? [];
      repos.getItems(page: page).then((response) {
        response.fold(
          (failure) => throw Exception(failure.message),
          (items) => emit(state.copyWith(isLoading: false, items: page == 1 ? items : [...oldItems, ...items])),
        );
      });
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }

  // Future<void> getItemUom({required String itemNo}) async {
  //   try {
  //     final response = await repos.getItemUoms(itemNo);
  //     response.fold(
  //       (l) => emit(throw Exception(l.toString())),
  //       (items) => emit(
  //         state.copyWith(isLoading: false),
  //       ),
  //     );
  //   } catch (error) {
  //     showErrorMessage(error.toString());
  //   }
  // }

  Future<void> searchItems(String query) async {
    //
  }
}
