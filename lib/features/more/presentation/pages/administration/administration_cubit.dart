import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:salesforce/features/more/domain/entities/device_info.dart';
import 'package:salesforce/features/more/presentation/pages/administration/administration_state.dart';

class AdministrationCubit extends Cubit<AdministrationState> {
  AdministrationCubit() : super(AdministrationState(isLoading: true));

  Future<void> checkInforDevice() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    emit(
      state.copyWith(
        deviceInfo: DeviceInfo(
          appName: packageInfo.appName,
          packageName: packageInfo.packageName,
          version: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
        ),
        isLoading: false,
      ),
    );
  }

  void checkBluetoothDevie(List<BluetoothDevice> devices) {
    if (devices.isEmpty) return;

    emit(state.copyWith(bluetoothDevice: devices.first));
  }

  Future<void> checkIminDevice(DeviceInfoPlugin deviceInfo) async {
    if (!Platform.isAndroid) return;

    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final model = (androidInfo.model ?? "").toLowerCase();

    if (model.contains("m2-202") ||
        model.contains("m2-203") ||
        model.contains("m2 pro")) {
      emit(state.copyWith(isIminDevice: true));
    } else {
      emit(state.copyWith(isIminDevice: false));
    }
  }
}
