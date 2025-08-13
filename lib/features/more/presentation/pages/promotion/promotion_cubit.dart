import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/promotion/promotion_state.dart';
import 'package:salesforce/injection_container.dart';

class PromotionCubit extends Cubit<PromotionState> {
  PromotionCubit() : super(const PromotionState(isLoading: true));
  final _repos = getIt<MoreRepository>();

  Future<void> getItemPromotionHeaders() async {
    try {
      emit(state.copyWith(isLoading: true));

      await _repos.getItemPromotionHeaders().then((response) {
        response.fold((l) => throw GeneralException(l.message), (promotionHeaders) {
          emit(state.copyWith(isLoading: false, headers: promotionHeaders));
        });
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }
}

//
