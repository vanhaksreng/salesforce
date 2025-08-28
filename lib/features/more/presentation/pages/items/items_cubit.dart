import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/download_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/items/items_state.dart';
import 'package:salesforce/injection_container.dart';

class ItemsCubit extends Cubit<ItemsState>
    with MessageMixin, DownloadMixin, AppMixin {
  ItemsCubit() : super(ItemsState(isLoading: true));
  final MoreRepository _moreRepo = getIt<MoreRepository>();

  late bool hasMorePage = true;

  Future<void> getSaleLines({
    required String scheduleId,
    required String documentType,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));

      final saleNo = Helpers.getSaleDocumentNo(
        scheduleId: scheduleId,
        documentType: documentType,
      );

      final response = await _moreRepo.getPosSaleLines(
        params: {'document_no': saleNo, 'document_type': documentType},
      );

      response.fold((l) => throw GeneralException(l.message), (r) {
        emit(
          state.copyWith(saleLines: r, cartCount: r.length, isLoading: false),
        );
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getItems({
    bool isLoading = true,
    int page = 1,
    Map<String, dynamic>? param,
  }) async {
    try {
      if (!hasMorePage && page > 1) {
        return;
      }

      hasMorePage = true;

      final oldItems = state.items;
      emit(state.copyWith(isLoading: isLoading, isFetching: true));

      final response = await _moreRepo.getItems(page: page, param: param);

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
            items: page == 1 ? items : [...oldItems, ...items],
          ),
        );
      });
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isFetching: false,
          error: e.toString(),
        ),
      );
    }
  }
}
