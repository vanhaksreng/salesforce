import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/competitor_promotion_line/competitor_promotion_line_state.dart';
import 'package:salesforce/injection_container.dart';

class CompetitorPromotionLineCubit extends Cubit<CompetitorPromotionLineState> with MessageMixin {
  CompetitorPromotionLineCubit() : super(const CompetitorPromotionLineState(isLoading: true));

  final _repo = getIt<TaskRepository>();

  Future<void> getCompetitorProLine({Map<String, dynamic>? param}) async {
    try {
      emit(state.copyWith(isLoading: true));
      await _repo.getCompetitorProLine(param: param).then((response) {
        response.fold(
          (l) => throw GeneralException(l.message),
          (r) => emit(state.copyWith(promotionLines: r, isLoading: false)),
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
}
