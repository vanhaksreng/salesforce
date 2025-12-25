import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/distributor/distributor_state.dart';
import 'package:salesforce/injection_container.dart';

class DistributorCubit extends Cubit<DistributorState> with MessageMixin {
  DistributorCubit() : super(const DistributorState(isLoading: true));

  final _repo = getIt<TaskRepository>();

  Future<void> loadInitialData() async {
    try {
      emit(state.copyWith(isLoading: true));
      await _repo.getDistributors().then((response) {
        response.fold((l) => GeneralException(l.message), (r) => emit(state.copyWith(isLoading: false, records: r)));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (e) {
      showErrorMessage(e.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
