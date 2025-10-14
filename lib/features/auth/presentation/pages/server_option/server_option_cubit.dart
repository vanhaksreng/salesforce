import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/features/auth/presentation/pages/server_option/server_option_state.dart';
import 'package:salesforce/injection_container.dart';

class ServerOptionCubit extends Cubit<ServerOptionState>
    with MessageMixin, AppMixin {
  ServerOptionCubit() : super(const ServerOptionState(isLoading: true));

  final _appRepos = getIt<AuthRepository>();
  final _baseRepo = getIt<BaseAppRepository>();

  Future<void> getServerLists() async {
    try {
      emit(state.copyWith(isLoading: true));
      await _appRepos.getServerLists().then((respose) {
        respose.fold((l) => throw GeneralException(l.message), (r) {
          emit(state.copyWith(isLoading: false, servers: r));
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

  void setSelectedServer(String id) {
    final index = state.servers.indexWhere((e) => e.id == id);
    if (index == -1) return;

    state.servers[index];
  }

  // Future<void> updateAppServer(String orgId) async {
  //   _baseRepo.getRemoteCompanyInfo(params: {'org_id': orgId});
  // }

  Future<void> updateAppServer(String orgId) async {
    try {
      await _baseRepo.getRemoteCompanyInfo(params: {'org_id': orgId}).then((
        respose,
      ) {
        respose.fold((l) => throw GeneralException(l.message), (r) {
          emit(state.copyWith(isLoading: false, companyInfo: r));
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

  // Future<void> getCompanyInfo() async {
  //   try {
  //     emit(state.copyWith(isLoading: true));
  //     final companyInfo = await _baseRepo.getRemoteCompanyInfo();
  //     companyInfo.fold((failure) => showErrorMessage(failure.message), (
  //       companyInfo,
  //     ) {
  //       emit(state.copyWith(companyInfo: companyInfo, isLoading: false));
  //     });
  //   } on GeneralException catch (e) {
  //     showWarningMessage(e.message);
  //   } on Exception {
  //     showErrorMessage();
  //   } finally {
  //     emit(state.copyWith(isLoading: false));
  //   }
  // }
}
