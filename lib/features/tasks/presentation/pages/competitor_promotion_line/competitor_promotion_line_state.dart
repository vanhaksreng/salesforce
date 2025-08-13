import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CompetitorPromotionLineState {
  final bool isLoading;
  final String? error;
  final List<CompetitorPromotionLine> promotionLines;

  const CompetitorPromotionLineState({this.isLoading = false, this.error, this.promotionLines = const []});

  CompetitorPromotionLineState copyWith({
    bool? isLoading,
    String? error,
    List<CompetitorPromotionLine>? promotionLines,
  }) {
    return CompetitorPromotionLineState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      promotionLines: promotionLines ?? this.promotionLines,
    );
  }
}
