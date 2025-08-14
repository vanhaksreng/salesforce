import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/my_schedule/my_schedule_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class MyScheduleCubit extends Cubit<MyScheduleState> with PermissionMixin, MessageMixin, AppMixin {
  MyScheduleCubit() : super(const MyScheduleState(isLoading: false));

  final _repos = getIt<TaskRepository>();

  Future<void> loadAppSetting() async {
    try {
      await _repos.downloadAppSetting().then((respose) {
        respose.fold((l) => throw GeneralException(l.message), (r) async {
          emit(state.copyWith(isLoading: false));
        });
      });
    } on GeneralException {
      // showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getUserSetup() async {
    final userSetupRes = await _repos.getUserSetup();
    userSetupRes.fold((l) => throw GeneralException(l.message), (user) => emit(state.copyWith(userSetup: user)));
  }

  Future<void> pendingScheduleValidate() async {
    if (state.userSetup == null) {
      throw GeneralException("User setup not found");
    }

    final response = await _repos.getLocalSchedules(
      param: {
        'schedule_date': DateTime.now().toDateString(),
        'status': 'Checked In',
        'salesperson_code': state.userSetup?.salespersonCode,
      },
    );

    bool hasPending = response.fold((failure) => false, (schedules) => schedules.isNotEmpty);

    if (hasPending) {
      throw GeneralException(greeting("you_has_any_pending_schedule"));
    }
  }

  Future<void> getSchedules(DateTime date, {String text = "", bool isLoading = true, bool requestApi = true}) async {
    try {
      emit(state.copyWith(isLoading: isLoading));

      final response = await _repos.getLocalSchedules(
        param: {
          "status": state.selectedStatus == "All" ? null : state.selectedStatus,
          "name": 'LIKE $text%',
          'schedule_date': DateTime.now().toDateString(),
          'salesperson_code': state.userSetup?.salespersonCode,
        },
      );

      response.fold((failure) => throw Exception(failure.message), (schedules) {
        emit(
          state.copyWith(
            isLoading: false,
            schedules: schedules,
            totalVisit: schedules.length,
            countCheckOut: schedules.where((e) => e.status == kStatusCheckOut).length,
          ),
        );
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> updatedScheduleStatus(SalespersonSchedule schedule) async {
    final schedules = List<SalespersonSchedule>.from(state.schedules);
    final index = schedules.indexWhere((e) => e.id == schedule.id);

    if (index != -1) {
      schedules[index] = schedule;
      emit(state.copyWith(schedules: schedules));
    }
  }

  Future<bool> hasRecordCheckOut(String scheduleId) async {
    final List<SalespersonSchedule> salesPersonSchedules = state.schedules;
    bool isHasCheckIn = salesPersonSchedules.any((e) => e.id == scheduleId);
    if (isHasCheckIn) {
      return true;
    }
    return false;
  }

  Future<void> initLoadPendingTasks(SalespersonSchedule schedule) async {
    emit(state.copyWith(schedule: schedule));

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
          emit(state.copyWith(isLoading: false));
        });
  }

  Future<void> getCountItemPrizeRedemptionEntries(SalespersonSchedule schedule) async {
    await _repos.getItemPrizeRedemptionEntries(param: {'schedule_id': schedule.id, 'status': kStatusOpen}).then((
      response,
    ) {
      response.fold((l) => throw GeneralException(l.message), (entries) {
        emit(state.copyWith(countItemPrizeRedeption: entries.length));
      });
    });
  }

  Future<void> getCountPosmAndMerchandising(SalespersonSchedule schedule) async {
    await _repos.getSalesPersonScheduleMerchandises(param: {'visit_no': state.schedule?.id}).then((resonse) {
      resonse.fold((l) => throw GeneralJournalBatch(l.message), (r) {
        final posm = List<SalesPersonScheduleMerchandise>.from(r.where((e) => e.merchandiseOption == kPOSM));
        final merchandize = List<SalesPersonScheduleMerchandise>.from(
          r.where((e) => e.merchandiseOption == kMerchandize),
        );

        emit(
          state.copyWith(
            countPosm: posm.where((e) => e.status == kStatusOpen).length,
            countMerchandising: merchandize.where((e) => e.status == kStatusOpen).length,
            checkPosmRecords: posm,
            checkMerchandiseRecords: merchandize,
            isLoading: false,
          ),
        );
      });
    });
  }

  Future<void> getCountCompetitorPromotion(SalespersonSchedule schedule) async {
    await _repos.getCompetitorItemLedgetEntry(param: {'status': kStatusOpen}).then((resonse) {
      resonse.fold((l) => throw GeneralJournalBatch(l.message), (r) {
        emit(state.copyWith(countCompetitorPromotion: r.length, isLoading: false));
      });
    });
  }

  Future<void> getCountCollection(SalespersonSchedule schedule) async {
    await _repos.getCashReceiptJournal(param: {'status': kStatusOpen}).then((resonse) {
      resonse.fold((l) => throw GeneralJournalBatch(l.message), (r) {
        emit(state.copyWith(countCollection: r == null ? 0 : 1, isLoading: false));
      });
    });
  }

  Future<void> getCountCheckStock(SalespersonSchedule schedule) async {
    await _repos.getCustomerItemLegerEntries(param: {'schedule_id': state.schedule?.id}).then((resonse) {
      resonse.fold((l) => throw GeneralJournalBatch(l.message), (r) {
        emit(
          state.copyWith(
            isLoading: false,
            countCheckStock: r.where(((e) => e.status == kStatusOpen)).length,
            checkItemStockRecords: r,
          ),
        );
      });
    });

    await _repos.getCompetitorItemLedgetEntry(param: {'schedule_id': state.schedule?.id}).then((resonse) {
      resonse.fold((l) => throw GeneralJournalBatch(l.message), (r) {
        emit(
          state.copyWith(
            isLoading: false,
            countCheckStock: r.where((e) => e.status == kStatusOpen).length + state.countCheckStock,
            checkCompetitorItemStockRecords: r,
          ),
        );
      });
    });
  }

  Future<void> getCountSales(SalespersonSchedule schedule) async {
    await _repos.getPosSaleHeaders(params: {'source_no': state.schedule?.id, 'source_type': kSourceTypeVisit}).then((
      resonse,
    ) {
      resonse.fold((l) => throw GeneralJournalBatch(l.message), (headers) {
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

  Future<void> getSaleLine(DateTime date, {bool requestApi = false}) async {
    try {
      final response = await _repos.getSaleLines(params: {'document_date': DateTime.now().toDateString()});

      response.fold((failure) => throw Exception(failure.message), (lines) {
        double totalSaleInv = lines
            .where((e) {
              return [kSaleInvoice, kSaleOrder].contains(e.documentType);
            })
            .fold(0.0, (sum, saleLine) => sum + Helpers.toDouble(saleLine.amountIncludingVatLcy));

        double totalSaleCr = lines
            .where((e) {
              return e.documentType == kSaleCreditMemo;
            })
            .fold(0.0, (sum, saleLine) => sum + Helpers.toDouble(saleLine.amountIncludingVatLcy));

        emit(state.copyWith(saleLines: lines, totalSales: totalSaleInv - totalSaleCr));
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void sortCustomerViaLatlng({required LatLng currentLocation}) {
    List<SalespersonSchedule> schedules = state.schedules;
    schedules.sort((a, b) {
      final distanceA = Helpers.calculateDistanceInMeters(
        currentLocation.latitude,
        currentLocation.longitude,
        a.latitude ?? 0,
        a.longitude ?? 0,
      );

      final distanceB = Helpers.calculateDistanceInMeters(
        currentLocation.latitude,
        currentLocation.longitude,
        b.latitude ?? 0,
        b.longitude ?? 0,
      );

      return distanceA.compareTo(distanceB);
    });
    final sortedSchedules = state.schedules.toList()
      ..sort((a, b) {
        final distanceA = Helpers.calculateDistanceInMeters(
          currentLocation.latitude,
          currentLocation.longitude,
          a.latitude ?? 0,
          a.longitude ?? 0,
        );
        final distanceB = Helpers.calculateDistanceInMeters(
          currentLocation.latitude,
          currentLocation.longitude,
          b.latitude ?? 0,
          b.longitude ?? 0,
        );
        return distanceA.compareTo(distanceB);
      });
    emit(state.copyWith(schedules: sortedSchedules));
  }

  void changeSortBy(bool isSortDistance) {
    emit(state.copyWith(isSortDistance: isSortDistance));
  }

  void changeStatus(String status) {
    emit(state.copyWith(selectedStatus: status));
  }

  void resetStatus() {
    emit(state.copyWith(selectedStatus: "All", isSortDistance: false));
  }
}
