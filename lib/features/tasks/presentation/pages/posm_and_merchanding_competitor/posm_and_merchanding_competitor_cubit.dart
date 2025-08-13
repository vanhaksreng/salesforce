import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

part 'posm_and_merchanding_competitor_state.dart';

class PosmAndMerchandingCompetitorCubit extends Cubit<PosmAndMerchandingCompetitorState> with MessageMixin {
  PosmAndMerchandingCompetitorCubit() : super(const PosmAndMerchandingCompetitorState(isLoading: true));
  final _taskRepos = getIt<TaskRepository>();

  Future<void> getCompletitors({bool isMore = false, bool isSearch = false, Map<String, dynamic>? param}) async {
    try {
      if (!isMore && !isSearch) {
        emit(state.copyWith(isLoading: true, currentPage: 1));

        final response = await _taskRepos.getCompetitors();
        return response.fold(
          (failure) => emit(state.copyWith(isLoading: false)),
          (completitor) => emit(state.copyWith(isLoading: false, completitor: completitor)),
        );
      }

      if (state.isFetching) return;

      final nextPage = !isMore ? 1 : state.currentPage + 1;

      emit(state.copyWith(isFetching: true, isLoading: !isMore, currentPage: nextPage, activeSearch: isSearch));
      final queryParams = {...?param, "page": nextPage};
      final response = await _taskRepos.getCompetitors(param: queryParams);

      return response.fold((failure) => emit(state.copyWith(isFetching: false, isLoading: false)), (newItems) {
        if (newItems.isEmpty) {
          return emit(state.copyWith(isFetching: false, isLoading: false));
        }

        final currentItems = !isMore ? [] : (state.completitor ?? []);
        final uniqueItems = newItems.where((item) => !currentItems.contains(item)).toList();

        emit(
          state.copyWith(
            isFetching: false,
            isLoading: false,
            completitor: [...currentItems, ...uniqueItems],
            currentPage: nextPage,
          ),
        );
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false, isFetching: false));
    }
  }

  Future<void> getSPSM({Map<String, dynamic>? param}) async {
    try {
      final response = await _taskRepos.getSalesPersonScheduleMerchandises(param: param);
      return response.fold((l) => throw GeneralException(l.message), (items) {
        emit(state.copyWith(spsms: items, isLoading: false));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
