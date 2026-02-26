class SplashState {
	final bool isLoading;
	final bool isUseGpsTracing;
	final String? error;
	  
	const SplashState({
		this.isLoading = false,
		this.isUseGpsTracing = false,
		this.error,
	});
	  
	SplashState copyWith({
		bool? isLoading,
		bool? isUseGpsTracing,
		String? error,
	}) {
		return SplashState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
			isUseGpsTracing: isUseGpsTracing ?? this.isUseGpsTracing,
		);
	}
}
