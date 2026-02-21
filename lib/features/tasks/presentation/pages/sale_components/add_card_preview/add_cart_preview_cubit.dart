import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/add_card_preview/add_cart_preview_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class AddCartPreviewCubit extends Cubit<AddCartPreviewState> with MessageMixin {
  AddCartPreviewCubit() : super(const AddCartPreviewState(isLoading: true));

  final _taskRepo = getIt<TaskRepository>();

  Future<void> loadInitialData({
    required String scheduleId,
    required String documentType,
  }) async {
    try {
      final saleNo = Helpers.getSaleDocumentNo(
        scheduleId: scheduleId,
        documentType: documentType,
      );

      final header = await _taskRepo.getPosSaleHeader(
        no: saleNo,
        documentType: documentType,
      );

      if (header == null) {
        throw GeneralException("Sale header not found.");
      }

      emit(state.copyWith(
        salesHeader: header,
        scheduleId: scheduleId,
        documentType: documentType,
      ));
    } catch (e) {
      Logger.log('Error loading initial data: $e');
    }
  }

  Future<Item?> getItem(String itemNo) async {
    try {
      final response = await _taskRepo.getItem(param: {'no': itemNo});
      return response.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(item: r));

        return r;
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
      return null;
    } on Exception {
      showErrorMessage();
      return null;
    }
  }

  Future<void> getSchedule(String scheduleId) async {
    try {
      final response = await _taskRepo.getSchedule(param: {'id': scheduleId});
      response.fold(
        (l) => throw GeneralException(l.message),
        (r) => emit(state.copyWith(schedule: r)),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    }
  }

  Future<void> getSaleLines() async {
    try {
      emit(state.copyWith(isLoading: true));

      final saleNo = Helpers.getSaleDocumentNo(
        scheduleId: state.scheduleId,
        documentType: state.documentType,
      );

      final response = await _taskRepo.getPosSaleLines(
        params: {'document_no': saleNo, 'document_type': state.documentType},
      );

      response.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(saleLines: r, isLoading: false));

        _getItems(r);
        _calculateSummery();
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
      emit(state.copyWith(isLoading: false));
    }
  }

  void _calculateSummery() {
    final lines = state.saleLines;

    double totalAmount = lines.fold(0.0, (sum, line) {
      return sum + Helpers.toDouble(line.amountIncludingVat);
    });

    double subTotalAmt = lines.fold(0.0, (sum, line) {
      return sum +
          (Helpers.toDouble(line.quantity) * Helpers.toDouble(line.unitPrice));
    });

    double totalVatAmt = lines.fold(0.0, (sum, line) {
      return sum + Helpers.toDouble(line.vatAmount);
    });

    double totalDiscountAmt = lines.fold(0.0, (sum, line) {
      final subTotal =
          Helpers.toDouble(line.quantity) * Helpers.toDouble(line.unitPrice);
      final disAmt =
          subTotal * (Helpers.toDouble(line.discountPercentage) / 100);

      return sum + Helpers.toDouble(line.discountAmount) + disAmt;
    });

    emit(
      state.copyWith(
        totalAmt: totalAmount,
        subTotalAmt: subTotalAmt,
        totalTaxAmt: totalVatAmt,
        totalDiscountAmt: totalDiscountAmt,
        isLoading: false,
      ),
    );
  }

  void _getItems(List<PosSalesLine> r) async {
    final filterItemNo = r.map((e) => '"${e.no}"').toList();
    await _taskRepo
        .getItems(param: {'no': 'IN {${filterItemNo.join(",")}}'})
        .then((response) {
          response.fold((l) {}, (r) => emit(state.copyWith(items: r)));
        });
  }

  Future<void> deletedLine(PosSalesLine line) async {
    try {
      final String headerNo = line.documentNo ?? "";
      final List<PosSalesLine> posSalesLines = List.from(state.saleLines);

      final remainingLines = posSalesLines;

      remainingLines.removeWhere((e) => e.id == line.id);

      final response = await _taskRepo.deletedPosSaleLine(line);

      response.fold(
        (l) {
          emit(state.copyWith(saleLines: posSalesLines, isLoading: false));

          throw GeneralException(l.message);
        },
        (r) {
          if (remainingLines.isEmpty) {
            _taskRepo.deletedPosSaleHeader(headerNo);

            emit(state.copyWith(saleLines: remainingLines, isLoading: false));

            _calculateSummery();
          } else {
            getSaleLines();
          }
        },
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getCustomer(String no) async {
    try {
      final response = await _taskRepo.getCustomer(no: no);

      response.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(customer: r));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getCustomerLedgerEntry(String customerNo) async {
    try {
      final response = await _taskRepo.getCustomerLedgerEntry(
        param: {"customer_no": customerNo},
      );

      response.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(customerLedgerEntries: r));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void setCreditLimitText([String text = ""]) {
    emit(state.copyWith(creditLimitText: text));
  }
}
