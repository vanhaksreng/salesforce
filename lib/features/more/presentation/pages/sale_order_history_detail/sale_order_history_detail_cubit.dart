import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

part 'sale_order_history_detail_state.dart';

class SaleOrderHistoryDetailCubit extends Cubit<SaleOrderHistoryDetailState> {
  SaleOrderHistoryDetailCubit() : super(const SaleOrderHistoryDetailState());
  final MoreRepository appRepos = getIt<MoreRepository>();

  Future<void> getSaleDetails({required String no}) async {
    final stableState = state;
    try {
      emit(state.copyWith(isLoading: true));

      final result = await appRepos.getSaleDetails(param: {'document_no': no});
      result.fold((l) {}, (record) {
        emit(state.copyWith(isLoading: false, record: record));
      });
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
      emit(stableState.copyWith(isLoading: false));
    }
  }

  void scaningBluetooth(bool isScan) {
    emit(state.copyWith(isScanning: isScan));
  }

  void setConnectingBluetooth(bool isConnect) {
    emit(state.copyWith(isConnected: isConnect));
  }

  void setBluetoothAdapterState(BluetoothAdapterState adapter) {
    emit(state.copyWith(adapterState: adapter));
  }

  void setBluetoothDevice(BluetoothDevice? device) {
    emit(state.copyWith(connectedDevice: device));
  }

  Future<void> getComapyInfo() async {
    final stableState = state;
    try {
      emit(state.copyWith(isLoading: true));

      final result = await appRepos.getCompanyInfo();
      result.fold((l) {}, (record) {
        print("============${record?.logo128}");
        emit(state.copyWith(isLoading: false, comPanyInfo: record));
      });
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
      emit(stableState.copyWith(isLoading: false));
    }
  }
}
