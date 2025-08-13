import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/auth/domain/entities/login_arg.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_state.dart';
import 'package:salesforce/injection_container.dart';

class LoginCubit extends Cubit<LoginState> with MessageMixin, AppMixin {
  LoginCubit() : super(const LoginState(isLoading: true));

  final _repos = getIt<AuthRepository>();

  Future<void> login({required LoginArg arg}) async {
    try {
      emit(state.copyWith(isLoading: true));
      await _repos.login(arg: arg);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> storeAppSyncLog() async {
    try {
      await _repos.storeAppSyncLog();
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    }
  }
}
