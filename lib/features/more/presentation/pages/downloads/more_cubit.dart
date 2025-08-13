import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
part 'more_state.dart';

class MoreCubit extends Cubit<MoreState> {
  MoreCubit() : super(MoreState(isLoading: false));
  final appRepos = getIt<MoreRepository>();

  Future<void> downloadMasterDatas(List<AppSyncLog> tables, Function(double, int, String, String)? onProgress) async {
    try {
      emit(state.copyWith(isLoading: true));
      await appRepos.downloadTranData(tables: tables, onProgress: onProgress).then((response) {
        response.fold(Helpers.exception, (r) {
          emit(state.copyWith(isLoading: false, isSelectAll: false, refresh: !state.refresh));
        });
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      Logger.log(e.toString());
      Helpers.showMessage(msg: "Something went wrong", status: MessageStatus.errors);
    }
  }

  void setToggleSelectAll() {
    emit(state.copyWith(isSelectAll: !state.isSelectAll));
  }

  void setSelectAll(bool isSelectAll) {
    emit(state.copyWith(isSelectAll: isSelectAll));
  }

  Future<void> fetchMasterDataTables() async {
    try {
      await appRepos.getAppSyncLogs(arg: {"type": "M"}).then((response) {
        response.fold(Helpers.exception, (r) {
          emit(state.copyWith(records: r, isLoading: false));
        });
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
