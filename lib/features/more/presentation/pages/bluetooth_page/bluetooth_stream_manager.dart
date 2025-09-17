import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothStreamManager {
  final Function(BluetoothAdapterState) onAdapterStateChange;
  final Function(bool) onScanStateChange;
  final Function(List<ScanResult>) onScanResults;
  final Function(String) onError;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<bool>? _scanningStateSubscription;

  BluetoothStreamManager({
    required this.onAdapterStateChange,
    required this.onScanStateChange,
    required this.onScanResults,
    required this.onError,
  });

  void setupStreams() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen(
      onAdapterStateChange,
      onError: (error) => onError('Adapter state error: $error'),
    );

    _scanningStateSubscription = FlutterBluePlus.isScanning.listen(
      onScanStateChange,
      onError: (error) => onError('Scanning state error: $error'),
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      onScanResults(results);
    }, onError: (error) => onError('Scan error: $error'));
  }

  void dispose() {
    _scanSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _scanningStateSubscription?.cancel();
  }
}
