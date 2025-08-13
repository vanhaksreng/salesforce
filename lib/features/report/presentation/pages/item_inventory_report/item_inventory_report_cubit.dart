import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/report/domain/repositories/report_repository.dart';
import 'package:salesforce/features/report/presentation/pages/item_inventory_report/item_inventory_report_state.dart';
import 'package:salesforce/injection_container.dart';

class ItemInventoryReportCubit extends Cubit<ItemInventoryReportState> with MessageMixin {
  ItemInventoryReportCubit() : super(const ItemInventoryReportState(isLoading: true));

  final ReportRepository _reportRepo = getIt<ReportRepository>();

  Future<void> getItemInventoryReport({required Map<String, dynamic> param, int page = 1}) async {
    try {
      final response = await _reportRepo.getItemInventoryReport(param: param, page: page);
      response.fold(
        (l) {
          throw GeneralException(l.message);
        },
        (records) {
          emit(state.copyWith(records: records["data"], isLoading: false, filterNote: records["filter_note"] ?? ''));
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

  void onSelectedSalePerson(String code) {
    emit(state.copyWith(salePersonCode: code));
  }

  void onChangeDate({required DateTime date, required DateType type}) {
    if (type == DateType.fromDate) {
      emit(state.copyWith(fromDate: date));
      return;
    }
    emit(state.copyWith(endDate: date));
  }
}
