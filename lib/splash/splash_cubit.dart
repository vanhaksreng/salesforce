import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/download_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/splash/splash_state.dart';

class SplashCubit extends Cubit<SplashState> with MessageMixin, DownloadMixin, AppMixin {
  SplashCubit() : super(const SplashState(isLoading: true));

  final _repos = getIt<BaseAppRepository>();
  final _taskRepos = getIt<TaskRepository>();

  Future<void> loadInitialData() async {
    try {
      await _repos.downloadAppSetting().then((respose) {
        respose.fold((l) => throw GeneralException(l.message), (r) async {
          emit(state.copyWith(isLoading: false));
        });
      });
    } on GeneralException {
      // showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getSchedules() async {
    try {
      await _taskRepos.getSchedules(DateTime.now().toDateString(), requestApi: true);
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
