import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

mixin AppMixin {
  final _appRepo = getIt<BaseAppRepository>();

  Future<bool> isValidApiSession() async {
    try {
      final response = await _appRepo.isValidApiSession();
      return response.fold((failure) => throw GeneralException(failure.message), (items) => true);
    } on GeneralException catch (e) {
      Helpers.showMessage(msg: e.message, status: MessageStatus.errors);
      return false;
    } on Exception {
      Helpers.showMessage(msg: errorMessage, status: MessageStatus.errors);
      return false;
    }
  }

  Future<bool> isConnectedToNetwork() async {
    return _appRepo.isConnectedToNetwork();
  }

  Future<String> getSetting(String settingKey) async {
    return _appRepo.getSetting(settingKey);
  }

  Future<GpsRouteTracking?> getLastGpsRequest() async {
    final response = await _appRepo.getLastGpsRequest();
    return response.fold((failure) => throw GeneralException(failure.message), (tracking) => tracking);
  }
}
