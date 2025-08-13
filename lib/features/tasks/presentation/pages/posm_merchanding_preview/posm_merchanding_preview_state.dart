import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class PosmMerchandingPreviewState {
  final bool isLoading;
  final String? error;
  final List<PointOfSalesMaterial> posms;
  final List<SalesPersonScheduleMerchandise> spsms;
  final bool isFetching;
  final int currentPage;

  const PosmMerchandingPreviewState({
    this.isLoading = false,
    this.error,
    this.posms = const [],
    this.spsms = const [],
    this.isFetching = false,
    this.currentPage = 1,
  });

  PosmMerchandingPreviewState copyWith({
    bool? isLoading,
    String? error,
    List<PointOfSalesMaterial>? posms,
    List<SalesPersonScheduleMerchandise>? spsms,
    bool? isFetching,
    int? currentPage,
  }) {
    return PosmMerchandingPreviewState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      posms: posms ?? this.posms,
      spsms: spsms ?? this.spsms,
      isFetching: isFetching ?? this.isFetching,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
