import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/generate_pdf_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/sale_credit_memo_history/sale_credit_memo_history_state.dart';
import 'package:salesforce/injection_container.dart';

class SaleCreditMemoHistoryCubit extends Cubit<SaleCreditMemoHistoryState>
    with MessageMixin, GeneratePdfMixin {
  SaleCreditMemoHistoryCubit()
    : super(const SaleCreditMemoHistoryState(isLoading: true));
  final MoreRepository appRepos = getIt<MoreRepository>();

  late bool hasMorePage = true;

  Future<void> getSaleCreditMemo({
    int page = 1,
    Map<String, dynamic>? param,
    bool fetchingApi = true,
  }) async {
    if (!hasMorePage && page > 1) {
      return;
    }

    hasMorePage = true;

    try {
      emit(state.copyWith(isFetching: true));

      final oldData = state.records;
      final result = await appRepos.getSaleHeaders(
        param: param,
        page: page,
        fetchingApi: fetchingApi,
      );

      result.fold((l) => throw Exception(l.message), (records) {
        if (page > 1 && (records.saleHeaders).isEmpty) {
          hasMorePage = false;
          return;
        }
        emit(
          state.copyWith(
            isLoading: false,
            currentPage: records.currentPage ?? 1,
            lastPage: records.lastPage ?? 1,
            records: page == 1
                ? (records.saleHeaders)
                : (records.saleHeaders) + oldData,
          ),
        );
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
      showErrorMessage(error.toString());
    } finally {
      emit(state.copyWith(isFetching: false));
    }
  }

  // Future<void> getSaleCreditMemo({
  //   Map<String, dynamic>? param,
  //   int page = 1,
  //   bool fetchingApi = true,
  // }) async {
  //   try {
  //     emit(state.copyWith(isLoading: true));

  //     final result = await appRepos.getSaleHeaders(
  //       param: param,
  //       page: page,
  //       fetchingApi: fetchingApi,
  //     );

  //     result.fold(
  //       (l) => throw Exception(),
  //       (records) => emit(state.copyWith(
  //         isLoading: false,
  //         currentPage: records.currentPage,
  //         lastPage: records.lastPage,
  //         records: records.saleHeaders,
  //       )),
  //     );
  //   } catch (error) {
  //     emit(state.copyWith(error: error.toString()));
  //   }
  // }

  Future<void> chooseDate({DateTime? startDate, DateTime? toDate}) async {
    try {
      emit(state.copyWith(startDate: startDate, toDate: toDate));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> chooseStatus(String status) async {
    emit(state.copyWith(selectedStatus: status));
  }

  Future<void> selectedDate(String selectDate) async {
    emit(state.copyWith(selectedDate: selectDate));
  }
}
