part of 'sale_order_history_detail_cubit.dart';

class SaleOrderHistoryDetailState {
  final bool isLoading;
  final String? error;
  final SaleDetail? record;
  final bool isScanning;
  final bool isConnected;
  final BluetoothAdapterState adapterState;
  final BluetoothDevice? connectedDevice;

  const SaleOrderHistoryDetailState({
    this.isLoading = false,
    this.isScanning = false,
    this.isConnected = false,
    this.error,
    this.record,
    this.adapterState = BluetoothAdapterState.unknown,
    this.connectedDevice,
  });

  SaleOrderHistoryDetailState copyWith({
    bool? isLoading,
    bool? isScanning,
    bool? isConnected,
    String? error,
    SaleDetail? record,
    BluetoothAdapterState? adapterState,
    BluetoothDevice? connectedDevice,
  }) {
    return SaleOrderHistoryDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      record: record ?? this.record,
      isScanning: isScanning ?? this.isScanning,
      isConnected: isConnected ?? this.isConnected,
      adapterState: adapterState ?? this.adapterState,
      connectedDevice: connectedDevice ?? this.connectedDevice,
    );
  }
}
