import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

mixin DownloadMixin {
  final _appRepo = getIt<BaseAppRepository>();

  Future<void> downloadDatas(
    List<AppSyncLog> tables, {
    Function(double, int, String, String)? onProgress,
    Map<String, dynamic>? param,
    bool showMessageAfterSuccess = true,
  }) async {
    try {
      await _appRepo.downloadTranData(tables: tables, onProgress: onProgress).then((response) {
        response.fold((l) => GeneralException(l.message), (r) {
          if (onProgress != null && showMessageAfterSuccess) {
            Helpers.showMessage(msg: "Data is up to date");
          }
        });
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<List<AppSyncLog>> getAppSyncLogs(Map<String, dynamic> tables) async {
    try {
      final r = await _appRepo.getAppSyncLogs(arg: tables);
      return r.fold((l) => throw Exception(l.message), (tables) => tables);
    } catch (_) {
      rethrow;
    }
  }
}
