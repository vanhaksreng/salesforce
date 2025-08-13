import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/presentation/cubits/base_cubit.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview/check_stock_submit_preview_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CheckStockSubmitPreviewCubit extends TaskBaseCubit<CheckStockSubmitPreviewState>
    with MessageMixin, PermissionMixin {
  CheckStockSubmitPreviewCubit() : super(const CheckStockSubmitPreviewState());

  final TaskRepository _repo = getIt<TaskRepository>();

  void initialize({required SalespersonSchedule schedule}) async {
    emit(state.copyWith(schedule: schedule));
  }

  Future<void> getCustomerItemLedgerEntries() async {
    try {
      emit(state.copyWith(isLoading: true));

      final response = await _repo.getCustomerItemLegerEntries(
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

  Future<void> submitCheckStock() async {
    try {
      emit(state.copyWith(isLoading: true));

      final response = await _repo.submitCheckStock(state.records);
      response.fold(
        (l) {
          throw GeneralException(l.message);
        },
        (r) {
          emit(state.copyWith(records: r, isLoading: false));
        },
      );
      showSuccessMessage("Submited success");
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getItems() async {
    try {
      emit(state.copyWith(isLoading: true));

      final headerNo = state.records.map((h) => '"${h.itemNo}"').toList();
      final response = await _repo.getItems(param: {'no': 'IN {${headerNo.join(",")}}'});

      response.fold(
        (l) {
          throw GeneralException(l.message);
        },
        (items) {
          emit(state.copyWith(items: items));
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

  Future<void> deleteItem(Item item, SalespersonSchedule schedule) async {
    final list = List<CustomerItemLedgerEntry>.from(state.records);

    final index = list.indexWhere((e) {
      return e.itemNo == item.no;
    });
    if (index != -1) {
      await _repo.deleteItemCheckStock(CheckItemStockArg(item: item, stockQty: 0, schedule: schedule)).then((response) {
        response.fold((l) => throw GeneralException(l.message), (r) {
          list.removeAt(index);
          emit(state.copyWith(records: list));
        });
      });
    }
  }
}
