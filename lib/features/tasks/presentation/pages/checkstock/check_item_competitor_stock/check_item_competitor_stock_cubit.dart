import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_competitor_stock/check_item_competitor_stock_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CheckItemCompetitorStockCubit extends Cubit<CheckItemCompetitorStockState> with MessageMixin {
  CheckItemCompetitorStockCubit() : super(const CheckItemCompetitorStockState(isLoading: false));

  final _repos = getIt<TaskRepository>();
  late bool hasMorePage = true;

  Future<void> getCompetitorItemLedgetEntry({required Map<String, dynamic>? args}) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await _repos.getCompetitorItemLedgetEntry(param: args);
      response.fold(
        (l) {
          throw GeneralException(l.message);
        },
        (cile) {
          emit(state.copyWith(cile: cile));
        },
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getItems({bool isLoading = true, int page = 1, Map<String, dynamic>? param}) async {
    try {
      if (!hasMorePage && page > 1) {
        return;
      }

      hasMorePage = true;

      final oldItems = state.items;
      emit(state.copyWith(isLoading: isLoading, isFetching: true));

      final response = await _repos.getCompletitorItems(page: page, params: param);

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
            items: page == 1 ? items : [...oldItems, ...items],
          ),
        );
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false, isFetching: false));
    }
  }

  Future<void> getDetailItemCompetitorLederEntry({required String itemNo, required String visitNo}) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await _repos.detailItemCompetitorLederEntry(itemNo: itemNo, visitNo: visitNo);
      response.fold(
        (l) {
          throw GeneralException(l.message);
        },
        (detail) {
          emit(state.copyWith(detailCompetitorLedgerEntry: detail, isLoading: false));
        },
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> updateCompititorItemLedgerEntry(CheckCompititorItemStockArg data) async {
    try {
      final response = await _repos.updateCompititorItemLedgerEntry(data);
      response.fold(
        (l) {
          throw GeneralException(l.message);
        },
        (r) {
          final list = List<CompetitorItemLedgerEntry>.from(state.cile);
          final index = list.indexWhere((item) => item.itemNo == r.itemNo);

          if (index != -1) {
            list[index] = r;
          } else {
            list.add(r);
          }

          emit(state.copyWith(cile: list, isLoading: false));
        },
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
