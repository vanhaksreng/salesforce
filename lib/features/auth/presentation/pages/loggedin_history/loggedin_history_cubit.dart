import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/features/auth/presentation/pages/loggedin_history/loggedin_history_state.dart';
import 'package:salesforce/injection_container.dart';

class LoggedinHistoryCubit extends Cubit<LoggedinHistoryState> {
  LoggedinHistoryCubit() : super(const LoggedinHistoryState(isLoading: true));

  final _repos = getIt<AuthRepository>();

  Future<bool> offlineLogin() async {
    final auth = getAuth();

    if (auth == null) {
      return false;
    }

    return await _repos.offlineLogin(username: auth.email, token: auth.token);
  }
}
