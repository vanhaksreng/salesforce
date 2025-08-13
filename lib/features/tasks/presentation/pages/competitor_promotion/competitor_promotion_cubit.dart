import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

part 'competitor_promotion_state.dart';

class CompetitorPromotionCubit extends Cubit<CompetitorPromotionState> {
  CompetitorPromotionCubit() : super(const CompetitorPromotionState(isLoading: true));
  final _taskRepos = getIt<TaskRepository>();
  late bool hasMorePage = true;

  Future<void> getCompetitorHeader({bool isLoading = true, int page = 1, Map<String, dynamic>? param}) async {
    try {
      if (!hasMorePage && page > 1) {
        return;
      }

      hasMorePage = true;

      final oldItems = state.completitorHeader ?? [];
      emit(state.copyWith(isLoading: isLoading, isFetching: true));

      final response = await _taskRepos.getCompetitorPromotionHeader(page: page, param: param);

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
            completitorHeader: page == 1 ? items : [...oldItems, ...items],
          ),
        );
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false, isFetching: false));
    }
  }
}
