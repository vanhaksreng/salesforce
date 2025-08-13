class LoggedinHistoryState {
	final bool isLoading;
	final String? error;
	  
	const LoggedinHistoryState({
		this.isLoading = false,
		this.error,
	});
	  
	LoggedinHistoryState copyWith({
		bool? isLoading,
		String? error,
	}) {
		return LoggedinHistoryState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
		);
	}
}
