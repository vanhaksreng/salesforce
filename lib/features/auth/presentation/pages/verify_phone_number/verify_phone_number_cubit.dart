import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/features/auth/presentation/pages/verify_phone_number/verify_phone_number_state.dart';
import 'package:salesforce/injection_container.dart';

class VerifyPhoneNumberCubit extends Cubit<VerifyPhoneNumberState>
    with MessageMixin {
  VerifyPhoneNumberCubit()
    : super(VerifyPhoneNumberState(isLoading: true, initialSelection: '+855'));

  final _repos = getIt<AuthRepository>();
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

  Future<bool> verifyResetPassword(Map arg) async {
    try {
      final data = await _repos.verifyResetPassword(arg: arg);

      data.fold(
        (failure) {
          showErrorMessage(failure.message);
          emit(state.copyWith(isLoading: false));
          return false;
        },
        (data) {
          emit(state.copyWith(isLoading: false));
          return true;
        },
      );
      return true;
    } catch (e) {
      showWarningMessage(e.toString());
      return false;
    }
  }

  void selectCountry(String country) {
    emit(state.copyWith(initialSelection: country));
  }
}
