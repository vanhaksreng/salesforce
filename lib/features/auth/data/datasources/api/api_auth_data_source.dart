import 'package:salesforce/core/data/datasources/api/base_api_data_source.dart';
import 'package:salesforce/features/auth/domain/entities/login_arg.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

abstract class ApiAuthDataSource extends BaseApiDataSource {
  Future<Map<String, dynamic>> login({required LoginArg arg});
  Future<String> logout();

  Future<List<AppServer>> getServerLists();
  Future<Map<String, dynamic>> getNotification({Map? arg});
}
