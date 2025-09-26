import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_helpers.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

part 'sale_order_history_detail_state.dart';

class SaleOrderHistoryDetailCubit extends Cubit<SaleOrderHistoryDetailState> {
  SaleOrderHistoryDetailCubit()
    : super(const SaleOrderHistoryDetailState(isLoading: true));
  final MoreRepository appRepos = getIt<MoreRepository>();

  Future<void> getSaleDetails({required String no}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await appRepos.getSaleDetails(param: {'document_no': no});

      result.fold(
        (failure) => emit(state.copyWith(error: failure.message)),
        (record) => emit(state.copyWith(record: record)),
      );
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    } finally {
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  // void scaningBluetooth(bool isScan) {
  //   emit(state.copyWith(isScanning: isScan));
  // }

  // void setConnectingBluetooth(bool isConnect) {
  //   emit(state.copyWith(isConnected: isConnect));
  // }

  // void setBluetoothAdapterState(BluetoothAdapterState adapter) {
  //   emit(state.copyWith(adapterState: adapter));
  // }

  // void setBluetoothDevice(BluetoothDevice? device) {
  //   emit(state.copyWith(connectedDevice: device));
  // }

  Future<void> getComapyInfo() async {
    final stableState = state;
    try {
      emit(state.copyWith(isLoading: true));
      await Future.delayed(const Duration(milliseconds: 500));
      final result = await appRepos.getCompanyInfo();
      result.fold((l) {}, (record) {
        emit(state.copyWith(isLoading: false, comPanyInfo: record));
      });
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
      emit(stableState.copyWith(isLoading: false));
    }
  }

  void getPreviewReceipt(ReceiptPreview? generated) {
    emit(state.copyWith(preview: generated));
  }
}
