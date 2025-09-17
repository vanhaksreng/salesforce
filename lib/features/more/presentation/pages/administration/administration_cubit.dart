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

  // bool isConnection() {
  //   final blueDevice = state.bluetoothDevice;
  //   // If we have a device, check connection state from Cubit
  //   return blueDevice != null &&
  //       state.bluetoothDevice == blueDevice.isConnected;
  // }
}
