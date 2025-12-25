import 'dart:convert';
import 'dart:io';
import 'package:salesforce/core/data/datasources/api/base_api_data_source.dart';
import 'package:salesforce/core/data/models/extension/salesperson_schedule_extension.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/core/data/datasources/api/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class BaseApiDataSourceImpl implements BaseApiDataSource {
  final ApiClient apiClient;

  BaseApiDataSourceImpl({required NetworkInfo network})
    : apiClient = ApiClient(client: http.Client(), networkInfo: network);

  Future<String> getParams({Map? params}) async {
    try {
      final auth = getAuth();
      final Map param = {
        "app_id": "com.clearviewerp.salesforce",
        "token": auth?.token ?? "",
        "username": auth?.email ?? "",
        "source": Platform.isIOS ? "ios" : "android",
      };

      var body = param;

      if (params != null) {
        body = {...param, ...params};
      }

      return json.encode(body);
    } catch (e) {
      return "";
    }
  }

  @override
  Future<List<SalespersonSchedule>> createSchedules(Map data) async {
    try {
      final response = await apiClient.post(
        'v2/add-schedule',
        body: await getParams(params: data),
      );

      final List<SalespersonSchedule> records = [];
      for (var item in response["records"]) {
        records.add(SalespersonScheduleExtension.fromMap(item));
      }

      return records;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SalespersonSchedule>> getSchedules(String date) async {
    try {
      final response = await apiClient.post(
        'v2/get-schedule',
        body: await getParams(params: {"visit_date": date}),
      );

      final List<SalespersonSchedule> records = [];
      for (var item in response["records"]) {
        records.add(SalespersonScheduleExtension.fromMap(item));
      }

      return records;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isValidApiSession() async {
    try {
      await apiClient.postCheckSession(
        'v2/check-api-session',
        body: await getParams(),
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // @override
  // Future<void> checkApiSession() async {
  //   try {
  //     await apiClient.postCheckSession(
  //       'v2/check-api-session',
  //       body: await getParams(),
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  @override
  Future<void> updateSchedule(
    SalespersonSchedule schedule, {
    String type = kStatusCheckIn,
  }) async {
    try {
      if (type == kStatusCheckIn) {
        await apiClient.postUploadFiles(
          'v2/update-schedule',
          body: await getParams(
            params: {'schedule': jsonEncode(schedule.toJson()), 'type': type},
          ),
          files: schedule.checkInImage != null
              ? [XFile(schedule.checkInImage!)]
              : [],
        );
      } else {
        await apiClient.postUploadFiles(
          'v2/update-schedule',
          body: await getParams(
            params: {'schedule': jsonEncode(schedule.toJson()), 'type': type},
          ),
          files: schedule.checkOutImage != null
              ? [XFile(schedule.checkOutImage!)]
              : [],
        );

        // await apiClient.post(
        //   'v2/update-schedule',
        //   body: await getParams(
        //     params: {'schedule': jsonEncode(schedule.toJson()), 'type': type},
        //   ),
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> downloadAppSetting() async {
    try {
      final response = await apiClient.post(
        'v2/download-app-setting',
        body: await getParams(),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitStockRequest(
    Map<String, dynamic> data,
  ) async {
    try {
      return await apiClient.post(
        'v2/submit-stock-request',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> downloadTranData({
    Map<String, dynamic>? data,
  }) async {
    try {
      return await apiClient.post(
        'v2/download-transaction-data',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> gpsTrackingEntry({required Map<String, dynamic> data}) async {
    try {
      await apiClient.post(
        'v2/tracking-gps-entry',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> processUpload({
    Map<String, dynamic>? data,
  }) async {
    return await apiClient.post(
      'v2/upload-data',
      body: await getParams(params: data),
    );

    try {
      return await apiClient.post(
        'v2/upload-data',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfileUer({
    required Map<String, dynamic> data,
    required XFile? imagePath,
  }) async {
    try {
      return await apiClient.postUploadFiles(
        'v2/update-profile-user',
        body: await getParams(params: data),
        files: (imagePath != null && imagePath.path.isNotEmpty)
            ? [imagePath]
            : [],
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> heartbeatStatus({
    required Map<String, dynamic> data,
  }) async {
    try {
      return await apiClient.post(
        'v2/heartbeat',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCompanyInfo({
    required Map<String, dynamic> data,
  }) async {
    try {
      return await apiClient.post(
        'get-org-info',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }
}
