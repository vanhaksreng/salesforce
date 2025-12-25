import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

part 'item_merchandising_state.dart';

class ItemMerchandisingCubit extends Cubit<ItemMerchandisingState> with MessageMixin {
  ItemMerchandisingCubit() : super(const ItemMerchandisingState(isLoading: true));
  final _taskRepos = getIt<TaskRepository>();

  late bool hasMorePage = true;

  Future<void> getSalesPersonScheduleMerchandises({Map<String, dynamic>? param}) async {
    try {
      final response = await _taskRepos.getSalesPersonScheduleMerchandises(param: param);
      response.fold((l) => throw GeneralException(l.message), (items) {
        emit(state.copyWith(spsms: items, isLoading: false));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> storeSalesPersonScheduleMerchandise({required ItemPosmAndMerchandiseArg args}) async {
    try {
      final list = List<SalesPersonScheduleMerchandise>.from(state.spsms);

      // if (args.qty == 0) {
      //   final index = list.indexWhere((e) {
      //     return e.competitorNo == args.competitor?.no && e.merchandiseCode == args.posm?.code;
      //   });

      //   if (index != -1) {
      //     _taskRepos.deleteSalesPersonScheduleMerchandise(list[index]).then((response) {
      //       response.fold(
      //         (l) => throw GeneralException(l.message),
      //         (r) => state.spsms.removeAt(index),
      //       );
      //     });
      //   }

      //   return;
      // }

      final response = await _taskRepos.storeSalesPersonScheduleMerchandise(args: args);
      response.fold((l) => throw GeneralException(l.message), (items) {
        final index = list.indexWhere((item) => item.merchandiseCode == items.merchandiseCode);
        if (index != -1) {
          list[index] = items;
        } else {
          list.add(items);
        }

        emit(state.copyWith(spsms: list, isLoading: false));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> submitMerchandiseSchdedule() async {
    try {
      final lists = List<SalesPersonScheduleMerchandise>.from(state.spsms.where((e) => e.status == kStatusOpen));
      if (lists.isEmpty) {
        showWarningMessage("Nothing to submit");
        return;
      }

      final response = await _taskRepos.updateSalesPersonScheduleMerchandiseStatus(lists, status: kStatusSubmit);

      response.fold((l) => throw GeneralException(l.message), (items) {
        emit(state.copyWith(isLoading: false, spsms: items));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getMerchandises({bool isLoading = true, int page = 1, Map<String, dynamic>? param}) async {
    try {
      if (!hasMorePage && page > 1) {
        return;
      }

      hasMorePage = true;

      final oldItems = state.merchindises ?? [];
      emit(state.copyWith(isLoading: isLoading, isFetching: true));

      final response = await _taskRepos.merchandises(page: page, param: param);

      return response.fold((l) => throw GeneralException(l.message), (items) {
        if (page > 1 && items.isEmpty) {
          hasMorePage = false;
          return;
        }

        emit(
          state.copyWith(
            isLoading: false,
            isFetching: false,
            currentPage: page,
            merchindises: page == 1 ? items : [...oldItems, ...items],
          ),
        );
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false, isFetching: false));
    }
  }
}
