import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/stock/domain/repositories/stock_repository.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_request/stock_request_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class StockRequestCubit extends Cubit<StockRequestState> with MessageMixin {
  StockRequestCubit() : super(const StockRequestState(isLoading: true));

  final StockRepository repos = getIt<StockRepository>();

  Future<void> getItemWorkSheets({Map<String, dynamic>? param}) async {
    try {
      final response = await repos.getItemRequestWorksheets(param: param);
      response.fold(
        (l) => throw GeneralException(l.message),
        (r) => emit(state.copyWith(isLoading: false, itemWorkSheet: r.records, headerStatus: r.headerSatatus)),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> submitStockRequest() async {
    try {
      final records = state.itemWorkSheet;
      if (records.isEmpty) {
        throw Exception("No items to submit. Please add items first.");
      }

      final response = await repos.submitStockRequest(records);
      response.fold((l) => throw GeneralException(l.message), (r) {
        showSuccessMessage("Your request has been submitted successfully");
        emit(
          state.copyWith(
            documentNo: r.records.first.documentNo,
            itemWorkSheet: r.records,
            headerStatus: r.headerSatatus,
          ),
        );
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteWorksheetItems(String itemNo) async {
    final ows = List<ItemStockRequestWorkSheet>.from(state.itemWorkSheet);

    try {
      final ws = List<ItemStockRequestWorkSheet>.from(ows);
      ws.removeWhere((item) => item.itemNo == itemNo);

      emit(state.copyWith(itemWorkSheet: ws));

      final response = await repos.deleteStockRequest(itemNo);
      response.fold((l) {
        showErrorMessage(l.message);
        emit(state.copyWith(itemWorkSheet: ows));
      }, (_) => showSuccessMessage("Item removed successfully"));
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> receiveStockRequest() async {
    try {
      List<ItemStockRequestWorkSheet> ows = state.itemWorkSheet;
      final response = await repos.receiveStockRequest();
      response.fold((l) => throw GeneralException(l.message), (r) {
        for (var record in r.records) {
          final index = ows.indexWhere((e) => e.id == record.id);
          if (index == -1) {
            ows[index] = record;
          }
        }

        emit(state.copyWith(isLoading: false, itemWorkSheet: ows, headerStatus: r.headerSatatus));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> cancelStockRequest() async {
    try {
      final response = await repos.cancelStockRequest();
      response.fold(
        (l) => throw GeneralException(l.message),
        (r) => emit(state.copyWith(isLoading: false, itemWorkSheet: r.records, headerStatus: r.headerSatatus)),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> onChangeReceiveQty(double qty, ItemStockRequestWorkSheet record) async {
    try {
      List<ItemStockRequestWorkSheet> ows = state.itemWorkSheet;
      final response = await repos.onChangeReceiveQty(quantityToReceive: qty, record: record);

      response.fold((l) => throw GeneralException(l.message), (result) {
        final index = ows.indexWhere((e) => e.id == result.id);
        if (index == -1) {
          ows[index] = record;
        }

        emit(state.copyWith(isLoading: false, itemWorkSheet: ows));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
