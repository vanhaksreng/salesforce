import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/features/auth/presentation/pages/loggedin_history/loggedin_history_state.dart';
import 'package:salesforce/injection_container.dart';

class LoggedinHistoryCubit extends Cubit<LoggedinHistoryState> with MessageMixin {
  LoggedinHistoryCubit() : super(const LoggedinHistoryState(isLoading: true));

  final _repos = getIt<AuthRepository>();
  final _baseAppRepository = getIt<BaseAppRepository>();

  Future<bool> offlineLogin() async {
    final auth = getAuth();

    if (auth == null) {
      return false;
    }

    return await _repos.offlineLogin(username: auth.email, token: auth.token);
  }

  Future<void> getCompanyInfo() async {
    try {
      final companyInfo = await _baseAppRepository.getCompanyInfo();
      companyInfo.fold((failure) => showErrorMessage(failure.message), (companyInfo) {
        emit(state.copyWith(company: companyInfo));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    }
  }
}
