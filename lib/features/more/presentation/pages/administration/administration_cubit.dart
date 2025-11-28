import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/entities/device_info.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/administration/administration_state.dart';
import 'package:salesforce/features/more/presentation/pages/administration/bletooth_printer_service.dart';
import 'package:salesforce/features/more/presentation/pages/administration/device_printer_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

class AdministrationCubit extends Cubit<AdministrationState>
    with MessageMixin, DevicePrinterMixin {
  AdministrationCubit() : super(AdministrationState(isLoading: true));
  final _repos = getIt<MoreRepository>();
  final _bluetoothService = BluetoothPrinterService();
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _statusSubscription;

  void getDiscoverPrinter(List<PrinterDeviceDiscover> devices) {
    emit(state.copyWith(printerDeviceDiscover: devices));
  }

  Future<void> startScanning({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        state.lastScanTime != null &&
        DateTime.now().difference(state.lastScanTime!) < Duration(minutes: 5)) {
      return;
    }

    emit(state.copyWith(isScanning: true));

    try {
      final devices = await ThermalPrinter.discoverPrinters(
        type: ConnectionType.bluetooth,
      );

      emit(
        state.copyWith(
          isScanning: false,
          printerDeviceDiscover: devices,
          lastScanTime: DateTime.now(),
        ),
      );

      if (devices.isEmpty) {
        showErrorMessage("No devices found");
      }
    } catch (error) {
      emit(state.copyWith(isScanning: false, error: error.toString()));
      showErrorMessage("Failed to scan: ${error.toString()}");
    }
  }

  Future<bool> storeDevicePrinter({required DevicePrinter device}) async {
    emit(state.copyWith(isLoading: true));

    try {
      final result = await _repos.storeDevicePrinter(device);

      return result.fold(
        (failure) {
          showErrorMessage(failure.message);
          emit(state.copyWith(isLoading: false));
          return false;
        },
        (records) {
          final updatedList = [...state.devicePrinter, device];

          emit(state.copyWith(isLoading: false, devicePrinter: updatedList));
          return true;
        },
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
      return false;
    }
  }

  Future<bool> deletePrinter({required DevicePrinter device}) async {
    final updatedList = List<DevicePrinter>.from(state.devicePrinter);
    final List<DevicePrinter> data = updatedList
      ..removeWhere((e) => e.macAddress == device.macAddress);
    emit(state.copyWith(devicePrinter: data));

    try {
      emit(state.copyWith(isLoading: true));

      final result = await _repos.deletePrinter(device: device);

      return result.fold(
        (failure) {
          showErrorMessage(failure.message);
          emit(state.copyWith(isLoading: false));
          return false;
        },
        (_) {
          emit(state.copyWith(devicePrinter: updatedList, isLoading: false));

          return true;
        },
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false));
      return false;
    }
  }

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));

    // Listen to connection changes from the service
    _connectionSubscription = _bluetoothService.connectionStream.listen((
      device,
    ) {
      emit(state.copyWith(selectedDevice: device));
    });

    _statusSubscription = _bluetoothService.statusStream.listen((status) {
      if (status == ConnectionStatus.connecting) {
        // Optional: show connecting state
      } else if (status == ConnectionStatus.connected) {
        // Optional: show connected state
      }
    });

    try {
      // Initialize the bluetooth service (will auto-reconnect if saved)
      await _bluetoothService.initialize();

      // Load saved devices
      await getDevicePrinter();

      // Update state with current connection
      emit(
        state.copyWith(
          selectedDevice: _bluetoothService.connectedDevice,
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  // Future<void> connectToPrinter(DevicePrinter device) async {
  //   emit(state.copyWith(connectingDeviceId: device.macAddress));

  //   try {
  //     final result = await _bluetoothService.connect(device);

  //     if (result) {
  //       emit(
  //         state.copyWith(
  //           selectedDevice: device,
  //           clearConnectingDeviceId: true,
  //           isLoading: false,
  //         ),
  //       );
  //       showSuccessMessage("Connected to ${device.deviceName}");
  //     } else {
  //       emit(state.copyWith(clearConnectingDeviceId: true, isLoading: false));
  //       showErrorMessage("Failed to connect");
  //     }
  //   } catch (error) {
  //     emit(state.copyWith(clearConnectingDeviceId: true, isLoading: false));
  //     showErrorMessage("Connection error: ${error.toString()}");
  //   }
  // }

  Future<void> disconnectFromPrinter(DevicePrinter device) async {
    try {
      final result = await _bluetoothService.disconnect();

      if (result) {
        emit(state.copyWith(clearSelectedDevice: true, isLoading: false));
        showSuccessMessage("Disconnected from ${device.deviceName}");
      } else {
        emit(state.copyWith(isLoading: false));
        showErrorMessage("Failed to disconnect");
      }
    } catch (error) {
      emit(state.copyWith(isLoading: false));
      showErrorMessage("Disconnection error: ${error.toString()}");
    }
  }

  // Future<void> getDevicePrinter({
  //   Map<String, dynamic>? params,
  //   int page = 1,
  //   bool append = false,
  // }) async {
  //   try {
  //     if (append) {
  //       emit(state.copyWith(isFetching: true, isLoading: false));
  //     }

  //     final result = await _repos.getDevicePrinter();

  //     result.fold((l) => throw Exception(), (records) {
  //       emit(
  //         state.copyWith(
  //           isLoading: false,
  //           isFetching: false,
  //           devicePrinter: records,
  //         ),
  //       );
  //     });
  //   } catch (error) {
  //     emit(state.copyWith(isLoading: false, error: error.toString()));
  //   }
  // }

  // Future<void> initialize() async {
  //   emit(state.copyWith(isLoading: true));

  //   try {
  //     final savedPrinter = await loadSelectedPrinter();

  //     await getDevicePrinter();

  //     if (savedPrinter != null) {
  //       emit(state.copyWith(selectedDevice: savedPrinter, isLoading: false));
  //       await _attemptReconnect(savedPrinter);
  //     } else {
  //       emit(state.copyWith(isLoading: false));
  //     }
  //   } catch (error) {
  //     emit(state.copyWith(isLoading: false));
  //   }
  // }

  // Future<void> _attemptReconnect(DevicePrinter device) async {
  //   try {
  //     final result = await ThermalPrinter.connect(
  //       PrinterDeviceDiscover(
  //         address: device.macAddress,
  //         name: device.originDeviceName,
  //         type: device.typeConnection == "bluetooth"
  //             ? ConnectionType.bluetooth
  //             : ConnectionType.usb,
  //       ),
  //     );

  //     if (result) {
  //       emit(state.copyWith(selectedDevice: device));
  //     } else {
  //       await clearSelectedPrinter();
  //       emit(state.copyWith(clearSelectedDevice: true));
  //     }
  //   } catch (error) {
  //     await clearSelectedPrinter();
  //     emit(state.copyWith(clearSelectedDevice: true));
  //   }
  // }

  // Future<void> saveSelectedPrinter(DevicePrinter device) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final deviceMap = device.toMap();
  //     final deviceJson = jsonEncode(deviceMap);
  //     await prefs.setString('selected_printer', deviceJson);
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  Future<void> connectToPrinter(DevicePrinter device) async {
    emit(state.copyWith(connectingDeviceId: device.macAddress));
    try {
      bool result = await _bluetoothService.connect(device);

      if (result) {
        emit(
          state.copyWith(
            selectedDevice: device,
            clearConnectingDeviceId: true, // Clear connecting state
            isLoading: false,
          ),
        );
        showSuccessMessage("Connected to ${device.deviceName}");
      } else {
        emit(state.copyWith(clearConnectingDeviceId: true, isLoading: false));
        showErrorMessage("Failed to connect");
      }
    } catch (error) {
      emit(state.copyWith(clearConnectingDeviceId: true, isLoading: false));
      showErrorMessage("Connection error: ${error.toString()}");
    }
  }

  // Future<void> disconnectFromPrinter(DevicePrinter device) async {
  //   try {
  //     final result = await ThermalPrinter.disconnect();

  //     if (result) {
  //       await clearSelectedPrinter();

  //       // Use the clearSelectedDevice flag
  //       emit(state.copyWith(clearSelectedDevice: true, isLoading: false));
  //       showSuccessMessage("Disconnected from ${device.deviceName}");
  //     } else {
  //       emit(state.copyWith(isLoading: false));
  //       showErrorMessage("Failed to disconnect");
  //     }
  //   } catch (error) {
  //     emit(state.copyWith(isLoading: false));
  //     showErrorMessage("Disconnection error: ${error.toString()}");
  //   }
  // }

  //  Future<bool> deletePrinter(DevicePrinter device)async{

  //  }

  Future<void> getDevicePrinter({
    Map<String, dynamic>? params,
    int page = 1,
    bool append = false,
  }) async {
    try {
      if (append) {
        emit(state.copyWith(isFetching: true, isLoading: false));
      }

      final result = await _repos.getDevicePrinter();

      result.fold((l) => throw Exception(), (records) {
        emit(
          state.copyWith(
            isLoading: false,
            isFetching: false,
            devicePrinter: records,
          ),
        );
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

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

  // void checkBluetoothDevie(BluetoothInfo? devices) {
  //   if (devices == null) return;

  //   emit(state.copyWith(bluetoothDevice: devices));
  // }

  Future<void> checkIminDevice(DeviceInfoPlugin deviceInfo) async {
    if (!Platform.isAndroid) return;

    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final model = (androidInfo.model).toLowerCase();

    if (model.contains("m2-202") ||
        model.contains("m2-203") ||
        model.contains("m2 pro")) {
      emit(state.copyWith(isIminDevice: true));
    } else {
      emit(state.copyWith(isIminDevice: false));
    }
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    _statusSubscription?.cancel();
    return super.close();
  }
}
