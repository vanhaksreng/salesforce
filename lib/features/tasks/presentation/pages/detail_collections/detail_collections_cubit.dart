import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/detail_collections/detail_collections_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class DetailCollectionsCubit extends Cubit<DetailCollectionsState> with MessageMixin {
  DetailCollectionsCubit() : super(const DetailCollectionsState(isLoading: true));

  final _taskRepos = getIt<TaskRepository>();

  Future<void> getCashReceiptJournals({Map<String, dynamic>? param}) async {
    try {
      final response = await _taskRepos.getCashReceiptJournals(param: param);
      return response.fold((l) => throw GeneralException(l.message), (journals) {
        final totalAmt = journals.fold(0.0, (sum, journal) {
          return sum + Helpers.toDouble(journal.amountLcy);
        });

        emit(state.copyWith(cashReceiptJournals: journals, totalReceiveAmt: totalAmt, isLoading: false));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> processPayment(PaymentArg arg) async {
    final response = await _taskRepos.processPayment(arg: arg);
    return response.fold((l) => throw GeneralException(l.message), (journal) {
      state.cashReceiptJournals.add(journal);

      final totalAmt = state.cashReceiptJournals.fold(0.0, (sum, journal) {
        return sum + Helpers.toDouble(journal.amountLcy);
      });

      emit(state.copyWith(totalReceiveAmt: totalAmt));
    });
  }

  Future<void> deletedPayment(CashReceiptJournals journal, CustomerLedgerEntry cEntry) async {
    final oldJournal = List<CashReceiptJournals>.from(state.cashReceiptJournals);
    try {
      final List<CashReceiptJournals> newJouranl = oldJournal;
      newJouranl.removeWhere((e) => e.id == journal.id);

      final response = await _taskRepos.deletedPayment(journal, cEntry);
      return response.fold((l) => throw GeneralException(l.message), (journal) {
        final totalAmt = newJouranl.fold(0.0, (sum, journal) {
          return sum + Helpers.toDouble(journal.amountLcy);
        });

        emit(state.copyWith(cashReceiptJournals: newJouranl, totalReceiveAmt: totalAmt));
        showSuccessMessage("Payment line have been removed");
      });
    } on GeneralException catch (e) {
      emit(state.copyWith(cashReceiptJournals: oldJournal));
      showWarningMessage(e.message);
    } on Exception {
      emit(state.copyWith(cashReceiptJournals: oldJournal));
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getPaymentType({Map<String, dynamic>? param}) async {
    try {
      final response = await _taskRepos.getPaymentType(param: param);
      return response.fold((l) => throw GeneralException(l.message), (items) {
        emit(state.copyWith(paymentMethods: items, isLoading: false));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
