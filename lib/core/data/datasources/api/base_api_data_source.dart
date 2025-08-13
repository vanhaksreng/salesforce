import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

abstract class BaseApiDataSource {
  Future<bool> isValidApiSession();
  Future<void> checkApiSession();
  Future<List<SalespersonSchedule>> createSchedules(Map data);
  Future<List<SalespersonSchedule>> getSchedules(String data);
  Future<void> updateSchedule(SalespersonSchedule schedule, {String type = kStatusCheckIn});

  Future<Map<String, dynamic>> downloadTranData({Map<String, dynamic>? data});
  Future<Map<String, dynamic>> downloadAppSetting();
  Future<void> gpsTrackingEntry({required Map<String, dynamic> data});

  Future<Map<String, dynamic>> processUpload({Map<String, dynamic>? data});

  Future<void> updateProfileUer({required Map<String, dynamic> data, required XFile? imagePath});

  Future<Map<String, dynamic>> heartbeatStatus({required Map<String, dynamic> data});
}
