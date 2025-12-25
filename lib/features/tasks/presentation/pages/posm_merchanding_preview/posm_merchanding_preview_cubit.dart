import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/posm_merchanding_preview/posm_merchanding_preview_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class PosmMerchandingPreviewCubit extends Cubit<PosmMerchandingPreviewState> with MessageMixin {
  PosmMerchandingPreviewCubit() : super(const PosmMerchandingPreviewState(isLoading: true));
  final _taskRepos = getIt<TaskRepository>();
  late bool hasMorePage = true;

  Future<void> getPosms({bool isLoading = true, int page = 1, Map<String, dynamic>? param}) async {
    try {
      if (!hasMorePage && page > 1) {
        return;
      }

      hasMorePage = true;

      final oldItems = state.posms;
      emit(state.copyWith(isLoading: isLoading, isFetching: true));

      final response = await _taskRepos.posms(page: page, param: param);

      return response.fold((l) => throw GeneralException(l.message), (items) {
        if (page > 1 && items.isEmpty) {
          hasMorePage = false;
          return;
        }

        emit(
          state.copyWith(
            isLoading: false,
            isFetching: false,
            currentPage: page,
            posms: page == 1 ? items : [...oldItems, ...items],
          ),
        );
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false, isFetching: false));
    }
  }

  Future<void> submitMerchandiseSchdedule() async {
    try {
      final lists = List<SalesPersonScheduleMerchandise>.from(state.spsms.where((e) => e.status == kStatusOpen));
      if (lists.isEmpty) {
        showWarningMessage("Nothing to submit");
        return;
      }

      final response = await _taskRepos.updateSalesPersonScheduleMerchandiseStatus(lists, status: kStatusSubmit);

      response.fold((l) => throw GeneralException(l.message), (items) {
        emit(state.copyWith(isLoading: false, spsms: items));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getMerchandiseSchdedule(SalespersonSchedule schedule, String type) async {
    try {
      final response = await _taskRepos.getSalesPersonScheduleMerchandises(
        param: {'visit_no': schedule.id, 'merchandise_option': type, 'status': kStatusOpen},
      );

      response.fold((l) => throw GeneralException(l.message), (items) {
        emit(state.copyWith(isLoading: false, spsms: items));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteItem(SalesPersonScheduleMerchandise item, SalespersonSchedule schedule) async {
    final list = List<SalesPersonScheduleMerchandise>.from(state.spsms);

    final index = list.indexWhere((e) {
      return e.id == item.id && e.status == kStatusOpen;
    });
    if (index != -1) {
      await _taskRepos.deleteSalesPersonScheduleMerchandise(item).then((response) {
        response.fold((l) => throw GeneralException(l.message), (r) {
          list.removeAt(index);
          emit(state.copyWith(spsms: list));
        });
      });
    }
  }
}
