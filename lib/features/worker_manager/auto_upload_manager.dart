import 'dart:async';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_cubit.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';

class AutoUploadManager with MessageMixin {
  static const _periodicTaskId = "autoUploadTask";
  static const _taskName = "uploadPendingData";

  static Future<void> initialize() async {
    await _registerPeriodicUploadTask();
  }

  static Future<void> _registerPeriodicUploadTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        _periodicTaskId,
        _taskName,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(seconds: 5),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        inputData: {"triggeredBy": "auto"},
        constraints: Constraints(
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          networkType: NetworkType.connected,
        ),
      );
    } catch (e) {
      if (!kReleaseMode) {
        Helpers.showMessage(msg: 'Failed to register upload task: $e');
      }
    }
  }

  static Future<bool> handleTask(
    String taskName,
    Map<String, dynamic>? inputData,
  ) async {
    try {
      if (taskName == _taskName || taskName == Workmanager.iOSBackgroundTask) {
        final uploadCubit = UploadCubit();
        await uploadCubit.loadInitialData(DateTime.now());

        await uploadCubit.processUpload();
        Logger.log("====================================Upload Successfully!");
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
