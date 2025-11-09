import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/auth/presentation/pages/forget_password/forget_password_state.dart';
import 'package:salesforce/injection_container.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> with MessageMixin {
  ForgetPasswordCubit() : super(ForgetPasswordState(isLoading: true));

  final _baseAppRepository = getIt<BaseAppRepository>();

  Future<void> getCompanyInfo() async {
    try {
      emit(state.copyWith(isLoading: true));
      final companyInfo = await _baseAppRepository.getCompanyInfo();
      companyInfo.fold((failure) => showErrorMessage(failure.message), (
        companyInfo,
      ) {
        emit(state.copyWith(company: companyInfo, isLoading: false));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
