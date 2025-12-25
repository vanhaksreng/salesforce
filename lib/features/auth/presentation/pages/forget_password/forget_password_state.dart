import 'package:salesforce/realm/scheme/schemas.dart';

class ForgetPasswordState {
  final bool isLoading;
  final String? error;
  final CompanyInformation? company;

  const ForgetPasswordState({this.isLoading = false, this.error, this.company});

  ForgetPasswordState copyWith({
    bool? isLoading,
    String? error,
    CompanyInformation? company,
  }) {
    return ForgetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      company: company ?? this.company,
    );
  }
}
