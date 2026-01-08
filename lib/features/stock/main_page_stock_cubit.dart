import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/download_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/stock/domain/repositories/stock_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

part 'main_page_stock_state.dart';

class MainPageStockCubit extends Cubit<MainPageStockState>
    with MessageMixin, DownloadMixin, AppMixin {
  MainPageStockCubit() : super(const MainPageStockState(isLoading: true));

  final StockRepository repos = getIt<StockRepository>();
  late bool hasMorePage = true;

  // Future<void> getItems({int page = 1, bool isLoading = true}) async {
  //   try {
  //     final oldItems = state.items;
  //     repos.getItems(page: page).then((response) {
  //       response.fold(
  //         (failure) => throw Exception(failure.message),
  //         (items) => emit(state.copyWith(
  //           isLoading: false,
  //           items: page == 1 ? items : [...oldItems, ...items],
  //         )),
  //       );
  //     });
  //   } catch (error) {
  //     showErrorMessage(error.toString());
  //   }
  // }

  Future<void> getItems({
    bool isLoading = true,
    int page = 1,
    Map<String, dynamic>? param,
  }) async {
    try {
      if (!hasMorePage && page > 1) {
        return;
      }

      hasMorePage = true;

      final oldItems = state.items;
      emit(state.copyWith(isLoading: isLoading, isFetching: true));

      final response = await repos.getItems(page: page, param: param);

      return response.fold((l) => throw GeneralException(l.message), (items) {
        if (items.isEmpty) {
          hasMorePage = false;
          emit(state.copyWith(isLoading: false, isFetching: false));
          return;
        }
        emit(
          state.copyWith(
            isLoading: false,
            isFetching: false,
            currentPage: page,
            items: page == 1 ? items : [...oldItems, ...items],
          ),
        );
        hasMorePage = false;
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false, isFetching: false));
    }
  }

  Future<void> getItemWorkSheets({Map<String, dynamic>? param}) async {
    try {
      final response = await repos.getItemRequestWorksheets(param: param);
      response.fold(
        (l) => emit(throw Exception(l.toString())),
        (r) => emit(state.copyWith(itemWorkSheet: r.records)),
      );
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }

  Future<void> storeStockRequest({
    required Item item,
    required double quantity,
    required String itemUomCode,
  }) async {
    try {
      emit(state.copyWith(loadingUpdate: true));

      if (quantity <= 0) {
        _deleteWorksheetItems(item.no);
        return;
      }

      final response = await repos.storeStockRequest(
        item,
        quantity,
        itemUomCode: itemUomCode,
      );
      response.fold(
        (failure) => showWarningMessage(failure.message),
        (newItem) => _updateWorksheetItems(newItem),
      );
    } catch (error) {
      showErrorMessage(error.toString());
    } finally {
      emit(state.copyWith(loadingUpdate: false));
    }
  }

  void _deleteWorksheetItems(String itemNo) async {
    final ows = List<ItemStockRequestWorkSheet>.from(state.itemWorkSheet);
    if (ows.isEmpty) {
      return;
    }

    try {
      final ws = List<ItemStockRequestWorkSheet>.from(ows);
      ws.removeWhere((item) => item.itemNo == itemNo);

      emit(state.copyWith(loadingUpdate: true, itemWorkSheet: ws));

      // Then handle database operation
      final response = await repos.deleteStockRequest(itemNo);
      response.fold((failure) {
        emit(state.copyWith(loadingUpdate: false, itemWorkSheet: ows));
        showWarningMessage(failure.message);
      }, (_) => showSuccessMessage('Item removed successfully'));
    } catch (e) {
      showErrorMessage(e.toString());
    } finally {
      emit(state.copyWith(loadingUpdate: false));
    }
  }

  void _updateWorksheetItems(ItemStockRequestWorkSheet newItem) {
    final isrws = List<ItemStockRequestWorkSheet>.from(state.itemWorkSheet);

    if (isrws.isEmpty) {
      isrws.add(newItem);
    } else {
      final index = isrws.indexWhere((e) => e.id == newItem.id);
      if (index == -1) {
        isrws.add(newItem);
      } else {
        isrws[index] = newItem;
      }
    }

    emit(state.copyWith(loadingUpdate: false, itemWorkSheet: isrws));
  }
}
