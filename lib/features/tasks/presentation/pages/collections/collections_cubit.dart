import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/download_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/collections_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CollectionsCubit extends Cubit<CollectionsState>
    with MessageMixin, DownloadMixin, AppMixin {
  CollectionsCubit() : super(const CollectionsState(isLoading: true));
  final _taskRepos = getIt<TaskRepository>();

  Future<void> getCustomerLedgerEntry({Map<String, dynamic>? param}) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await _taskRepos.getCustomerLedgerEntry(param: param);
      return response.fold((l) => throw GeneralException(l.message), (items) {
        emit(state.copyWith(cusLedgerEntry: items, isLoading: false));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getCashReceiptJournals({Map<String, dynamic>? param}) async {
    try {
      final response = await _taskRepos.getCashReceiptJournals(param: param);
      return response.fold((l) => throw GeneralException(l.message), (items) {
        emit(state.copyWith(casReJounals: items, isLoading: false));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> processCashReceiptJournals() async {
    try {
      final journals = List<CashReceiptJournals>.from(
        state.casReJounals,
      ).where((journal) => journal.status == kStatusOpen).toList();

      if (journals.isEmpty) {
        showWarningMessage("No transaction to submit!");
        return;
      }

      final response = await _taskRepos.processCashReceiptJournals(journals);
      return response.fold((l) => throw GeneralException(l.message), (
        journals,
      ) {
        emit(state.copyWith(casReJounals: journals, isLoading: false));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
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
