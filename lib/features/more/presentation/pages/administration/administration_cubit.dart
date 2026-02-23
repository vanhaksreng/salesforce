import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/entities/device_info.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/administration/administration_state.dart';
import 'package:salesforce/features/more/presentation/pages/administration/bletooth_printer_service.dart';
import 'package:salesforce/features/more/presentation/pages/administration/device_printer_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/bluetooth_page/bluetooth_permission_handler.dart';
import 'package:salesforce/features/more/presentation/pages/imin_device/imin_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

class AdministrationCubit extends Cubit<AdministrationState>
    with MessageMixin, DevicePrinterMixin, IminPrinterMixin {
  AdministrationCubit() : super(AdministrationState(isLoading: true));
  final _repos = getIt<MoreRepository>();
  final _bluetoothService = BluetoothPrinterService();
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _statusSubscription;
  final _bluetoothPermission = BluetoothPermissionHandler();

  Future<void> checkPermission() async {
    final hasPermission = await _bluetoothPermission.hasPermissions();
    emit(state.copyWith(hasPermission: hasPermission));
  }

  Future<void> checkBluetoothStatus() async {
    final status = await _bluetoothPermission.getBluetoothStatus();
    emit(state.copyWith(status: status));

    debugPrint('Bluetooth Status: $status');
  }

  void checkListenIOSBluetooth() {
    _bluetoothPermission.onBluetoothStateChanged = (isEnabled) {
      debugPrint('Bluetooth state changed: $isEnabled');
      checkBluetoothStatus();
    };
  }

  void getDiscoverPrinter(List<PrinterDeviceDiscover> devices) {
    emit(state.copyWith(printerDeviceDiscover: devices));
  }

  Future<void> startScanning(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    final isReady = await _bluetoothPermission.ensureBluetoothReady();
    if (!context.mounted) return;
    if (!isReady) {
      if (Platform.isIOS) {
        Helpers.showDialogAction(
          context,
          labelAction: "Bluetooth Required",
          canCancel: false,
          subtitle: 'Please enable Bluetooth in Settings to use the printer.',
          confirmText: 'Open Settings',
          confirm: () async {
            Navigator.pop(context);
            await _bluetoothPermission.openBluetoothSettings();
          },
        );
      } else {
        showErrorMessage("Please enable Bluetooth to continue");
      }

      return;
    }
    await checkBluetoothStatus();
    emit(state.copyWith(hasPermission: true));
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

    try {
      if (state.isIminDevice) {
        bool initialized = false;
        int attempts = 0;

        while (!initialized && attempts < 3) {
          attempts++;

          try {
            await initializeIminPrinter();

            await Future.delayed(Duration(seconds: 3));

            final status = await checkIminPrinterStatus(showMessage: false);

            if (status != null) {
              final statusCode = status['status'] as int;
              if (statusCode == 0 || statusCode == -1) {
                initialized = true;
                debugPrint(" iMin printer initialized successfully");
              } else {
                debugPrint("Printer status: ${status['message']}, retrying...");
                await Future.delayed(Duration(seconds: 2));
              }
            }
          } catch (e) {
            debugPrint("Initialization attempt $attempts failed: $e");
            if (attempts < 3) {
              await Future.delayed(Duration(seconds: 2));
            }
          }
        }

        if (!initialized) {
          showErrorMessage(
            "Failed to initialize printer after $attempts attempts",
          );
        }

        emit(state.copyWith(isLoading: false));
      } else {
        debugPrint("📱 Non-iMin device - initializing Bluetooth printer");

        // Listen to connection changes from the Bluetooth service
        _connectionSubscription = _bluetoothService.connectionStream.listen((
          device,
        ) {
          emit(state.copyWith(selectedDevice: device));
        });

        _statusSubscription = _bluetoothService.statusStream.listen((status) {
          if (status == ConnectionStatus.connecting) {
            debugPrint(" Bluetooth printer connecting...");
          } else if (status == ConnectionStatus.connected) {
            debugPrint(" Bluetooth printer connected");
          } else if (status == ConnectionStatus.disconnected) {
            debugPrint(" Bluetooth printer disconnected");
          }
        });

        // Initialize the bluetooth service (will auto-reconnect if saved)
        await _bluetoothService.initialize();

        // Load saved devices
        await getDevicePrinter();

        emit(
          state.copyWith(
            selectedDevice: _bluetoothService.connectedDevice,
            isLoading: false,
          ),
        );
      }
    } catch (error) {
      debugPrint("Initialization error: $error");
      emit(state.copyWith(isLoading: false));
      showErrorMessage("Initialization failed: ${error.toString()}");
    }
  }

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

  Future<void> connectToPrinter(DevicePrinter device) async {
    try {
      final granted = await _bluetoothPermission.ensurePermissions();
      if (!granted) {
        showSuccessMessage("Bluetooth permission is required");
        return;
      }
      emit(
        state.copyWith(
          connectingDeviceId: device.macAddress,
          hasPermission: true,
        ),
      );

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

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    _statusSubscription?.cancel();
    return super.close();
  }

  Future<bool> checkImin() async {
    if (await checkIminDevice()) {
      emit(state.copyWith(isIminDevice: true));
      return true;
    }
    emit(state.copyWith(isIminDevice: false));
    return false;
  }

  Future<void> printReceiptWithImin(String receiptContent) async {
    emit(state.copyWith(isLoading: true));

    try {
      final success = await printWithImin(receiptContent);
      emit(state.copyWith(isLoading: false));

      if (!success) {
        // Handle print failure
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      showErrorMessage("Print failed: ${e.toString()}");
    }
  }

  /// Test iMin printer
  Future<void> testIminPrinter() async {
    emit(state.copyWith(isLoading: true));
    await printIminTestReceipt();
    emit(state.copyWith(isLoading: false));
  }
}
