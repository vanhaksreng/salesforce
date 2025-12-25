import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_screen/payment_screen_state.dart';
import 'package:salesforce/injection_container.dart';

class PaymentScreenDartCubit extends Cubit<PaymentScreenState> with MessageMixin {
  PaymentScreenDartCubit() : super(const PaymentScreenState(isLoading: true));
  final _taskRepos = getIt<TaskRepository>();

  void selectedPayment(String code) {
    emit(state.copyWith(codePayment: code));
  }

  Future<void> getPaymentType({Map<String, dynamic>? param}) async {
    try {
      final response = await _taskRepos.getPaymentType(param: param);
      return response.fold((l) => throw GeneralException(l.message), (items) {
        emit(state.copyWith(paymentMethods: items, isLoading: false));
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
