import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/generate_pdf_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history/sale_order_history_state.dart';
import 'package:salesforce/injection_container.dart';

class SaleOrderHistoryCubit extends Cubit<SaleOrderHistoryState>
    with MessageMixin, GeneratePdfMixin {
  SaleOrderHistoryCubit() : super(const SaleOrderHistoryState(isLoading: true));
  final MoreRepository appRepos = getIt<MoreRepository>();

  late bool hasMorePage = true;

  Future<void> getSaleOrders({
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
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      showErrorMessage(e.toString());
    } finally {
      emit(state.copyWith(isFetching: false));
    }
  }

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

  Future<void> isReset({
    DateTime? startDate,
    DateTime? toDate,
    String? selectedDate,
  }) async {
    emit(
      state.copyWith(
        startDate: startDate,
        toDate: toDate,
        selectedDate: selectedDate,
        selectedStatus: state.selectedStatus == "All"
            ? null
            : state.selectedStatus,
      ),
    );
  }

  // Future<void> getInvoiceHtml({
  //   required String documentNo,
  // }) async {
  //   try {
  //     final result = await appRepos.getInvoiceHtml(
  //       param: {"document_no": documentNo},
  //     );

  //     result.fold(
  //       (l) => throw Exception(l.message),
  //       (html) {
  //         emit(state.copyWith(
  //           htmlContent: html,
  //           isLoading: false,
  //         ));
  //       },
  //     );
  //   } catch (e) {
  //     emit(state.copyWith(isLoading: false));
  //     showErrorMessage(e.toString());
  //   } finally {
  //     emit(state.copyWith(isFetching: false));
  //   }
  // }
}
