import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/stock/domain/repositories/stock_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

part 'group_screen_filter_item_state.dart';

class GroupScreenFilterItemCubit extends Cubit<GroupScreenFilterItemState> {
  GroupScreenFilterItemCubit()
    : super(const GroupScreenFilterItemState(isLoading: true));
  final StockRepository repos = getIt<StockRepository>();

  bool hasMorePage = true;

  Future<void> selectedGroupCode(String code) async {
    print("====================> $code");
    try {
      final List<String> currentCodes = List<String>.from(state.grupCode ?? []);
      if (currentCodes.contains(code)) {
        currentCodes.remove(code);
      } else {
        currentCodes.add(code);
      }

      emit(state.copyWith(grupCode: currentCodes, lastSelectedCode: code));
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  void resetFilter() {
    emit(state.copyWith(grupCode: [], statusStock: ""));
  }

  Future<void> getItemsGroup({
    bool isLoading = true,
    int page = 1,
    Map<String, dynamic>? param,
  }) async {
    try {
      if (!hasMorePage && page > 1) {
        return;
      }

      hasMorePage = true;

      final oldItems = state.itemsGroup ?? [];
      emit(state.copyWith(isLoading: isLoading, isFetching: true));

      final response = await repos.getItemsGroup(page: page, param: param);

      return response.fold((l) => throw GeneralException(l.message), (items) {
        if (page > 1 && items.isEmpty) {
          hasMorePage = false;
          return;
        }

        emit(
          state.copyWith(
            isLoading: false,
            isFetching: false,
            currentPage: page,
            itemsGroup: page == 1 ? items : [...oldItems, ...items],
          ),
        );
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false, isFetching: false));
    }
  }

  void selectStatus(String status) {
    emit(state.copyWith(statusStock: status));
  }

  // Future<void> getItemsGroup({int page = 1, bool isMore = false}) async {
  //   try {
  //     if (!isMore) {
  //       emit(state.copyWith(isLoading: true));
  //       final response = await repos.getItemsGroup(page: page);
  //       return response.fold(
  //         (failure) => emit(state.copyWith(
  //           isLoading: false,
  //         )),
  //         (items) => emit(state.copyWith(isLoading: false, itemsGroup: items)),
  //       );
  //     }

  //     if (state.isFetching) return;
  //     emit(state.copyWith(isFetching: true));

  //     final response = await repos.getItemsGroup(page: page);
  //     response.fold(
  //       (failure) => emit(state.copyWith(
  //         isFetching: false,
  //       )),
  //       (newItems) {
  //         final currentItems = state.itemsGroup ?? [];
  //         final uniqueItems =
  //             newItems.where((item) => !currentItems.contains(item)).toList();
  //         emit(state.copyWith(
  //           isFetching: false,
  //           itemsGroup: [...currentItems, ...uniqueItems],
  //         ));
  //       },
  //     );
  //   } catch (e) {
  //     emit(state.copyWith(
  //       isLoading: false,
  //       isFetching: false,
  //     ));
  //   }
  // }
}
