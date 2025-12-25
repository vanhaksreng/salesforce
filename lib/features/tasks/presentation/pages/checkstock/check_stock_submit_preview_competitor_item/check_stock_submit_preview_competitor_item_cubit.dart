import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/presentation/cubits/base_cubit.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview_competitor_item/check_stock_submit_preview_competitor_item_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class CheckStockSubmitPreviewCompetitorItemCubit extends TaskBaseCubit<CheckStockSubmitPreviewCompetitorItemState>
    with MessageMixin, PermissionMixin {
  CheckStockSubmitPreviewCompetitorItemCubit() : super(const CheckStockSubmitPreviewCompetitorItemState());

  final TaskRepository _repo = getIt<TaskRepository>();

  void initialize({required SalespersonSchedule schedule}) async {
    emit(state.copyWith(schedule: schedule));
  }

  Future<void> getCompetitorItemLedgerEntries() async {
    try {
      emit(state.copyWith(isLoading: true));

      final response = await _repo.getCompetitorItemLedgetEntry(
        param: {'schedule_id': state.schedule?.id, 'status': kStatusOpen},
      );

      response.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(records: r));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> submitCheckStockCometitorItem() async {
    try {
      final response = await _repo.submitCheckStockCometitorItem(state.records);
      response.fold(
        (l) {
          throw Exception(l.message);
        },
        (r) {
          emit(state.copyWith(records: r, isLoading: false));
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
}
