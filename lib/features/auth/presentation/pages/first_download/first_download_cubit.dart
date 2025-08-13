import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/features/auth/presentation/pages/first_download/first_download_state.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';

class FirstDownloadCubit extends Cubit<FirstDownloadState> with MessageMixin {
  FirstDownloadCubit() : super(const FirstDownloadState(isLoading: true));

  final _repos = getIt<BaseAppRepository>();
  final _taskRepos = getIt<TaskRepository>();

  Future<void> getAppSyncLog() async {
    try {
      final response = await _repos.getAppSyncLogs();
      response.fold(
        (l) {
          throw GeneralException(l.message);
        },
        (tableLogs) {
          emit(state.copyWith(tableLogs: tableLogs));
        },
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> downLoadAppSetting() async {
    try {
      await _repos.downloadAppSetting().then((respose) {
        respose.fold((l) => throw GeneralException(l.message), (r) async {
          emit(state.copyWith(isLoading: false));
        });
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> downloadMasterData() async {
    try {
      final tables = state.tableLogs;
      if (tables.isEmpty) {
        showWarningMessage("Nothing to download");
        return;
      }

      List<String> errors = List<String>.from(state.errors);

      await _repos.downloadTranData(
        tables: tables,
        onProgress: (progressValue, total, tableName, errorMsg) {
          if (errorMsg.isNotEmpty) {
            errors.add(errorMsg);
          }

          emit(state.copyWith(progressValue: progressValue, textLoading: tableName, totalValue: total, errors: errors));
        },
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
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

  Future<void> cleanAllData() async {
    await _taskRepos.clearAllData(state.tableLogs);
  }
}
