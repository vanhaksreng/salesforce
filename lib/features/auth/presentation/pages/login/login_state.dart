class LoginState {
  final bool isLoading;
  final String? keys;

  const LoginState({
    this.isLoading = false,
    this.keys,
  });

  LoginState copyWith({
    bool? isLoading,
    String? keys,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      keys: keys ?? this.keys,
    );
  }
}
