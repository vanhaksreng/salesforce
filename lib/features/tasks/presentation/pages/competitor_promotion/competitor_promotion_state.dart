part of 'competitor_promotion_cubit.dart';

class CompetitorPromotionState {
  final bool isLoading;
  final bool isFetching;
  final bool activeSearch;
  final int currentPage;
  final List<CompetitorPromtionHeader>? completitorHeader;

  const CompetitorPromotionState({
    this.isLoading = false,
    this.currentPage = 1,
    this.completitorHeader,
    this.activeSearch = false,
    this.isFetching = false,
  });

  CompetitorPromotionState copyWith({
    List<CompetitorPromtionHeader>? completitorHeader,
    int? currentPage,
    bool? isFetching,
    bool? isLoading,
    bool? activeSearch,
  }) {
    return CompetitorPromotionState(
      isLoading: isLoading ?? this.isLoading,
      completitorHeader: completitorHeader ?? this.completitorHeader,
      currentPage: currentPage ?? this.currentPage,
      isFetching: isFetching ?? this.isFetching,
      activeSearch: activeSearch ?? this.activeSearch,
    );
  }
}
