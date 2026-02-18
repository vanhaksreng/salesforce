import 'package:salesforce/core/data/datasources/api/base_api_data_source_impl.dart';
import 'package:salesforce/env.dart';
import 'package:salesforce/features/auth/data/datasources/api/api_auth_data_source.dart';
import 'package:salesforce/features/auth/domain/entities/login_arg.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ApiAuthDataSourceImpl extends BaseApiDataSourceImpl
    implements ApiAuthDataSource {
  ApiAuthDataSourceImpl({required super.network});

  @override
  Future<List<AppServer>> getServerLists() async {
    try {
      final response = await apiClient.get(
        'v2/server-lists',
        customUrl: kDomain,
      );

      final List<AppServer> records = [];
      for (var item in response["records"]) {
        records.add(
          AppServer(
            item['id'] as String,
            item['name'] as String,
            item['icon'] as String,
            item['hide'] is int ? item['hide'] : 0,
            item['url'] as String,
            item['backend_url'] as String,
          ),
        );
      }

      return records;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> login({required LoginArg arg}) async {
    try {
      final response = await apiClient.post(
        'v2/login',
        customUrl: arg.server.url,
        body: await getParams(params: arg.toJson()),
      );

      return response["record"];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> logout() async {
    try {
      final response = await apiClient.post(
        'v2/logout',
        body: await getParams(),
      );

      return response["message"] as String;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getNotification({Map? arg}) async {
    try {
      return await apiClient.post(
        'v2/get-notification',
        body: await getParams(params: arg),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyResetPassword({Map? arg}) async {
    try {
      return apiClient.post(
        'v2/verify-reset-password',
        body: await getParams(params: arg),
      );
    } catch (e) {
      rethrow;
    }
  }
}
