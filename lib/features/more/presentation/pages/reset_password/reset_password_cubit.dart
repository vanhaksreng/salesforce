import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/reset_password/reset_password_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/localization/trans.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(ResetPasswordState());
  final MoreRepository _appRepos = getIt<MoreRepository>();

  void toggleCurrent() {
    emit(state.copyWith(isCurrentObscure: !state.isCurrentObscure));
  }

  void toggleNew() async {
    emit(state.copyWith(isNewObscure: !state.isNewObscure));
  }

  void toggleConfirm() async {
    emit(state.copyWith(isConfirmObscure: !state.isConfirmObscure));
  }

  void isMatchingPassword(String password, String confirmPassword) {
    if (password == confirmPassword) {
      emit(state.copyWith(isMatchingPassword: true));
    } else {
      Helpers.showMessage(msg: greeting("password_not_match"), status: MessageStatus.errors);
    }
  }

  Future<void> resetPassword({Map<String, dynamic>? params}) async {
    try {
      final result = await _appRepos.resetPassword(params: params);
      result.fold(
        (l) {
          Helpers.showMessage(msg: l.message, status: MessageStatus.errors);
          emit(state.copyWith(loading: false));
        },
        (message) {
          if (message.isNotEmpty) {
            Helpers.showMessage(msg: message, status: MessageStatus.success);
          }
        },
      );
      emit(state.copyWith(resetPasswordSuccess: true, loading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }
}
