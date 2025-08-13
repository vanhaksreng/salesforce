import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/download_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

part 'process_state.dart';

class ProcessCubit extends Cubit<ProcessState> with AppMixin, DownloadMixin, PermissionMixin {
  ProcessCubit() : super(const ProcessState(isLoading: true));
  final _taskRepo = getIt<TaskRepository>();

  Future<void> loadInitialData(SalespersonSchedule schedule) async {
    emit(state.copyWith(isLoading: true, schedule: schedule));

    await Future.wait([
          getCountCheckStock(schedule),
          getCountSales(schedule),
          getCountCollection(schedule),
          getCountCompetitorPromotion(schedule),
          getCountPosmAndMerchandising(schedule),
          getCountItemPrizeRedemptionEntries(schedule),
        ])
        .then((_) {
          emit(state.copyWith(isLoading: false));
        })
        .catchError((error) {
          Logger.log("Exception in loadInitialData: $error");
          emit(state.copyWith(isLoading: false, error: error.toString()));
        });
  }

  Future<void> getCountItemPrizeRedemptionEntries(SalespersonSchedule schedule) async {
    await _taskRepo.getItemPrizeRedemptionEntries(param: {'schedule_id': schedule.id, 'status': kStatusOpen}).then((
      response,
    ) {
      response.fold((l) => throw GeneralException(l.message), (entries) {
        emit(state.copyWith(countItemPrizeRedeption: entries.length));
      });
    });
  }

  Future<void> getCountPosmAndMerchandising(SalespersonSchedule schedule) async {
    await _taskRepo
        .getSalesPersonScheduleMerchandises(param: {'status': kStatusOpen, 'visit_no': state.schedule?.id})
        .then((resonse) {
          resonse.fold((l) => throw GeneralException(l.message), (r) {
            emit(
              state.copyWith(
                countPosm: r.where((e) => e.merchandiseOption == kPOSM).length,
                countMerchandising: r.where((e) => e.merchandiseOption == kMerchandize).length,
                isLoading: false,
              ),
            );
          });
        });
  }

  Future<void> getCountCompetitorPromotion(SalespersonSchedule schedule) async {
    await _taskRepo.getCompetitorItemLedgetEntry(param: {'status': kStatusOpen, 'schedule_id': schedule.id}).then((
      resonse,
    ) {
      resonse.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(countCompetitorPromotion: r.length, isLoading: false));
      });
    });
  }

  Future<void> getCountCollection(SalespersonSchedule schedule) async {
    await _taskRepo.getCashReceiptJournal(param: {'status': kStatusOpen, 'source_no': schedule.id}).then((resonse) {
      resonse.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(countCollection: r == null ? 0 : 1, isLoading: false));
      });
    });
  }

  Future<void> getCountCheckStock(SalespersonSchedule schedule) async {
    await _taskRepo.getCustomerItemLedgerEntry(param: {'schedule_id': schedule.id, 'status': kStatusOpen}).then((
      resonse,
    ) {
      resonse.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(isLoading: false, countCheckStock: r == null ? 0 : 1));
      });
    });

    if (state.countCheckStock > 0) {
      return; // If there are already check stock entries, skip competitor item ledger entry count
    }

    await _taskRepo.getCompetitorItemLedgetEntry(param: {'source_no': state.schedule?.id, 'status': kStatusOpen}).then((
      resonse,
    ) {
      resonse.fold(
        (l) => throw GeneralException(l.message),
        (r) => emit(state.copyWith(isLoading: false, countCheckStock: r.length)),
      );
    });
  }

  Future<void> getCountSales(SalespersonSchedule schedule) async {
    await _taskRepo.getPosSaleHeaders(params: {'source_no': schedule.id, 'source_type': kSourceTypeVisit}).then((
      resonse,
    ) {
      resonse.fold((l) => throw GeneralException(l.message), (headers) {
        emit(
          state.copyWith(
            isLoading: false,
            countSaleOrder: headers.where((e) => e.documentType == kSaleOrder).length,
            countSaleInvoice: headers.where((e) => e.documentType == kSaleInvoice).length,
            countSaleCreditMemo: headers.where((e) => e.documentType == kSaleCreditMemo).length,
          ),
        );
      });
    });
  }

  Future<void> getItemUom({required String itemNo, required String uOmCode}) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await _taskRepo.getItemUom(params: {'item_no': itemNo, 'unit_of_measure_code': uOmCode});

      response.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (itemUom) async {
          emit(state.copyWith(isLoading: false, itemUom: itemUom));
        },
      );
    } catch (error) {
      Logger.log("Exception in getItemUom: $error");
      emit(state.copyWith(isLoading: false));
    }
  }

  void updateCountCart(int totalCount) {
    emit(state.copyWith(cartCount: totalCount));
  }

  Future<void> getItemPromotionHeaders() async {
    try {
      emit(state.copyWith(isLoading: true));

      await _taskRepo.getItemPromotionHeaders().then((response) {
        response.fold((l) => throw GeneralException(l.message), (promotionHeaders) {
          emit(state.copyWith(isLoading: false));
        });
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getSaleLines({required String scheduleId, required String documentType}) async {
    try {
      emit(state.copyWith(isLoading: true));

      final saleNo = Helpers.getSaleDocumentNo(scheduleId: scheduleId, documentType: documentType);

      final response = await _taskRepo.getPosSaleLines(params: {'document_no': saleNo, 'document_type': documentType});

      response.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(cartCount: r.length, isLoading: false));
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void updateAction(ActionState action) {
    emit(state.copyWith(actionState: action));
  }

  void refreshing() {
    emit(state.copyWith(isRefreshing: !state.isRefreshing));
  }
}
