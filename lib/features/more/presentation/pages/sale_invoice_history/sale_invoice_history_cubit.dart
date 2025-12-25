import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/constants/permission.dart';
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
    : super(const SaleInvoiceHistoryState(isLoading: true));
  final MoreRepository appRepos = getIt<MoreRepository>();

  late bool hasMorePage = true;

  Future<void> getSaleInvoice({
    int page = 1,
    Map<String, dynamic>? param,
    bool fetchingApi = true,
  }) async {
    if (!hasMorePage && page > 1) {
      return;
    }

    hasMorePage = true;

    try {
      emit(state.copyWith(isFetching: true, isLoading: true));

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
              .fold<double>(0.0, (sum, line) => sum + (line.amount ?? 0.0))
              .toString();
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
      emit(state.copyWith(isLoading: false));
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

  Future<String> isShowAccCustomer() async {
    return await hasPermission(kUseSalesInvoiceWithoutVisit)
        ? kStatusYes
        : kStatusNo;
  }
}
