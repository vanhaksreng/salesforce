import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/item_promotion/item_promotion_state.dart';
import 'package:salesforce/injection_container.dart';

class ItemPromotionCubit extends Cubit<ItemPromotionState> {
  ItemPromotionCubit() : super(const ItemPromotionState(isLoading: true));

  final _taskRepo = getIt<TaskRepository>();

  Future<void> getItemPromotionHeaders() async {
    try {
      emit(state.copyWith(isLoading: true));

      await _taskRepo.getItemPromotionHeaders().then((response) {
        response.fold((l) => throw GeneralException(l.message), (promotionHeaders) {
          emit(state.copyWith(isLoading: false, headers: promotionHeaders));
        });
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
