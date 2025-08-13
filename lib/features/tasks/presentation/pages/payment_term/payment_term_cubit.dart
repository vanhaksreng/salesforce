import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_term/payment_term_state.dart';
import 'package:salesforce/injection_container.dart';

class PaymentTermCubit extends Cubit<PaymentTermState> with MessageMixin {
  PaymentTermCubit() : super(const PaymentTermState(isLoading: true));

  final _taskRepo = getIt<TaskRepository>();

  Future<void> loadInitialData() async {
    try {
      emit(state.copyWith(isLoading: true));
      await _taskRepo.getPaymentTerms().then((response) {
        response.fold((l) => throw GeneralException(l.message), (r) => emit(state.copyWith(records: r)));
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
