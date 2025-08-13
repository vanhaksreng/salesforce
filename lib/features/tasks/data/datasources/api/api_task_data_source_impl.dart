import 'package:salesforce/core/data/datasources/api/base_api_data_source_impl.dart';
import 'package:salesforce/features/tasks/data/datasources/api/api_task_data_source.dart';
import 'package:salesforce/features/tasks/domain/entities/app_version.dart';

class ApiTaskDataSourceImpl extends BaseApiDataSourceImpl implements ApiTaskDataSource {
  ApiTaskDataSourceImpl({required super.network});

  @override
  Future<AppVersion> checkAppVersion({Map<String, dynamic>? data}) async {
    try {
      final response = await apiClient.post('v2/check-app-version', body: await getParams(params: data));
      return AppVersion.fromJson(response["record"]);
    } catch (e) {
      rethrow;
    }
  }
}
