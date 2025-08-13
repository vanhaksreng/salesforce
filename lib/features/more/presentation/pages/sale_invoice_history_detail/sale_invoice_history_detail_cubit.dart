import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/injection_container.dart';

part 'sale_invoice_history_detail_state.dart';

class SaleInvoiceHistoryDetailCubit extends Cubit<SaleInvoiceHistoryDetailState> {
  SaleInvoiceHistoryDetailCubit() : super(const SaleInvoiceHistoryDetailState(isLoading: true));
  final MoreRepository appRepos = getIt<MoreRepository>();

  Future<void> getSaleDetails({required String no}) async {
    try {
      emit(state.copyWith(isLoading: true));

      final result = await appRepos.getSaleDetails(param: {'document_no': no});
      result.fold((l) {}, (record) {
        emit(state.copyWith(isLoading: false, record: record));
      });
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }
}
