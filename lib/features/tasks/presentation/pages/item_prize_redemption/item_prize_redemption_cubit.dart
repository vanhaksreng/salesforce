import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_prize_redemption/item_prize_redemption_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class ItemPrizeRedemptionCubit extends Cubit<ItemPrizeRedemptionState> with MessageMixin {
  ItemPrizeRedemptionCubit() : super(const ItemPrizeRedemptionState(isLoading: true));
  final _repo = getIt<TaskRepository>();

  Future<void> initLoadData(DefaultProcessArgs arg) async {
    emit(state.copyWith(args: arg));
  }

  Future<void> getItemPrizeRedemptionHeader() async {
    try {
      emit(state.copyWith(isLoading: true));
      await _repo.getItemPrizeRedemptionHeader().then((response) {
        response.fold(
          (l) => throw GeneralException(l.message),
          (headers) => emit(state.copyWith(headers: headers, isLoading: false)),
        );
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (e) {
      showErrorMessage(e.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getItemPrizeRedemptionLine() async {
    final headers = state.headers.map((h) => '"${h.no}"').toList();

    try {
      await _repo.getItemPrizeRedemptionLine(param: {'promotion_no': 'IN {${headers.join(",")}}'}).then((response) {
        response.fold((l) => throw GeneralException(l.message), (lines) => emit(state.copyWith(lines: lines)));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (e) {
      showErrorMessage(e.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getItemPrizeRedemptionEntries() async {
    final headers = state.headers.map((h) => '"${h.no}"').toList();

    try {
      await _repo
          .getItemPrizeRedemptionEntries(
            param: {'promotion_no': 'IN {${headers.join(",")}}', 'schedule_id': state.args?.schedule.id},
          )
          .then((response) {
            response.fold(
              (l) => throw GeneralException(l.message),
              (entries) => emit(state.copyWith(entries: entries)),
            );
          });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (e) {
      showErrorMessage(e.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> processTakeInRedemption(ItemPrizeRedemptionHeader header, double quantity) async {
    if (state.args?.schedule == null) {
      showWarningMessage("Schedule not initailize.");
      return;
    }

    try {
      final response = await _repo.processTakeInRedemption(
        header: header,
        quantity: quantity,
        schedule: state.args!.schedule,
      );

      response.fold(
        (l) {
          throw GeneralException(l.message);
        },
        (entries) {
          getItemPrizeRedemptionEntries();
        },
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (e) {
      showErrorMessage(e.toString());
    }
  }

  Future<void> deleteTakeInRedemption(ItemPrizeRedemptionHeader header) async {
    await _repo.deleteTakeInRedemption(header, state.args?.schedule.id ?? "");
    getItemPrizeRedemptionEntries();
  }

  Future<void> processSubmitRedemption() async {
    try {
      final entries = state.entries.where((e) => e.status == kStatusOpen).toList();
      if (entries.isEmpty) {
        showWarningMessage("Nothing to submit");
        return;
      }

      final response = await _repo.processSubmitRedemption(entries);
      response.fold(
        (l) {
          throw GeneralException(l.message);
        },
        (entries) {
          showSuccessMessage("Submited success");
          getItemPrizeRedemptionEntries();
        },
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (e) {
      showErrorMessage(e.toString());
    }
  }
}
