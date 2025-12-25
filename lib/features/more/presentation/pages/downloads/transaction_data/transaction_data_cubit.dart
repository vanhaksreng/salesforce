import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/transaction_data/transaction_data_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class TransactionDataCubit extends Cubit<TransactionDataState> with PermissionMixin {
  TransactionDataCubit() : super(const TransactionDataState(isLoading: true));

  final appRepos = getIt<MoreRepository>();

  Future<void> loadInitialData() async {
    try {
      await appRepos.getAppSyncLogs(arg: {"type": "T"}).then((response) {
        response.fold(Helpers.exception, (r) {
          emit(state.copyWith(records: r, isLoading: false));
        });
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> downloadDatas(List<AppSyncLog> tables) async {
    await appRepos.downloadTranData(tables: tables).then((response) {
      response.fold(Helpers.exception, (r) {
        refreshTransactionData(tables[0].tableName);
      });
    });
  }

  void refreshTransactionData(String tableName) async {
    final oldTables = state.records ?? [];

    await appRepos.getAppSyncLogs(arg: {"type": "T", "tableName": tableName}).then((response) {
      response.fold(Helpers.exception, (r) {
        final index = oldTables.indexWhere((element) {
          return element.tableName == tableName;
        });

        if (index != -1) {
          oldTables[index].total = r[0].total;
          oldTables[index].lastSynchedDatetime = r[0].lastSynchedDatetime;
          emit(state.copyWith(records: oldTables));
        }
      });
    });
  }
}
