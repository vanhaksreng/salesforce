part of 'posm_and_merchanding_competitor_cubit.dart';

class PosmAndMerchandingCompetitorState {
  final bool isLoading;
  final bool isFetching;
  final bool activeSearch;
  final int currentPage;
  final int dataCount;
  final List<Competitor>? completitor;
  final List<SalesPersonScheduleMerchandise> spsms;

  const PosmAndMerchandingCompetitorState({
    this.isLoading = false,
    this.currentPage = 1,
    this.completitor,
    this.activeSearch = false,
    this.dataCount = 0,
    this.isFetching = false,
    this.spsms = const [],
  });

  PosmAndMerchandingCompetitorState copyWith({
    List<Competitor>? completitor,
    int? currentPage,
    bool? isFetching,
    bool? isLoading,
    bool? activeSearch,
    int? dataCount,
    List<SalesPersonScheduleMerchandise>? spsms,
  }) {
    return PosmAndMerchandingCompetitorState(
      isLoading: isLoading ?? this.isLoading,
      completitor: completitor ?? this.completitor,
      currentPage: currentPage ?? this.currentPage,
      isFetching: isFetching ?? this.isFetching,
      activeSearch: activeSearch ?? this.activeSearch,
      dataCount: dataCount ?? this.dataCount,
      spsms: spsms ?? this.spsms,
    );
  }
}
