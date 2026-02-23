import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/mixins/generate_pdf_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history/sale_order_history_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class SaleOrderHistoryCubit extends Cubit<SaleOrderHistoryState>
    with MessageMixin, GeneratePdfMixin, PermissionMixin {
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
      emit(state.copyWith(isLoading: true));

      final oldData = state.records;
      final result = await appRepos.getSaleHeaders(
        param: param,
        page: page,
        fetchingApi: fetchingApi,
      );

      result.fold((l) => throw Exception(l.message), (records) async {
        if (page > 1 && (records.saleHeaders).isEmpty) {
          hasMorePage = false;
          return;
        }

        List<SalesLine> lines = await loadSalesLines(records.saleHeaders);

        for (var header in records.saleHeaders) {
          final headerLines = lines
              .where((e) => e.documentNo == header.no)
              .toList();

          header.totalAmtLine = headerLines
              .fold<double>(
                0.0,
                (sum, line) => sum + (line.amountIncludingVat ?? 0.0),
              )
              .toString();
        }
        emit(
          state.copyWith(
            isLoading: false,
            currentPage: records.currentPage,
            lastPage: records.lastPage,
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

  Future<List<SalesLine>> loadSalesLines(List<SalesHeader> salesHeaders) async {
    if (salesHeaders.isEmpty) return [];

    final headerNumbers = salesHeaders.map((h) => '"${h.no}"').toList();

    List<SalesLine> result = [];

    await _handleResponse(
      () => appRepos.getSaleLines(
        param: {
          'document_no': 'IN {${headerNumbers.join(",")}}',
          // 'is_sync': kStatusNo,
        },
      ),
      (List<SalesLine> data) {
        result = data;
        return state.copyWith(saleLines: data);
      },
    );

    return result;
  }

  Future<void> _handleResponse<T>(
    Future<dynamic> Function() request,
    SaleOrderHistoryState Function(T data) onSuccess,
  ) async {
    final response = await request();
    response.fold((l) => showErrorMessage(), (data) => emit(onSuccess(data)));
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

  Future<void> canSaleWithoutSchedult() async {
    final hasPermission = await this.hasPermission(
      kUseSalesInvoiceWithoutVisit,
    );

    emit(state.copyWith(canSaleWithSchedult: hasPermission));
  }

  void checkPendingUpload() async {
    await appRepos
        .getSaleHeaders(
          param: {'is_sync': kStatusNo},
          page: 1,
          fetchingApi: false,
        )
        .then((result) {
          result.fold(
            (l) => showErrorMessage(),
            (r) => emit(
              state.copyWith(hasPendingUpload: r.saleHeaders.isNotEmpty),
            ),
          );
        });
  }
}
