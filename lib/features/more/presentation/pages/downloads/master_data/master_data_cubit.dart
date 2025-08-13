import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/master_data/master_data_state.dart';
import 'package:salesforce/injection_container.dart';

class MasterDataCubit extends Cubit<MasterDataState> {
  MasterDataCubit() : super(const MasterDataState(isLoading: true));

  final appRepos = getIt<MoreRepository>();

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
