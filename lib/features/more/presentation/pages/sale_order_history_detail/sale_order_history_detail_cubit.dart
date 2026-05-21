import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

part 'sale_order_history_detail_state.dart';

class SaleOrderHistoryDetailCubit extends Cubit<SaleOrderHistoryDetailState>
    with MessageMixin, AppMixin {
  SaleOrderHistoryDetailCubit()
    : super(const SaleOrderHistoryDetailState(isLoading: true));
  final MoreRepository appRepos = getIt<MoreRepository>();

  Future<void> getSaleDetails({
    required String no,
    required String isSync,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await appRepos.getSaleDetails(
        param: {'document_no': no, "isSync": isSync},
      );

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

  Future<List<DevicePrinter>> getPrinterConfig() async {
    final result = await appRepos.getDevicePrinter();
    return result.fold((l) => [], (record) => record);
  }

  Future<void> storeDevicePrinter(DevicePrinter device) async {
    await appRepos.storeDevicePrinter(device);
  } 
}
