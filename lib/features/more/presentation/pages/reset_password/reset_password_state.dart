class ResetPasswordState {
  final bool loading;
  final String? error;
  final bool isCurrentObscure;
  final bool isNewObscure;
  final bool isConfirmObscure;
  final bool isMatchingPassword;
  final bool resetPasswordSuccess;

  ResetPasswordState({
    this.loading = false,
    this.error,
    this.isCurrentObscure = true,
    this.isNewObscure = true,
    this.isConfirmObscure = true,
    this.isMatchingPassword = false,
    this.resetPasswordSuccess = false,
  });

  ResetPasswordState copyWith({
    bool? loading,
    String? error,
    bool? isCurrentObscure,
    bool? isNewObscure,
    bool? isConfirmObscure,
    bool? isMatchingPassword,
    bool? resetPasswordSuccess,
  }) {
    return ResetPasswordState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      isCurrentObscure: isCurrentObscure ?? this.isCurrentObscure,
      isNewObscure: isNewObscure ?? this.isNewObscure,
      isConfirmObscure: isConfirmObscure ?? this.isConfirmObscure,
      isMatchingPassword: isMatchingPassword ?? this.isMatchingPassword,
      resetPasswordSuccess: resetPasswordSuccess ?? this.resetPasswordSuccess,
    );
  }
}
