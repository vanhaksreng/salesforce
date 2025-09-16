part of 'sale_order_history_detail_cubit.dart';

class SaleOrderHistoryDetailState {
  final bool isLoading;
  final String? error;
  final SaleDetail? record;
  // final bool isScanning;
  // final bool isConnected;
  // final BluetoothAdapterState adapterState;
  // final BluetoothDevice? connectedDevice;
  final CompanyInformation? comPanyInfo;

  const SaleOrderHistoryDetailState({
    this.isLoading = false,
    // this.isScanning = false,
    // this.isConnected = false,
    this.error,
    this.record,
    // this.adapterState = BluetoothAdapterState.unknown,
    // this.connectedDevice,
    this.comPanyInfo,
  });

  SaleOrderHistoryDetailState copyWith({
    bool? isLoading,

    String? error,
    SaleDetail? record,
    // bool? isScanning,
    // bool? isConnected,
    // BluetoothAdapterState? adapterState,
    // BluetoothDevice? connectedDevice,
    CompanyInformation? comPanyInfo,
  }) {
    return SaleOrderHistoryDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      record: record ?? this.record,
      // isScanning: isScanning ?? this.isScanning,
      // isConnected: isConnected ?? this.isConnected,
      // adapterState: adapterState ?? this.adapterState,
      // connectedDevice: connectedDevice ?? this.connectedDevice,
      comPanyInfo: comPanyInfo ?? this.comPanyInfo,
    );
  }
}
