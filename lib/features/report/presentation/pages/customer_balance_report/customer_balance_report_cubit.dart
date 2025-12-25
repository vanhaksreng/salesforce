import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/report/domain/repositories/report_repository.dart';
import 'package:salesforce/features/report/presentation/pages/customer_balance_report/customer_balance_report_state.dart';
import 'package:salesforce/injection_container.dart';

class CustomerBalanceReportCubit extends Cubit<CustomerBalanceReportState> {
  CustomerBalanceReportCubit()
    : super(const CustomerBalanceReportState(isLoading: true));

  final ReportRepository _appRepos = getIt<ReportRepository>();

  Future<void> chooseDate({DateTime? startDate, DateTime? toDate}) async {
    emit(state.copyWith(startDate: startDate, toDate: toDate));
  }

  Future<void> isFilter({bool isFilter = false, bool isClick = false}) async {
    emit(state.copyWith(isFilter: isFilter, isClick: isClick));
  }

  Future<void> isSelectedSalesperson(String name) async {
    emit(state.copyWith(isSelectedSalesperson: name));
  }

  Future<void> getCustomerBalanceReport({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      final result = await _appRepos.getCustomerBalanceReport(
        param: param,
        page: page,
      );
      result.fold((l) {
        emit(state.copyWith(error: l.message, isLoading: false));
      }, (records) => emit(state.copyWith(isLoading: false, records: records)));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
