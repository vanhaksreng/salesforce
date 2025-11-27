import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/report/domain/repositories/report_repository.dart';
import 'package:salesforce/features/report/presentation/pages/daily_sale_summary_report/daily_sale_summary_report_state.dart';
import 'package:salesforce/injection_container.dart';

class DailySaleSummaryReportCubit extends Cubit<DailySaleSummaryReportState>
    with MessageMixin {
  DailySaleSummaryReportCubit()
    : super(const DailySaleSummaryReportState(isLoading: true));

  final ReportRepository _appRepos = getIt<ReportRepository>();

  Future<void> getDailySalesSummaryReport({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));
      final result = await _appRepos.getDailySalesSummaryReport(
        page: page,
        param: param,
      );
      result.fold((l) {
        print("====ddd======asdf===========${l.message}");
        emit(state.copyWith(isLoading: false, error: l.message));
      }, (records) => emit(state.copyWith(isLoading: false, records: records)));
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

  Future<void> chooseDate({DateTime? startDate, DateTime? toDate}) async {
    emit(state.copyWith(startDate: startDate, toDate: toDate));
  }

  Future<void> isFilter({bool isFilter = false, bool isClick = false}) async {
    emit(state.copyWith(isFilter: isFilter, isClick: isClick));
  }

  Future<void> isSelectedSalesperson(String name) async {
    emit(state.copyWith(isSelectedSalesperson: name));
  }

  Future<void> getSalespersons({Map<String, dynamic>? param}) async {
    try {
      emit(state.copyWith(isLoading: true));
      final result = await _appRepos.getSalespersons(param: param);
      result.fold(
        (l) => throw Exception(),
        (records) =>
            emit(state.copyWith(isLoading: false, recordSalespersons: records)),
      );
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }
}
