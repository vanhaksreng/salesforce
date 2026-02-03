import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/about/about/about_state.dart';
import 'package:salesforce/injection_container.dart';

class AboutCubit extends Cubit<AboutState> with MessageMixin {
  AboutCubit() : super(AboutState(isLoading: false));

  final appRepos = getIt<MoreRepository>();

  Future<void> checkAppVersion({Map<String, dynamic>? param}) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await appRepos.checkAppVersion(param: param);

      response.fold(
        (l) => throw GeneralException(l.message),
        (appVersion) =>
            emit(state.copyWith(appVersion: appVersion, isLoading: false)),
      );
    } on GeneralException catch (e) {
      emit(state.copyWith(isLoading: false));
      showWarningMessage(e.message);
    } catch (error) {
      emit(state.copyWith(isLoading: false));
      showErrorMessage();
    }
  }
}
