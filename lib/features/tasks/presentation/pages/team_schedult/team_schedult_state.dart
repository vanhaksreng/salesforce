class TeamSchedultState {
	final bool isLoading;
	final String? error;
	  
	const TeamSchedultState({
		this.isLoading = false,
		this.error,
	});
	  
	TeamSchedultState copyWith({
		bool? isLoading,
		String? error,
	}) {
		return TeamSchedultState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
		);
	}
}
