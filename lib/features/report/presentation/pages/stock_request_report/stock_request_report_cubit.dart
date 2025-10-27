import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/report/domain/repositories/report_repository.dart';
import 'package:salesforce/injection_container.dart';

import 'stock_request_report_state.dart';

class StockRequestReportCubit extends Cubit<StockRequestReportState> {
  StockRequestReportCubit() : super(StockRequestReportState());
  final ReportRepository _appRepos = getIt<ReportRepository>();

  Future<void> getStockRequestReport({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));
      final result = await _appRepos.getStockRequestReport(
        param: param,
        page: page,
      );
      result.fold((l) {
        emit(state.copyWith(isLoading: false, error: l.message));
      }, (records) => emit(state.copyWith(isLoading: false, records: records)));
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }
}
