import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/report/domain/repositories/report_repository.dart';
import 'package:salesforce/features/report/presentation/pages/so_outstanding_report/so_outstanding_report_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class SoOutstandingReportCubit extends Cubit<SoOutstandingReportState>
    with MessageMixin {
  SoOutstandingReportCubit() : super(SoOutstandingReportState());
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

  Future<void> chooseStatus(String status) async {
    emit(state.copyWith(selectedStatus: status));
  }

  Future<void> selectedDate(String selectDate) async {
    emit(state.copyWith(selectedDate: selectDate));
  }

  Future<void> selectedSalePeronCode(Salesperson salePersonCoe) async {
    emit(state.copyWith(salesperson: salePersonCoe));
  }

  // Future<void> getSalespersons({
  //   Map<String, dynamic>? param,
  // }) async {
  //   try {
  //     emit(state.copyWith(isLoading: true));
  //     final result = await _appRepos.getSalespersons(param: param);
  //     result.fold(
  //       (l) => throw Exception(),
  //       (records) => emit(state.copyWith(
  //         isLoading: false,
  //         recordSalespersons: records,
  //       )),
  //     );
  //   } catch (error) {
  //     emit(state.copyWith(error: error.toString(), isLoading: false));
  //   }
  // }

  Future<void> getSoOutstandingReport({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));

      final result = await _appRepos.getSoOutstandingReport(
        page: page,
        param: param,
      );
      result.fold(
        (l) {
          emit(state.copyWith(isLoading: false, error: l.message));
        },
        (records) {
          emit(
            state.copyWith(
              isLoading: false,
              records: records,
              isFilter: param?["isFilter"],
            ),
          );
        },
      );
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

  // late bool hasMorePage = true;

  // Future<void> getSoOutstandingReport({
  //   int page = 1,
  //   Map<String, dynamic>? param,
  //   bool fetchingApi = true,
  // }) async {
  //   if (!hasMorePage && page > 1) {
  //     return;
  //   }

  //   hasMorePage = true;

  //   try {
  //     emit(state.copyWith(isFetching: true));

  //     final oldData = state.records;
  //     final result = await _appRepos.getSoOutstandingReport(
  //       param: param,
  //       page: page,
  //       // fetchingApi: fetchingApi,
  //     );

  //     result.fold(
  //       (l) => throw Exception(l.message),
  //       (records) {
  //         if (page > 1 && records.isEmpty) {
  //           hasMorePage = false;
  //           return;
  //         }
  //         emit(state.copyWith(
  //           isLoading: false,
  //           currentPage: records.currentPage ?? 1,
  //           lastPage: records.lastPage ?? 1,
  //           records: page == 1
  //               ? (records.saleHeaders ?? [])
  //               : (records.saleHeaders ?? []) + oldData,
  //         ));
  //       },
  //     );
  //   } catch (error) {
  //     emit(state.copyWith(isLoading: false));
  //     showErrorMessage(error.toString());
  //   } finally {
  //     emit(state.copyWith(isFetching: false));
  //   }
  // }
}
