class SplashState {
	final bool isLoading;
	final String? error;
	  
	const SplashState({
		this.isLoading = false,
		this.error,
	});
	  
	SplashState copyWith({
		bool? isLoading,
		String? error,
	}) {
		return SplashState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
		);
	}
}
