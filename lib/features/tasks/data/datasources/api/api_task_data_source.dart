import 'package:salesforce/core/data/datasources/api/base_api_data_source.dart';
import 'package:salesforce/features/tasks/domain/entities/app_version.dart';

abstract class ApiTaskDataSource extends BaseApiDataSource {
  Future<AppVersion> checkAppVersion({Map<String, dynamic>? data});
}
