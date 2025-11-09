import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/more/presentation/pages/invoice_printer/invoice_printer_state.dart';

class InvoicePrinterCubit extends Cubit<InvoicePrinterState> {
  InvoicePrinterCubit() : super(InvoicePrinterState(isLoading: true));

  Future<void> loadInitialData() async {
    final stableState = state;
    try {
      emit(state.copyWith(isLoading: true));

      // TODO your code here

      emit(state.copyWith(isLoading: false));
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
      emit(stableState.copyWith(isLoading: false));
    }
  }
}
