import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/data/models/realm_until.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
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
  final _baseAppRepository = getIt<BaseAppRepository>();

  Future<void> login({required LoginArg arg}) async {
    await _repos.login(arg: arg);
  }

  Future<void> storeAppSyncLog() async {
    try {
      await _repos.storeAppSyncLog(appSyncLogs);
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    }
  }

  Future<void> getCompanyInfo() async {
    try {
      emit(state.copyWith(isLoading: true));
      final companyInfo = await _baseAppRepository.getCompanyInfo();
      companyInfo.fold((failure) => showErrorMessage(failure.message), (
        companyInfo,
      ) {
        emit(state.copyWith(company: companyInfo, isLoading: false));
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
