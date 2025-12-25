import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedult/team_schedult_state.dart';
import 'package:salesforce/injection_container.dart';

class TeamSchedultCubit extends Cubit<TeamSchedultState> {
  TeamSchedultCubit() : super(const TeamSchedultState(isLoading: true));

  final TaskRepository repos = getIt<TaskRepository>();

  Future<void> loadInitialData() async {
    final stableState = state;
    try {
      emit(state.copyWith(isLoading: true));

      // TODO your code here

      emit(state.copyWith(isLoading: false));
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
      emit(stableState.copyWith(isLoading: false));
    }
  }
}
