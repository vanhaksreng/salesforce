import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/redemptions/redemptions_state.dart';
import 'package:salesforce/injection_container.dart';

class RedemptionsCubit extends Cubit<RedemptionsState> with MessageMixin {
  RedemptionsCubit() : super(const RedemptionsState(isLoading: true));
  final _repo = getIt<MoreRepository>();

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
}
