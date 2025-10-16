import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_state.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class UploadCubit extends Cubit<UploadState> with MessageMixin {
  UploadCubit() : super(const UploadState(isLoading: true));

  final _taskRepo = getIt.get<TaskRepository>();
  final _moreRepo = getIt.get<MoreRepository>();

  // Public Methods
  Future<void> processUpload() async {
    final uploadTasks = [
      if (state.salesHeaders.isNotEmpty) _processUploadSale(),
      if (state.cashReceiptJournals.isNotEmpty) _processUploadCollection(),
      if (state.customerItemLedgerEntries.isNotEmpty)
        _processUploadCheckStock(),
      if (state.competitorItemLedgerEntries.isNotEmpty)
        _processUploadCompetitorCheckStock(),
      if (state.merchandiseSchedules.isNotEmpty)
        _processUploadMerchandiseAndPosm(),
      if (state.redemptions.isNotEmpty) _processUploadRedemptions(),
      if (state.salespersonSchedules.isNotEmpty) _processUploadSchedules(),

      _gpsTracking(),
      _gpsRouteTracking(),
    ];

    //TODO : competitor promotion
    // Redemption

    await Future.wait(uploadTasks);
  }

  Future<void> loadInitialData(DateTime date) async {
    try {
      print("======init=======fasdasdf}");
      emit(state.copyWith(isLoading: true));

      await _loadCustomerItemLedgerEntries();
      await _loadSalesData();
      await _loadSalesLines();
      await _loadCashReceiptJournals();
      await _loadSalespersonSchedules(DateTime.now());
      await _loadCompetitorItemLedgerEntries();
      await _loadMerchandiseSchedules();
      await _loadRedeptionEntries();
    } catch (e) {
      print("=====================${e.toString()}");
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // Private Upload Methods
  Future<void> _processUploadRedemptions() async {
    final response = await _moreRepo.processUploadRedemptions(
      records: state.redemptions,
    );

    response.fold(
      (failure) => showErrorMessage(failure.message),
      (_) => emit(state.copyWith(redemptions: [])),
    );
  }

  Future<void> _processUploadSale() async {
    final response = await _moreRepo.processUploadSale(
      salesHeaders: state.salesHeaders,
      salesLines: state.salesLines,
    );

    response.fold(
      (failure) => showErrorMessage(failure.message),
      (_) => emit(state.copyWith(salesHeaders: [])),
    );
  }

  Future<void> _processUploadCollection() async {
    final response = await _moreRepo.processUploadCollection(
      records: state.cashReceiptJournals,
    );

    response.fold(
      (failure) => showErrorMessage(failure.message),
      (_) => emit(state.copyWith(cashReceiptJournals: [])),
    );
  }

  Future<void> _processUploadCheckStock() async {
    final response = await _moreRepo.processUploadCheckStock(
      records: state.customerItemLedgerEntries,
    );

    response.fold(
      (failure) => showErrorMessage(failure.message),
      (_) => emit(state.copyWith(customerItemLedgerEntries: [])),
    );
  }

  Future<void> _processUploadCompetitorCheckStock() async {
    final response = await _moreRepo.processUploadCompetitorCheckStock(
      records: state.competitorItemLedgerEntries,
    );

    response.fold(
      (failure) => showErrorMessage(failure.message),
      (_) => emit(state.copyWith(competitorItemLedgerEntries: [])),
    );
  }

  Future<void> _processUploadMerchandiseAndPosm() async {
    final response = await _moreRepo.processUploadMerchandiseAndPosm(
      records: state.merchandiseSchedules,
    );

    response.fold(
      (failure) => showErrorMessage(failure.message),
      (_) => emit(state.copyWith(merchandiseSchedules: [])),
    );
  }

  Future<void> _processUploadSchedules() async {
    final response = await _moreRepo.processUploadSchedule(
      records: state.salespersonSchedules,
    );

    response.fold(
      (failure) => showErrorMessage(failure.message),
      (schedules) => emit(state.copyWith(salespersonSchedules: schedules)),
    );
  }

  Future<void> _gpsTracking() async {
    final response = await _moreRepo.processUploadGpsTracking();

    response.fold((failure) => showErrorMessage(failure.message), (_) {});
  }

  Future<void> _gpsRouteTracking() async {
    final response = await _moreRepo.syncOfflineLocationToBackend();
    response.fold((failure) => showErrorMessage(failure.message), (_) {});
  }

  // Private Data Loading Methods
  Future<void> _loadRedeptionEntries() async {
    await _handleResponse(
      () => _taskRepo.getItemPrizeRedemptionEntries(
        param: {'status': kStatusSubmit, 'is_sync': kStatusNo},
      ),
      (List<ItemPrizeRedemptionLineEntry> data) {
        return state.copyWith(redemptions: data);
      },
    );
  }

  Future<void> _loadCustomerItemLedgerEntries() async {
    await _handleResponse(
      () => _taskRepo.getCustomerItemLegerEntries(
        param: {'status': kStatusSubmit, 'is_sync': kStatusNo},
      ),
      (List<CustomerItemLedgerEntry> data) {
        return state.copyWith(customerItemLedgerEntries: data);
      },
    );
  }

  Future<void> _loadSalesData() async {
    await _handleResponse(
      () => _taskRepo.getSaleHeaders(
        params: {'is_sync': kStatusNo, 'status': kStatusApprove},
      ),
      (List<SalesHeader> data) {
        return state.copyWith(salesHeaders: data);
      },
    );
  }

  Future<void> _loadSalesLines() async {
    if (state.salesHeaders.isEmpty) return;

    final headerNumbers = state.salesHeaders.map((h) => '"${h.no}"').toList();

    await _handleResponse(
      () => _taskRepo.getSaleLines(
        params: {
          'document_no': 'IN {${headerNumbers.join(",")}}',
          'is_sync': kStatusNo,
        },
      ),
      (List<SalesLine> data) {
        return state.copyWith(salesLines: data);
      },
    );
  }

  Future<void> _loadCashReceiptJournals() async {
    await _handleResponse(
      () => _taskRepo.getCashReceiptJournals(
        param: {'status': kStatusSubmit, 'is_sync': kStatusNo},
      ),
      (List<CashReceiptJournals> data) {
        return state.copyWith(cashReceiptJournals: data);
      },
    );
  }

  Future<void> _loadSalespersonSchedules(DateTime date) async {
    await _handleResponse(
      () => _taskRepo.getLocalSchedules(
        param: {'schedule_date': date.toDateString()},
      ),
      (List<SalespersonSchedule> data) {
        return state.copyWith(salespersonSchedules: data);
      },
    );
  }

  Future<void> _loadCompetitorItemLedgerEntries() async {
    await _handleResponse(() => _taskRepo.getCompetitorItemLedgetEntry(), (
      List<CompetitorItemLedgerEntry> data,
    ) {
      return state.copyWith(competitorItemLedgerEntries: data);
    });
  }

  Future<void> _loadMerchandiseSchedules() async {
    await _handleResponse(
      () => _taskRepo.getSalesPersonScheduleMerchandises(
        param: {'status': kStatusSubmit, 'is_sync': kStatusNo},
      ),
      (List<SalesPersonScheduleMerchandise> data) {
        return state.copyWith(merchandiseSchedules: data);
      },
    );
  }

  // Generic Response Handler
  Future<void> _handleResponse<T>(
    Future<dynamic> Function() request,
    UploadState Function(T data) onSuccess,
  ) async {
    final response = await request();
    response.fold((l) => showErrorMessage(), (data) => emit(onSuccess(data)));
  }
}
