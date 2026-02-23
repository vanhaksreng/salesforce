import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/generate_pdf_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/sale_invoice_history/sale_invoice_history_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class SaleInvoiceHistoryCubit extends Cubit<SaleInvoiceHistoryState>
    with MessageMixin, GeneratePdfMixin, PermissionMixin {
  SaleInvoiceHistoryCubit()
    : super(const SaleInvoiceHistoryState(isLoading: false));
  final MoreRepository appRepos = getIt<MoreRepository>();

  late bool hasMorePage = true;

  Future<void> getSaleInvoice({
    int page = 1,
    Map<String, dynamic>? param,
    bool fetchingApi = true,
  }) async {
    if (!hasMorePage && page > 1) return;

    hasMorePage = true;
    emit(state.copyWith(isFetching: true, isLoading: page == 1));
    int currentPage = 1;
    int lastPage = 1;

    try {
      final List<SalesHeader> previousRecords = page == 1
          ? []
          : List.from(state.records);

      final h = await appRepos.getSaleHeaders(
        param: param,
        page: page,
        fetchingApi: fetchingApi,
      );

      final List<SalesHeader> newRecords = await h.fold(
        (l) => throw GeneralException(l.message),
        (r) {
          currentPage = r.currentPage ?? 1;
          lastPage = r.lastPage ?? 1;
          return r.saleHeaders;
        },
      );

      if (page > 1 && newRecords.isEmpty) {
        hasMorePage = false;
        emit(state.copyWith(isLoading: false, isFetching: false));
        return;
      }

      final lines = await loadSalesLines(newRecords);
      for (final header in newRecords) {
        final headerLines = lines.where((e) => e.documentNo == header.no);

        header.totalAmtLine = headerLines
            .fold<double>(0.0, (sum, line) => sum + (line.amount ?? 0.0))
            .toString();
      }

      previousRecords.addAll(newRecords);

      emit(
        state.copyWith(
          isLoading: false,
          records: previousRecords,
          currentPage: currentPage,
          lastPage: lastPage,
        ),
      );
    } catch (error) {
      showErrorMessage(error.toString());
    } finally {
      emit(state.copyWith(isLoading: false, isFetching: false));
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
    SaleInvoiceHistoryState Function(T data) onSuccess,
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
