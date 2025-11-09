import 'package:salesforce/realm/scheme/schemas.dart';

class VerifyPhoneNumberState {
  final bool isLoading;
  final String? error;
  final CompanyInformation? company;
  final String? initialSelection;

  const VerifyPhoneNumberState({
    this.isLoading = false,
    this.error,
    this.company,
    this.initialSelection,
  });

  VerifyPhoneNumberState copyWith({
    bool? isLoading,
    String? error,
    CompanyInformation? company,
    String? initialSelection,
  }) {
    return VerifyPhoneNumberState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      company: company ?? this.company,
      initialSelection: initialSelection ?? this.initialSelection,
    );
  }
}
